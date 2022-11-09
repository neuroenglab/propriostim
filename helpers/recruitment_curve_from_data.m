function recruitmentCurve = recruitment_curve_from_data(model)
fiberType = 'Ia';
Charge = model.Q';
Recruitment = model.recruitment_motor_by_type(fiberType)';

[Recruitment, iUnique] = unique(Recruitment); % remove doubled points
Charge = Charge(iUnique);
recruitmentCurve = table(Charge, Recruitment);
end

