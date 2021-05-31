function plot_recruitment(model, ax)

axes(ax);
cla();
hold on;

colors = hsv(model.nFiberType);
Q = model.Q;
l = {};
if model.motorFasc ~= 0
    recrMotor = model.recruitment(model.motorFasc);
    plot(Q, recrMotor*100, '--b', 'LineWidth', 1);
    l = [l {'Motor fascicle'}];
end
if model.refFasc ~= 0
    recrRef = model.recruitment(model.refFasc);
    plot(Q, recrRef*100, '--r', 'LineWidth', 1);
    l = [l {'Reference fascicle'}];
end
if model.motorFasc ~= 0
    if ~isempty(model.fiberType)
        fiberTypes = find(any(model.fiberType));
        for iFiberType = fiberTypes
            plot(Q, model.recruitment_motor_by_type(iFiberType)*100, 'Color', colors(iFiberType, :), 'LineWidth', 1);
        end
        l = [l model.fiberTypeNameExt(fiberTypes)];
    end
end
legend(l);

end
