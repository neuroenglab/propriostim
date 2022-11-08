function stimulationParameters = compute_stimulation_parameters(spindleActivation, recruitmentCurve)
% Input:
% spindleActivation is a table with columns 't' [s], 'Recruitment' [%], and FiringRate [Hz]
% recruitmentCurve is a table with columns 'Charge' [nC] and 'Recruitment' [%]

% Output:
% stimulationParameters is a table with columns 't' [s], 'Charge' [nC], and 'Frequency' [Hz]

% Interpolate recruitment curve at desired recruitment levels
t = spindleActivation.t;
Charge = interp1(recruitmentCurve.Recruitment, recruitmentCurve.Charge, spindleActivation.Recruitment, 'pchip');
Frequency = spindleActivation.FiringRate;
stimulationParameters = table(t, Charge, Frequency);
end

