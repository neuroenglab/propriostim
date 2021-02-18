function plot_recruitment(model, ax)

axes(ax);
cla();
hold on;

Q = model.Q;
l = {};
if model.motorFasc ~= 0
    recrMotor = model.recruitment(model.motorFasc);
    plot(Q, recrMotor*100, 'b', 'LineWidth', 1);
    l = [l {'Motor fascicle'}];
    if ~isempty(model.IaFiberId)
        plot(Q, model.recruitment(model.motorFasc, model.IaFiberId)*100, 'm', 'LineWidth', 1);
        plot(Q, model.recruitment(model.motorFasc, model.IbFiberId)*100, 'c', 'LineWidth', 1);
        plot(Q, model.recruitment(model.motorFasc, model.AlphaFiberId)*100, 'g', 'LineWidth', 1);
        l = [l {'Ia fibers', 'Ib fibers', 'Alpha Motor fibers'}];
    end
end
if model.refFasc ~= 0
    recrRef = model.recruitment(model.refFasc);
    plot(Q, recrRef*100, 'r', 'LineWidth', 1);
    l = [l {'Reference fascicle'}];
end

legend(l);

end
