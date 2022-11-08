addpath('helpers');
movementsFolder = 'data/movements';

movements = list_subfolders(movementsFolder);

% Select movement
iMovement = listdlg('ListString', movements);

movementFolder = fullfile(movementsFolder, movements{iMovement});

[muscles, fullpaths] = list_csv(movementFolder);

fprintf('%d muscles found in the movement folder: %s\n', numel(muscles), strjoin(muscles, ', '));

nMuscles = numel(muscles);
muscleElongation = cell(nMuscles, 1);
spindleActivation = cell(nMuscles, 1);
recruitmentCurve = cell(nMuscles, 1);
stimulationParameters = cell(nMuscles, 1);
for iMuscle = 1:nMuscles
    muscleElongation{iMuscle} = readtable(fullpaths{iMuscle});
    spindleActivation{iMuscle} = compute_spindle_activation(muscleElongation{iMuscle});
    recruitmentCurve{iMuscle} = logistic_recruitment_curve(iMuscle*2, iMuscle*10); % random values...
    % TODO load recruitment curves as csv from data/recruitment-curves
    stimulationParameters{iMuscle} = compute_stimulation_parameters(spindleActivation{iMuscle}, recruitmentCurve{iMuscle});
end

figure;
tiledlayout(4, 1, 'TileSpacing', 'tight');
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
hold on;
title('Recruitment curve');
for iMuscle = 1:nMuscles
    plot(recruitmentCurve{iMuscle}.Charge, recruitmentCurve{iMuscle}.Recruitment);
end
legend(muscles);
ylabel('Recruitment [%]');
xlabel('Charge [nC]');

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
