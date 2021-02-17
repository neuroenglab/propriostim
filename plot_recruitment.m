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
if model.touchFasc ~= 0
    recrTouch = model.recruitment(model.touchFasc);
    plot(Q, recrTouch*100, 'r', 'LineWidth', 1);
    l = [l {'Touch fascicle'}];
end

legend(l);

end
