function plot_recruitment(model, ax)
%PLOT_RECRUITMENT Summary of this function goes here
%   Detailed explanation goes here

axes(ax);
cla();
hold on;

Q = 0:0.1:120;
l = {};
if model.motorFasc ~= 0
    recrMotor = compute_recruitment_curve(Q, model.fiberActive{model.fascIds == model.motorFasc});
    plot(Q, recrMotor*100, 'b', 'LineWidth', 1);
    l = [l {'Motor'}];
end
if model.touchFasc ~= 0
    recrTouch = compute_recruitment_curve(Q, model.fiberActive{model.fascIds == model.touchFasc});
    plot(Q, recrTouch*100, 'r', 'LineWidth', 1);
    l = [l {'Touch'}];
end

legend(l);

end

function recr = compute_recruitment_curve(Q, fiberActive)

recr = mean(fiberActive > 0 & fiberActive <= Q);

end
