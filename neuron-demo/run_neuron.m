function run_neuron()
addpath('neuron-demo\matlab');

%% Setup
if ~isfile('config.mat')
    make_config();
end
config = load('config.mat');

assert(exist(config.nrnBin, 'dir'), '%s is not a folder. Verify that NEURON is installed and that its path is correctly set by running make_config().', config.nrnBin);

MRG_coeff = load('data/MRG_coeff.mat');

subject = 'Subject1';
electrode = 'TIME4H_8';

asList = arrayfun(@num2str, 1:4, 'UniformOutput', false);
[iAS, tf] = listdlg('PromptString', 'Select active site', 'ListString', asList, 'SelectionMode', 'single');
if ~tf, return; end
model = load_model(subject, electrode, asList{iAS}, true);

[iFasc, tf] = listdlg('PromptString', 'Select fascicle', 'ListString', arrayfun(@num2str, model.fascIds, 'UniformOutput', false), 'SelectionMode', 'single');
if ~tf, return; end
model.motorFasc = model.fascIds(iFasc);

[iModel, tf] = listdlg('PromptString', 'Select model', 'ListString', {'MRG', 'Gaines'}, 'SelectionMode', 'single');
if ~tf, return; end

gaines = iModel == 2;

%% Select fibers
minDiamIFibers = 12;
minDiamIIFibers = 6;
[idIFibers, idIIFibers, idIIIFibers] = split_fibers(model, minDiamIFibers, minDiamIIFibers);
[numIaFibers, numIbFibers, numAlphaFibers] = default_I_fibers_count(idIFibers);

answer = inputdlg({'Number of Ia fibers (default 16% of diameter >= 12 um)', ...
    'Number of Ib fibers (default 12% of diameter >= 12 um)', ...
    'Number of Alpha Motor fibers (default 72% of diameter >= 12 um)', ...
    'Number of II fibers (default all of diameter >= 6 and < 12 um)', ...
    'Number of III fibers (default all of diameter < 6)', ...
    'Minimum diameter of I and Alpha motor fibers [um]', ...
    'Minimum diameter of II fibers [um]'}, ...
    'Fibers population', 1, ...
    {num2str(numIaFibers), ...
    num2str(numIbFibers), ...
    num2str(numAlphaFibers), ...
    num2str(numel(idIIFibers)), ...
    num2str(numel(idIIIFibers)), ...
    num2str(minDiamIFibers), ...
    num2str(minDiamIIFibers)});

numIaFibers = str2double(answer{1});
numIbFibers = str2double(answer{2});
numAlphaFibers = str2double(answer{3});
numIIFibers = str2double(answer{4});
numIIIFibers = str2double(answer{5});
minDiamIFibers = str2double(answer{6});
minDiamIIFibers = str2double(answer{7});

[idIFibers, idIIFibers, idIIIFibers] = split_fibers(model, minDiamIFibers, minDiamIIFibers);
maxNumIFibers = numel(idIFibers);
maxNumIIFibers = numel(idIIFibers);
maxNumIIIFibers = numel(idIIIFibers);

assert(numIaFibers + numIbFibers + numAlphaFibers <= maxNumIFibers, ...
    'The chosen number of primary and alpha motor fibers exceeds the number of fibers within the chosen diameter range (%d).', maxNumIFibers);

assert(numIIFibers <= maxNumIIFibers, ...
    'The chosen number of II fibers exceeds the number of fibers within the chosen diameter range (%d).', maxNumIIFibers);

assert(numIIIFibers <= maxNumIIIFibers, ...
    'The chosen number of III fibers exceeds the number of fibers within the chosen diameter range (%d).', maxNumIIIFibers);

%% Plot cross-section
figure;
axCross = gca();
prepare_plot_cross_section(axCross);
colorbar off;
iCross = plot_cross_section(model, axCross);
motorBranches = model.endo.data{model.motorFasc, iCross};
XY = vertcat(motorBranches{:}, model.activeSites(iAS).coord');
minXY = min(XY);
maxXY = max(XY);
xlim([minXY(1) maxXY(1)]);
ylim([minXY(2) maxXY(2)]);

[iSelectionMode, tf] = listdlg('PromptString', 'Choose fiber selection mode', 'ListString', {'Random', 'Cluster'}, 'SelectionMode', 'single');
if ~tf, return; end

if iSelectionMode == 2
    [x, y] = cluster_selection();
    clusterCenters = [x, y];
else
    clusterCenters = [];
end

model = select_fibers(model, clusterCenters, minDiamIFibers, minDiamIIFibers, numIaFibers, numIbFibers, numAlphaFibers, numIIFibers, numIIIFibers);

plot_cross_section(model, axCross);

%% Run
fibers = model.fibers{iFasc};
assignedFibers = any(model.fiberType, 2);
nAssignedFibers = sum(assignedFibers);
V = model.V{model.fascIds(iFasc)};

% determine the current necessary to inject 1nC within the duration
currentFor1nC = 1e-9 / (config.stimDur * 1e-3);
V = cellfun(@(v) v * currentFor1nC / model.referenceCurrent, V, 'UniformOutput', false);

% Setup waitbar
D = parallel.pool.DataQueue;
h = waitbar(0, 'Running NEURON simulations...');
afterEach(D, @updateWaitbar);
p = 1;

thr = nan(height(fibers), 1);
r = fibers.r;
motor = model.get_fibers_by_type('Alpha Motor');
tic();
if gaines
    build_neuron_dll('Gaines/Motor');
    build_neuron_dll('Gaines/Sensory');
else
    build_neuron_dll('MRG');
end
parfor iFiber = 1:height(fibers)
    % Parallel execution requires Parallel Computing Toolbox, otherwise it
    % falls back to a simple for.
    if ~assignedFibers(iFiber)
        % Skip unassigned fibers
        continue;
    end
    if gaines
        if motor(iFiber)
            nrnModel = 'Gaines/Motor';
        else
            nrnModel = 'Gaines/Sensory';
        end
    else
        nrnModel = 'MRG';
    end
    thr(iFiber) = find_threshold(iFiber, r(iFiber), V{iFiber}, nrnModel, config, MRG_coeff);
    send(D, iFiber);
end
t = toc();
close(h);
fprintf('Simulation completed, mean time %.3f s per fiber\n', t/nAssignedFibers);

model.Q = 0:config.deltaQnC:config.qMaxnC;
model.fiberActive{iFasc} = thr;
if gaines
    model.nrnModel = 'Gaines';
else
    model.nrnModel = 'MRG';
end

dateString = datestr(now, 'yymmdd_HHMMSS');
runsDir = 'data\runs\';
if ~exist(runsDir, 'dir')
    mkdir(runsDir);
end
baseRunPath = [runsDir strjoin({subject, electrode, ['AS' asList{iAS}], ...
    ['fasc' num2str(model.motorFasc)], model.nrnModel, dateString}, '_')];
runPath = [baseRunPath '.mat'];
counter = 0;
while isfile(runPath)
    % Very unlikely
    counter = counter + 1;
    runPath = [baseRunPath '_' counter '.mat'];
end

fprintf('Saving model in %s...\n', runPath);
save(runPath, 'model', 'config');

view_run(model);

    function updateWaitbar(~)
        waitbar(p/nAssignedFibers, h);
        p = p + 1;
    end
end
