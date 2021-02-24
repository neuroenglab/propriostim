function [idIFibers, idIIFibers, idIIIFibers] = split_fibers(model, minDiamIFibers, minDiamIIFibers)

% Extraction of primary and secondary fibers
idIFibers = model.fibers{model.motorFascRel}.r >= minDiamIFibers/2;
idIIIFibers = model.fibers{model.motorFascRel}.r < minDiamIIFibers/2;
idIIFibers = ~idIFibers & ~idIIIFibers;

idIFibers = find(idIFibers);
idIIFibers = find(idIIFibers);
idIIIFibers = find(idIIIFibers);

end

