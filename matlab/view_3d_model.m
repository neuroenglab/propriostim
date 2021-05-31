function view_3d_model(model, ax)
if nargin < 2
    figure;
    ax = gca();
else
    axes(ax);
end
hold on;
axis equal;
ax.Clipping = 'off';
cmap = colormap(ax, flipud(parula));
c = colorbar(ax);
c.Label.String = 'Charge threshold [nC]';
idCrossStep = 5;  % Plot z-resolution, change at will
idCrosses = 1:idCrossStep:size(model.endo.data,2);
for idFascicle = 1:size(model.endo.data,1)
    for idCross = idCrosses
        branches = model.endo.data{idFascicle, idCross};
        for idBranch = 1 : numel(branches)
            % Split by NaN (if holes are present)
            delimiters = [0; find(isnan(branches{idBranch}(:,1))); size(branches{idBranch},1)+1];
            for iDelimiter = 2:numel(delimiters)
                idx1 = delimiters(iDelimiter-1)+1;
                idx2 = delimiters(iDelimiter)-1;
                idxs = [idx1:idx2, idx1];
                plot3(branches{idBranch}(idxs,1), ...
                    branches{idBranch}(idxs,2), ...
                    branches{idBranch}(idxs,3), 'Color', [0.4 0.4 0.4]);
            end
        end
        plot3(model.epi{idCross}(:,1), model.epi{idCross}(:,2), model.epi{idCross}(:,3), 'Color', [0.7 0.7 0.7]);
    end
end

for idCross = 1:numel(model.electrode)
    if model.electrode(idCross).NumRegions > 0
        elec_regions = regions(model.electrode(idCross));
        for idElReg = 1 : numel(elec_regions)
            plot3(elec_regions(idElReg).Vertices([1:end,1],1), ...
                elec_regions(idElReg).Vertices([1:end,1],2), ...
                repmat(model.epi{idCross}(1,3), [length(elec_regions( ...
                idElReg).Vertices([1:end,1], 1)) 1]), 'm');
        end
    end
end
as = model.activeSites(model.iAS).coord;
plot3(as(1), as(2),as(3),'xr', 'LineWidth', 3);

% Plot fibers
maxCurr = max(cellfun(@max, model.fiberActive));
caxis([0 maxCurr]);
cvalues = linspace(0, maxCurr, size(cmap,1));
fiberViewRatio = 10;
for idFascicle = 1:numel(model.fascIds)
    activationCurr = model.fiberActive{idFascicle};
    act = activationCurr > 0;
    colors = zeros(numel(activationCurr), 3);
    colors(act, :) = interp1(cvalues, cmap, activationCurr(act));
    nFibers = height(model.fibers{idFascicle});
    fiberIds = randperm(nFibers, ceil(nFibers/fiberViewRatio));
    for idFiber = 1:height(model.fibers{idFascicle})
        centers = model.fibers{idFascicle}.center(idFiber, idCrosses, :);
        plot3(centers(:, :, 1), centers(:, :, 2), centers(:, :, 3), 'Color', colors(idFiber, :));
    end
end
hold off;
axis off;
view(3);
title(sprintf('1/%dth of fibers, 1/%dth of slices represented', fiberViewRatio, idCrossStep));
end
