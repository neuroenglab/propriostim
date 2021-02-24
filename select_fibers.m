function model = select_fibers(model, clusterCenters, minDiamIFibers, minDiamIIFibers, numIaFibers, numIbFibers, numAlphaFibers, numIIFibers, numIIIFibers)
% If clusterCenters is empty, assign randomly

fibers = model.fibers{model.fascIds == model.motorFasc};

if nargin < 3
    minDiamIFibers = 12;
    minDiamIIFibers = 6;
end
[idIFibers, idIIFibers, idIIIFibers] = split_fibers(model, minDiamIFibers, minDiamIIFibers);

if nargin < 4
    [numIaFibers, numIbFibers, numAlphaFibers] = default_I_fibers_count(idIFibers);
    numIIFibers = numel(idIIFibers);
    numIIIFibers = numel(idIIIFibers);
end

model.fiberType = false(height(fibers), model.nFiberType);

model = model.set_fiber_type('II', idIIFibers(randperm(numel(idIIFibers), numIIFibers)));
model = model.set_fiber_type('III', idIIIFibers(randperm(numel(idIIIFibers), numIIIFibers)));

if isempty(clusterCenters)
    randIdPrimaryFibers = idIFibers(randperm(numel(idIFibers)));
    
    % Random disposition assignation
    model = model.set_fiber_type('Ia', randIdPrimaryFibers(1 : numIaFibers));
    model = model.set_fiber_type('Ib', randIdPrimaryFibers((1 : numIbFibers) + numIaFibers));
    model = model.set_fiber_type('Alpha Motor', randIdPrimaryFibers(numIaFibers + numIbFibers + 1 : numIaFibers + numIbFibers + numAlphaFibers));
else
    % extraction of fascicle fibers position
    centers = squeeze(fibers.center(idIFibers, 101, 1:2));
    
    % Extraction of Ia Fibers ID
    [~, order] = sort(pdist2(clusterCenters(1, :), centers, 'euclidean'));
    IdPopIaFibers = idIFibers(order(1:numIaFibers));
    
    % Update of remaining primary fibers
    idIFibers = setdiff(idIFibers, IdPopIaFibers);
    centers = squeeze(fibers.center(idIFibers, 101, 1:2));
    
    % Extraction of Ib Fibers
    [~, order] = sort(pdist2(clusterCenters(2, :), centers, 'euclidean'));
    IdPopIbFibers = idIFibers(order(1:numIbFibers));
    
    % Extraction of Alpha Fibers ID
    idIFibers = setdiff(idIFibers, IdPopIbFibers);
    IdPopAlphaFibers = idIFibers(randperm(numel(idIFibers), numAlphaFibers));
    
    % Disposition assignation
    model = model.set_fiber_type('Ia', IdPopIaFibers);
    model = model.set_fiber_type('Ib', IdPopIbFibers);
    model = model.set_fiber_type('Alpha Motor', IdPopAlphaFibers);
end

end
