function recruitmentCurve = logistic_recruitment_curve(threshold10, threshold90)
errFun = @(k_x0) abs(logistic(k_x0(1), k_x0(2), threshold10) - 0.1) + abs(logistic(k_x0(1), k_x0(2), threshold90) - 0.9);
k_x0 = fminsearch(errFun, [1 1]);

Charge = linspace(0, threshold90*2)';
Recruitment = logistic(k_x0(1), k_x0(2), Charge);

[Recruitment, iUnique] = unique(Recruitment); % remove doubled points
Charge = Charge(iUnique);
recruitmentCurve = table(Charge, Recruitment);
end


function y = logistic(k, x0, x)
y0 = 1 ./ (1 + exp(-k.*(-x0))); % shift to go through origin
y = (1 ./ (1 + exp(-k.*(x - x0))) - y0)./(1 - y0);
end
