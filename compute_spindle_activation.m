function spindleActivation = compute_spindle_activation(muscleElongation)
% Input:
% muscleElongation is a table with columns 't' [s] and 'Elongation' [relative]

% Output:
% spindleActivation is a table with columns 't' [s], 'Recruitment' [%], and FiringRate [Hz]

% THIS IS A STUB
% TODO @Andrea implement
t = muscleElongation.t;
Recruitment = muscleElongation.Elongation+min(muscleElongation.Elongation);
FiringRate = muscleElongation.Elongation * 50;
spindleActivation = table(t, Recruitment, FiringRate);
end