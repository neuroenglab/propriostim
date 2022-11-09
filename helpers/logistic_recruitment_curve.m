function recruitmentCurve = logistic_recruitment_curve(Q, recruitment)
errFun = @(k_x0) sum((logistic(k_x0(1), k_x0(2), Q) - recruitment).^2);
k_x0 = fminsearch(errFun, [1 1]);

Charge = linspace(0, 1/k_x0(1)*12)';
Recruitment = logistic(k_x0(1), k_x0(2), Charge);

[Recruitment, iUnique] = unique(Recruitment); % remove doubled points
Charge = Charge(iUnique);
recruitmentCurve = table(Charge, Recruitment);
end


function y = logistic(k, x0, x)
y0 = 1 ./ (1 + exp(-k.*(-x0))); % shift to go through origin
y = (1 ./ (1 + exp(-k.*(x - x0))) - y0)./(1 - y0);
end
