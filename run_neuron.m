function run_neuron()
%% Setup
config = load('config.mat');
MRG = load('data/MRG_coeff.mat');

asList = arrayfun(@num2str, 1:4, 'UniformOutput', false);
[iAS, tf] = listdlg('PromptString', 'Select active site', 'ListString', asList, 'SelectionMode', 'single');
if ~tf, return; end
model = load_model('Subject1', 'TIME4H_8', asList{iAS}, true);

[iFasc, tf] = listdlg('PromptString', 'Select fascicle', 'ListString', arrayfun(@num2str, model.fascIds, 'UniformOutput', false), 'SelectionMode', 'single');
if ~tf, return; end
model.motorFasc = model.fascIds(iFasc);
model = select_fibers(model, []);

[iModel, tf] = listdlg('PromptString', 'Select model', 'ListString', {'MRG', 'Gaines'}, 'SelectionMode', 'single');
if ~tf, return; end

gaines = iModel == 2;

%% Run
fibers = model.fibers{iFasc};
V = model.V{model.fascIds(iFasc)};

% determine the current necessary to inject 1nC within the duration
currentFor1nC = 1e-9 / (config.stimDur * 1e-3);
V = cellfun(@(v) v * currentFor1nC / model.referenceCurrent, V, 'UniformOutput', false);

thr = nan(height(fibers), 1);
r = fibers.r;
motor = model.AlphaFiberId;
parfor iFiber = 1:height(fibers)
    if gaines
        if ismember(iFiber, motor)
            nrnModel = 'Gaines/Motor';
        else
            nrnModel = 'Gaines/Sensory';
        end
    else
        nrnModel = 'MRG';
    end
    thr(iFiber) = find_threshold(iFiber, r(iFiber), V{iFiber}, nrnModel, config, MRG);
end

model.Q = 0:config.deltaQnC:config.qMaxnC;
model.fiberActive{iFasc} = thr;

dateString = datestr(now, 'yymmdd_HHMMSS');
counter = 1;
while true
    if counter == 1
        runName = dateString;
    else
        % Very unlikely
        runName = [dateString '_' counter];
    end
    runPath = ['data/runs/model_' runName '.mat'];
    if ~isfile(runPath), break; end
    counter = counter + 1;
end

fprintf('Saving model in %s...\n', runPath);
save(runPath, 'model');

%% Plot
figure;
tiledlayout(2, 1);
nexttile;
prepare_plot_cross_section(gca());
plot_cross_section(model, gca());
nexttile;
prepare_plot_recruitment(gca());
plot_recruitment(model, gca());

end

