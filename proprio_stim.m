function proprio_stim(model, iPace)

load('data\ProprioSim\propriosim_output.mat', 'proprioSim_firing_rate', ...
    'proprioSim_recruitment_rate', 'knee_angle', 'knee_velocity');

period = [2 1.6 1.2];
t = linspace(0, period(iPace), size(proprioSim_recruitment_rate,1))';

recrIa = model.recruitment(model.motorFasc, model.IaFiberId);
recrIb = model.recruitment(model.motorFasc, model.IbFiberId);
recrAlpha = model.recruitment(model.motorFasc, model.AlphaFiberId);
recrII = model.recruitment(model.motorFasc, model.IIFiberId);
recrTouch = model.recruitment(model.touchFasc);

% TODO choose Lateral/Medial
[~, iStim] = min(abs(recrIa - proprioSim_recruitment_rate(:, 1, iPace)), [], 2);

figure;
tiledlayout('flow');

nexttile;
plot(t, knee_angle(:, iPace));
xlabel('t [s]');
title('Knee Angle');

nexttile;
plot(t, model.Q(iStim));
xlabel('t [s]');
title('Injected Charge');

nexttile;
plot(t, proprioSim_firing_rate(:, 1, iPace));
xlabel('t [s]');
title('Frequency');

nexttile;
hold on;
plot(t, recrIa(iStim), 'm', 'LineWidth', 1);
plot(t, recrIb(iStim), 'c', 'LineWidth', 1);
plot(t, recrAlpha(iStim), 'g', 'LineWidth', 1);
plot(t, recrII(iStim), 'y', 'LineWidth', 1);
plot(t, recrTouch(iStim), 'r', 'LineWidth', 1);
legend('Ia fibers', 'Ib fibers', 'Alpha motor fibers', 'II fibers', 'Touch fascicle');
xlabel('t [s]');
title('Recruitment');

% nexttile;
% plot(t, knee_velocity(:, iPace));
% title('Knee Velocity');

end