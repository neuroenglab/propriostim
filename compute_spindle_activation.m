function spindleActivation = compute_spindle_activation(muscleState)
% Input:
% muscleState is a table with columns 't' [s], 'Elongation' [relative] and
% activation [normalized EMG]

% Output:
% spindleActivation is a table with columns 't' [s], 'Recruitment' [%], 
% and FiringRate [Hz]

% Creation of auxiliary variables
Elongation = muscleState.Elongation;
ElongationVel = diff(muscleState.Elongation)/...
    (muscleState.t(2) - muscleState.t(1));
% Compensating for missing value due to the differential
ElongationVel = [ElongationVel; ElongationVel(end)];
Activation = muscleState.Activation;

%% RECRUITMENT RATE obtained via interpolation from Botterman et al. 1982
% experimental data
SpindelsRecruitmentRate = [[0 15 25 40 50 65 100]/(100*2);
        [3 4 7 13 21 24 24]/24]';
    
muscle_elongation = zeros(size(Elongation));
muscle_elongation((Elongation)>=0) = Elongation(Elongation>=0,1);
recruitment_rate = interp1(SpindelsRecruitmentRate(:,1), ...
    SpindelsRecruitmentRate(:,2), muscle_elongation);

%% POPULATION FIRING RATE computed with the riparametrized prochazka model on human data

% baseline firing rate (Original value = 50)
mean_rate = 29.4390;
% Proportional constant for normalized muscle elongation input 
% (Original value = 200)
k_lm = 114.8011;
% Proportional constant for normalized muscle elongation velocity 
% input (Original value = 65)
k_vm = 25.8856;
% Expontial parameter for normalized muscle elongation velocity 
% input (Original value = 0.5)
e_vm = 0.3691;
% Proportional constant for normalized muscle EMG (Original value = 50)
k_emg = 50;

% Prochazka Model formulation mean firing rate
mean_firing_rate = mean_rate + k_lm * Elongation + ...
    k_vm .* sign(ElongationVel) .* abs(ElongationVel).^e_vm + ...
    k_emg * Activation;
mean_firing_rate(mean_firing_rate < 0 ) = 0;

% Population firing rate
firing_rate = mean_firing_rate .* recruitment_rate;

% Data output
t = muscleState.t;
Recruitment = recruitment_rate;
FiringRate = mean_firing_rate;
spindleActivation = table(t, Recruitment, FiringRate);

end