function model = load_model(subject, electrode, as)
%LOAD_MODEL Summary of this function goes here
%   Detailed explanation goes here

modelName = [subject '_' electrode];

load(['data\Nerve\' subject '_noElectrode\Epineurium\epineurium.mat'], 'epi');
load(['data\Nerve\' modelName '\Fascicles\endoneuria_correct.mat'], 'endo_correct');
load(['data\Nerve\' modelName '\fascIdsByAs.mat'], 'fascIdsByAs');
load(['data\Electrode\' modelName '\electrodes.mat'], 'electrode', 'activeSites');
load(['data\Recruitment\' modelName '\MRG\recruitment_1_' modelName '_AS' as '.mat'], 'fiberActive', 'deltaQnC', 'qMaxnC');
load(['data\Fibers\' modelName '\fibers.mat'], 'fibersPerFascicle');

%fascIdsAllAs = find(any(fascIdsByAs));
iAS = str2double(as);
fascIds = find(fascIdsByAs(iAS,:));

% Filter out fibers unreached by active site
fibersPerFascicle = fibersPerFascicle(fascIds);

model = struct('epi', {epi}, ...
               'endo', endo_correct, ...
               'electrode', electrode, ...
               'activeSites', activeSites, ...
               'iAS', iAS, ...
               'fascIds', fascIds, ...
               'fibers', {fibersPerFascicle}, ...
               'fiberActive', {fiberActive'});

end

