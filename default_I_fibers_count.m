function [numIaFibers, numIbFibers, numAlphaFibers] = default_I_fibers_count(idIFibers)

numPrimaryFibers = numel(idIFibers);

% Subpartition of primary fibers
numIaFibers = ceil(0.16 * numPrimaryFibers);
numIbFibers = ceil(0.12 * numPrimaryFibers);
numAlphaFibers = numPrimaryFibers - numIaFibers - numIbFibers;

end

