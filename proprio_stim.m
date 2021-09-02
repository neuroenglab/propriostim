function proprio_stim(model, iPace, iMuscle, interpolate)
% Run without arguments to select model and parameters via GUI.
% iMuscle = 1 for medial, = 2 for lateral
addpath('matlab');

if nargin == 0
    model = view_run();
    iPace = listdlg('ListString', list_pace(), 'SelectionMode', 'single');
    iMuscle = select_muscle_dlg();
    interpolate = true;
end

load('data\ProprioSim\propriosim_output.mat', 'proprioSim_firing_rate', ...
    'proprioSim_recruitment_rate', 'knee_angle', 'knee_velocity');

period = [2 1.6 1.2];
t = linspace(0, period(iPace), size(proprioSim_recruitment_rate,1))';

recr = zeros(numel(model.Q), model.nFiberType);
iIa = model.get_fiber_type_index('Ia');
for iFiberType = 1:model.nFiberType
    recr(:, iFiberType) = model.recruitment_motor_by_type(iFiberType);
end
if model.refFasc
    recrRef = model.recruitment(model.refFasc);
end

if interpolate
    Q = interp1(recr(:, iIa) + cumsum(zeros(size(recr(:, iIa))) + eps), model.Q, proprioSim_recruitment_rate(:, iMuscle, iPace));
else
    [~, iStim] = min(abs(recr(:, iIa)' - proprioSim_recruitment_rate(:, iMuscle, iPace)), [], 2);
    Q = model.Q(iStim);
end

figure;
tiledlayout('flow');

nexttile;
plot(t, knee_angle(:, iPace));
xlabel('t [s]');
ylabel('Angle [°]');
title('Knee Angle');

nexttile;
plot(t, Q);
xlabel('t [s]');
ylabel('Q [nC]');
title('Injected Charge');

nexttile;
plot(t, proprioSim_firing_rate(:, iMuscle, iPace));
xlabel('t [s]');
ylabel('f [Hz]');
title('Stimulation Frequency');

nexttile;
hold on;
box on;
colors = hsv(model.nFiberType);
for iFiberType = 1:model.nFiberType
    if interpolate
        r = interp1(model.Q, recr(:, iFiberType), Q);
    else
        r = recr(iStim, iFiberType);
    end
    plot(t, r*100, 'Color', colors(iFiberType, :), 'LineWidth', 1);
end
if model.refFasc
    if interpolate
        r = interp1(model.Q, recrRef, Q);
    else
        r = recrRef(iStim);
    end
    plot(t, r*100, '--r', 'LineWidth', 1);
    l = legend([model.fiberTypeName {'Reference fascicle'}]);
else
    l = legend(model.fiberTypeName);
end
l.Location = 'EastOutside';
xlabel('t [s]');
ylabel('Recruitment');
ytickformat percentage;
title('Recruitment');

% nexttile;
% plot(t, knee_velocity(:, iPace));
% title('Knee Velocity');

end