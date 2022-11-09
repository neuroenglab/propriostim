addpath('helpers');
addpath('neuron-demo\matlab');
movementsFolder = 'data/movements';

movements = list_subfolders(movementsFolder);

% Select movement
iMovement = listdlg('ListString', movements, 'SelectionMode', 'single');

movementFolder = fullfile(movementsFolder, movements{iMovement});

[muscles, fullpaths] = list_csv(movementFolder);

fprintf('%d muscles found in the movement folder: %s\n', numel(muscles), strjoin(muscles, ', '));

subject = 'Subject1';
electrode = 'TIME4H_11';

defaultASs = [1 5 9 12];
defaultFasc = [48 42 41 40];

nMuscles = numel(muscles);
muscleElongation = cell(nMuscles, 1);
spindleActivation = cell(nMuscles, 1);
recruitmentCurve = cell(nMuscles, 1);
stimulationParameters = cell(nMuscles, 1);
ASs = arrayfun(@num2str, defaultASs(1:nMuscles), 'UniformOutput', false)';
targetFascicles = defaultFasc(1:nMuscles)';
for iMuscle = 1:nMuscles
    muscleElongation{iMuscle} = readtable(fullpaths{iMuscle});
    spindleActivation{iMuscle} = compute_spindle_activation(muscleElongation{iMuscle});
    
    %% Load recruitment curves from stored data
    % TODO allow loading custom recruitment curves as csv from data/recruitment-curves
    model = load_model(subject, electrode, ASs{iMuscle}, false);
    model.motorFasc = targetFascicles(iMuscle);
    model = select_fibers(model, []);  % Distribute Ia fibers randomly according to realistic distributions
    recruitmentCurve{iMuscle} = recruitment_curve_from_data(model);
    % Fit the recruitmentwith a logistic curve:
    recruitmentCurve{iMuscle} = logistic_recruitment_curve(recruitmentCurve{iMuscle}.Charge, recruitmentCurve{iMuscle}.Recruitment);

    stimulationParameters{iMuscle} = compute_stimulation_parameters(spindleActivation{iMuscle}, recruitmentCurve{iMuscle});
end

%% Plots
colors = lines(nMuscles);

figure;
tiledlayout(nMuscles, 1);
sgtitle('Recruitment curves');
for iMuscle = 1:nMuscles
    nexttile;
    title(muscles{iMuscle}, sprintf('Active Site %s - Fascicle %d', ASs{iMuscle}, targetFascicles(iMuscle)));
    hold on;
    plot(recruitmentCurve{iMuscle}.Charge, recruitmentCurve{iMuscle}.Recruitment, 'Color', colors(iMuscle, :));
    ylabel('Recruitment [%]');
    xlabel('Charge [nC]');
end

figure;
tiledlayout(4, 1, 'TileSpacing', 'tight');
nexttile;
title('Muscle Elongations');
hold on;
for iMuscle = 1:nMuscles
    plot(muscleElongation{iMuscle}.t, muscleElongation{iMuscle}.Elongation, 'Color', colors(iMuscle, :));
end
legend(muscles);
xlabel('t [s]');
ylabel('Elongation');

nexttile;
title('Spindles Activity');
hold on;
yyaxis left;
for iMuscle = 1:nMuscles
    h = plot(spindleActivation{iMuscle}.t, spindleActivation{iMuscle}.Recruitment, '-', 'Color', colors(iMuscle, :));
    if iMuscle == 1
        hRecr = h;
    end
end
ylabel('Recruitment [%]');
hold on;
yyaxis right;
for iMuscle = 1:nMuscles
    h = plot(spindleActivation{iMuscle}.t, spindleActivation{iMuscle}.FiringRate, '--', 'Color', colors(iMuscle, :));
    if iMuscle == 1
        hFR = h;
    end
end
ylabel('Firing Rate [Hz]');
xlabel('t [s]');
legend([hRecr hFR], {'Recruitment', 'Firing Rate'});
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';

nexttile;
title('Stimulation Charge');
hold on;
for iMuscle = 1:nMuscles
    plot(stimulationParameters{iMuscle}.t, stimulationParameters{iMuscle}.Charge, 'Color', colors(iMuscle, :));
end
ylabel('Charge [nC]');

nexttile;
title('Stimulation Frequency');
hold on;
for iMuscle = 1:nMuscles
    plot(stimulationParameters{iMuscle}.t, stimulationParameters{iMuscle}.Frequency, 'Color', colors(iMuscle, :));
end
ylabel('Frequency [Hz]');
xlabel('t [s]');
