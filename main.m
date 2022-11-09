addpath('helpers');
addpath('neuron-demo\matlab');
movementsFolder = 'data/movements';

movements = list_subfolders(movementsFolder);

% Select movement
iMovement = listdlg('ListString', movements);

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
ASs = arrayfun(@num2str, defaultASs(1:nMuscles), UniformOutput=false)';
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

figure;
hold on;
title('Recruitment curve');
for iMuscle = 1:nMuscles
    plot(recruitmentCurve{iMuscle}.Charge, recruitmentCurve{iMuscle}.Recruitment);
end
legend(muscles);
ylabel('Recruitment [%]');
xlabel('Charge [nC]');

figure;
tiledlayout(3, 1, 'TileSpacing', 'tight');
nexttile;
title('Muscle elongations');
hold on;
for iMuscle = 1:nMuscles
    plot(muscleElongation{iMuscle}.t, muscleElongation{iMuscle}.Elongation);
end
legend(muscles);
xlabel('t [s]');
ylabel('Elongation');

nexttile;
title('Spindles activity');
hold on;
yyaxis left;
for iMuscle = 1:nMuscles
    plot(spindleActivation{iMuscle}.t, spindleActivation{iMuscle}.Recruitment);
end
legend(muscles, "AutoUpdate", "off");
ylabel('Recruitment [%]');
hold on;
yyaxis right;
for iMuscle = 1:nMuscles
    plot(spindleActivation{iMuscle}.t, spindleActivation{iMuscle}.FiringRate);
end
ylabel('Firing Rate [Hz]');
xlabel('t [s]');

nexttile;
title('Stimulation parameters');
hold on;
yyaxis left;
for iMuscle = 1:nMuscles
    plot(stimulationParameters{iMuscle}.t, stimulationParameters{iMuscle}.Charge);
end
legend(muscles, "AutoUpdate", "off");
ylabel('Charge [nC]');
hold on;
yyaxis right;
for iMuscle = 1:nMuscles
    plot(stimulationParameters{iMuscle}.t, stimulationParameters{iMuscle}.Frequency);
end
ylabel('Frequency [Hz]');
xlabel('t [s]');
