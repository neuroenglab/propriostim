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
fibers = fibersPerFascicle(fascIds);

model = Model(epi, endo_correct, electrode, activeSites, iAS, fascIds, fibers, 0:deltaQnC:qMaxnC, fiberActive);

end

