function stimulationParameters = compute_linear_encoding(jointKinematics, minCharge, maxCharge)
jointAngles = jointKinematics.Angle;
minAngle = min(jointAngles);
t = jointKinematics.t;
Charge = minCharge + (jointAngles - minAngle) ./ (max(jointAngles) - minAngle) * (maxCharge - minCharge);
Frequency = zeros(size(t)) + 50;  % Fixed at 50 Hz
stimulationParameters = table(t, Charge, Frequency);
end

