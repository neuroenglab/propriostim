function proprio_stim(model, iPace)

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

% TODO choose Lateral/Medial
[~, iStim] = min(abs(recr(:, iIa)' - proprioSim_recruitment_rate(:, 1, iPace)), [], 2);

figure;
tiledlayout('flow');

nexttile;
plot(t, knee_angle(:, iPace));
xlabel('t [s]');
ylabel('Angle [°]');
title('Knee Angle');

nexttile;
plot(t, model.Q(iStim));
xlabel('t [s]');
ylabel('Q [nC]');
title('Injected Charge');

nexttile;
plot(t, proprioSim_firing_rate(:, 1, iPace));
xlabel('t [s]');
ylabel('f [Hz]');
title('Stimulation Frequency');

nexttile;
hold on;
box on;
colors = hsv(model.nFiberType);
for iFiberType = 1:model.nFiberType
    plot(t, recr(iStim, iFiberType)*100, 'Color', colors(iFiberType, :), 'LineWidth', 1);
end
if model.refFasc
    plot(t, recrRef(iStim)*100, '--r', 'LineWidth', 1);
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