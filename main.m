addpath('helpers');
addpath('neuron-demo\matlab');
movementsFolder = 'data/movements';

movements = list_subfolders(movementsFolder);

% Select movement
iMovement = listdlg('ListString', movements, 'SelectionMode', 'single');

movement = movements{iMovement};

movementFolder = fullfile(movementsFolder, movement);

%% Load kinematics
[joints, jointPaths] = list_csv(fullfile(movementFolder, 'kinematics'));
nJoints = numel(joints);
jointKinematics = cell(nJoints, 1);
for iJoint = 1:nJoints
    jointKinematics{iJoint} = readtable(jointPaths{iJoint});
    % To rename columns of tables saved in old format:
    %jointAngles{iJoint} = renamevars(jointAngles{iJoint}, joints{iJoint}, 'Angle');
    %writetable(jointAngles{iJoint}, jointPaths{iJoint});
end
joints = cellfun(@(s) replace([upper(s(1)) s(2:end)], '_', ' '), joints, 'UniformOutput', false);

%% Load muscle elongations
[muscles, fullpaths] = list_csv(movementFolder);
muscles = cellfun(@(s) replace([upper(s(1)) s(2:end)], '_', ' '), muscles, 'UniformOutput', false);

fprintf('%d muscles found in the movement folder: %s\n', numel(muscles), strjoin(muscles, ', '));

subject = 'Subject1';
electrode = 'TIME4H_11';

defaultASs = [1 5 9 12];
defaultFasc = [48 42 41 40];

nMuscles = numel(muscles);
muscleElongation = cell(nMuscles, 1);
spindleActivation = cell(nMuscles, 1);
recruitmentCurve = cell(nMuscles, 1);
psStimulationParameters = cell(nMuscles, 1);
linearStimulationParameters = cell(nMuscles, 1);
ASs = arrayfun(@num2str, defaultASs(1:nMuscles), 'UniformOutput', false)';
targetFascicles = defaultFasc(1:nMuscles)';
for iMuscle = 1:nMuscles
    %% Load recruitment curves from stored data
    % TODO allow loading custom recruitment curves as csv from data/recruitment-curves
    model = load_model(subject, electrode, ASs{iMuscle}, false);
    model.motorFasc = targetFascicles(iMuscle);
    model = select_fibers(model, []);  % Distribute Ia fibers randomly according to realistic distributions
    recruitmentCurve{iMuscle} = recruitment_curve_from_data(model);
    % Fit the recruitmentwith a logistic curve:
    recruitmentCurve{iMuscle} = logistic_recruitment_curve(recruitmentCurve{iMuscle}.Charge, recruitmentCurve{iMuscle}.Recruitment);
    
    %% Compute ProprioStim encoding
    muscleElongation{iMuscle} = readtable(fullpaths{iMuscle});
    spindleActivation{iMuscle} = compute_spindle_activation(muscleElongation{iMuscle});
    psStimulationParameters{iMuscle} = compute_stimulation_parameters(spindleActivation{iMuscle}, recruitmentCurve{iMuscle});

    %% Compute linear encoding
    % Linear charge encoding between 10% and 90% recruitment
    chargeRange = interp1(recruitmentCurve{iMuscle}.Recruitment, recruitmentCurve{iMuscle}.Charge, [0.1 0.9]);
    linearStimulationParameters{iMuscle} = compute_linear_encoding(jointKinematics{strcmp(joints, 'Knee')}, chargeRange(1), chargeRange(2));
end

%% Recruitment Plots
colors = lines(nMuscles + nJoints);
mColors = colors(1:nMuscles, :);
jColors = colors(nMuscles+1:end, :);

figure;
tiledlayout(nMuscles, 1);
sgtitle('Recruitment curves');
for iMuscle = 1:nMuscles
    nexttile;
    title(muscles{iMuscle}, sprintf('Active Site %s - Fascicle %d', ASs{iMuscle}, targetFascicles(iMuscle)));
    hold on;
    plot(recruitmentCurve{iMuscle}.Charge, recruitmentCurve{iMuscle}.Recruitment, 'Color', mColors(iMuscle, :));
    ylabel('Recruitment [%]');
    xlabel('Charge [nC]');
end

%% Linear Encoding Plots
figure;
tiledlayout(3, 1, 'TileSpacing', 'tight');
sgtitle([movement ' - Linear Encoding']);

nexttile;
title('Joint Kinematics');
hold on;
for iJoint = 1:nJoints
    plot(jointKinematics{iJoint}.t, jointKinematics{iJoint}.Angle, 'Color', jColors(iJoint, :));
end
legend(joints);
ylabel('Angle [°]');

nexttile;
title('Stimulation Charge');
hold on;
for iMuscle = 1:nMuscles
    plot(linearStimulationParameters{iMuscle}.t, linearStimulationParameters{iMuscle}.Charge, 'Color', mColors(iMuscle, :));
end
ylabel('Charge [nC]');

nexttile;
title('Stimulation Frequency');
hold on;
for iMuscle = 1:nMuscles
    plot(linearStimulationParameters{iMuscle}.t, linearStimulationParameters{iMuscle}.Frequency, 'Color', mColors(iMuscle, :));
end
ylabel('Frequency [Hz]');
xlabel('t [s]');

%% ProprioStim Plots
figure;
tiledlayout(5, 1, 'TileSpacing', 'tight');
sgtitle([movement ' - ProprioStim']);

nexttile;
title('Joint Kinematics');
hold on;
for iJoint = 1:nJoints
    plot(jointKinematics{iJoint}.t, jointKinematics{iJoint}.Angle, 'Color', jColors(iJoint, :));
end
legend(joints);
ylabel('Angle [°]');

nexttile;
title('Muscle Elongations');
hold on;
for iMuscle = 1:nMuscles
    plot(muscleElongation{iMuscle}.t, muscleElongation{iMuscle}.Elongation, 'Color', mColors(iMuscle, :));
end
legend(muscles);
ylabel('Elongation');

nexttile;
title('Spindles Activity');
hold on;
yyaxis left;
for iMuscle = 1:nMuscles
    h = plot(spindleActivation{iMuscle}.t, spindleActivation{iMuscle}.Recruitment, '-', 'Color', mColors(iMuscle, :));
    if iMuscle == 1
        hRecr = h;
    end
end
ylabel('Recruitment [%]');
hold on;
yyaxis right;
for iMuscle = 1:nMuscles
    h = plot(spindleActivation{iMuscle}.t, spindleActivation{iMuscle}.FiringRate, '--', 'Color', mColors(iMuscle, :));
    if iMuscle == 1
        hFR = h;
    end
end
ylabel('Firing Rate [Hz]');
legend([hRecr hFR], {'Recruitment', 'Firing Rate'});
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';

nexttile;
title('Stimulation Charge');
hold on;
for iMuscle = 1:nMuscles
    plot(psStimulationParameters{iMuscle}.t, psStimulationParameters{iMuscle}.Charge, 'Color', mColors(iMuscle, :));
end
ylabel('Charge [nC]');

nexttile;
title('Stimulation Frequency');
hold on;
for iMuscle = 1:nMuscles
    plot(psStimulationParameters{iMuscle}.t, psStimulationParameters{iMuscle}.Frequency, 'Color', mColors(iMuscle, :));
end
ylabel('Frequency [Hz]');
xlabel('t [s]');
