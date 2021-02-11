function model = select_fibers(model, clusterCenters)
%SELECT_RANDOM_FIBERS Summary of this function goes here
%   Detailed explanation goes here

fibers = model.fibers{model.fascIds == model.motorFasc};

% Extraction of primary and secondary fibers
idPrimaryFibers = find(fibers.r >= 6);
numPrimaryFibers = numel(idPrimaryFibers);
model.IIFiberId = setdiff(1:numPrimaryFibers, idPrimaryFibers);

% Subpartition of primary fibers
numIaFibers = ceil(0.16 * numPrimaryFibers);
numIbFibers = ceil(0.12 * numPrimaryFibers);

if isempty(clusterCenters)
    randIdPrimaryFibers = idPrimaryFibers(randperm(numPrimaryFibers));
    
    % Random disposition assignation
    model.IaFiberId = randIdPrimaryFibers(1 : numIaFibers);
    model.IbFiberId = randIdPrimaryFibers((1 : numIbFibers) + numIaFibers);
    model.AlphaFiberId = randIdPrimaryFibers(numIaFibers + numIbFibers + 1 : end);
else    
    % extraction of fascicle fibers position
    centers = squeeze(fibers.center(idPrimaryFibers, 101, 1:2));
    
    % Extraction of Ia Fibers ID
    [~, order] = sort(pdist2(clusterCenters(1, :), centers, 'euclidean'));
    IdPopIaFibers = idPrimaryFibers(order(1:numIaFibers));
    
    % Update of remaining primary fibers
    idPrimaryFibers = setdiff(idPrimaryFibers, IdPopIaFibers);
    centers = squeeze(fibers.center(idPrimaryFibers, 101, 1:2));
    
    % Extraction of Ib Fibers
    [~, order] = sort(pdist2(clusterCenters(2, :), centers, 'euclidean'));
    IdPopIbFibers = idPrimaryFibers(order(1:numIbFibers));
    
    % Extraction of Alpha Fibers ID
    IdPopAlphaFibers = setdiff(idPrimaryFibers, IdPopIbFibers);
    
    % Disposition assignation
    model.IaFiberId = IdPopIaFibers;
    model.IbFiberId = IdPopIbFibers;
    model.AlphaFiberId = IdPopAlphaFibers;
end

end
