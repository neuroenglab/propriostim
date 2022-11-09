function [fiberActive, deltaQnC, qMaxnC] = load_thresholds(modelName, AS)
modelNameAS = [modelName '_AS' AS];
nrnModel = 'MRG';
load(['data\Recruitment\' modelName '\' nrnModel '\recruitment_1_' modelNameAS '.mat'], 'fiberActive', 'deltaQnC', 'qMaxnC');
end

