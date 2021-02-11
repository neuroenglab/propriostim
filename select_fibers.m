function model = select_fibers(model, clusterCenter)
%SELECT_RANDOM_FIBERS Summary of this function goes here
%   Detailed explanation goes here

fibers = model.fibers{model.fascIds == model.motorFasc};

% Extraction of primary fibers
idPrimaryFibers = find(fibers.r >= 6);
numPrimaryFibers = numel(idPrimaryFibers);
% Subpartition of primary fibers
numIaFibers = ceil(0.16 * numPrimaryFibers);
numIbFibers = ceil(0.12 * numPrimaryFibers);

if isempty(clusterCenter)
    randIdPrimaryFibers = idPrimaryFibers(randperm(numPrimaryFibers));
    
    % Random disposition assignation
    model.IaFiberId = randIdPrimaryFibers(1 : numIaFibers);
    model.IbFiberId = randIdPrimaryFibers((1 : numIbFibers) + numIaFibers);
    model.AlphaFiberId = randIdPrimaryFibers(numIaFibers + numIbFibers + 1 : end);
else
    % Subpartition of primary fibers
    PopSeedIaFibers(iFasc, iDisp)  = randi(numPrimaryFibers, 1);
    PopSeedIbFibers(iFasc, iDisp) = randi(numPrimaryFibers - ...
        numIaFibers, 1);
    idPrimaryFibers = find(fibersCompart{iFasc}.r >= 6);
    % extraction of fascicle fibers position
    centers = squeeze(fibersCompart{iFasc}.center( ...
        idPrimaryFibers, 101, 1:2));
    numPrimaryFibers = size(centers, 1);
    % Extraction of Ia Fibers ID
    IdPopIaFibers = PopSeedIaFibers(iFasc, iDisp);
    [~, order] = sort(pdist2(centers(IdPopIaFibers, :), ...
        centers, 'euclidean'));
    IdPopIaFibers = idPrimaryFibers(order(1:numIaFibers));
    % Update of remaining primary fibers
    idPrimaryFibers = setdiff(idPrimaryFibers, IdPopIaFibers);
    centers = squeeze(fibersCompart{iFasc}.center( ...
        idPrimaryFibers, 101, 1:2));
    % Extraction of Ib Fibers
    IdPopIbFibers = PopSeedIbFibers(iFasc, iDisp);
    [~, order] = sort(pdist2(centers(IdPopIbFibers, :), ...
        centers, 'euclidean'));
    IdPopIbFibers = idPrimaryFibers(order(1:numIbFibers));
    % Extraction of Alpha Fibers ID
    IdPopAlphaFibers = setdiff(idPrimaryFibers, IdPopIbFibers);
    
    % Disposition assignation
    populations_primary_motor.IaFiberId{iFasc, ...
        iDisp} = IdPopIaFibers;
    populations_primary_motor.IbFiberId{iFasc, ...
        iDisp} = IdPopIbFibers;
    populations_primary_motor.AlphaFiberId{iFasc, ...
        iDisp} = IdPopAlphaFibers;
end

end
