function model = load_model(subject, electrode, as, loadPotentials)
%LOAD_MODEL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    loadPotentials = false;
end

modelName = [subject '_' electrode];
modelNameAS = [modelName '_AS' as];

load(['data\Nerve\' subject '_noElectrode\Epineurium\epineurium.mat'], 'epi');
load(['data\Nerve\' modelName '\Fascicles\endoneuria_correct.mat'], 'endo_correct');
load(['data\Nerve\' modelName '\fascIdsByAs.mat'], 'fascIdsByAs');
load(['data\Electrode\' modelName '\electrodes.mat'], 'electrode', 'activeSites');
load(['data\Fibers\' modelName '\fibers.mat'], 'fibersPerFascicle');
if loadPotentials
    load(['data\Potential\' modelName '\potentials_' modelNameAS '.mat'], 'Vs', 'currentDensityAm2');
    referenceCurrent = currentDensityAm2 * 0.08e-3^2 * pi;
else
    nrnModel = 'MRG';  % TODO allow selection
    load(['data\Recruitment\' modelName '\' nrnModel '\recruitment_1_' modelNameAS '.mat'], 'fiberActive', 'deltaQnC', 'qMaxnC');
end

%fascIdsAllAs = find(any(fascIdsByAs));
iAS = str2double(as);
fascIds = find(fascIdsByAs(iAS,:));

% Filter out fibers unreached by active site
fibers = fibersPerFascicle(fascIds);
if loadPotentials
    model = Model.with_potentials(epi, endo_correct, electrode, activeSites, iAS, fascIds, fibers, Vs, referenceCurrent);
else
    model = Model(epi, endo_correct, electrode, activeSites, iAS, fascIds, fibers, 0:deltaQnC:qMaxnC, fiberActive, nrnModel);
end

end

