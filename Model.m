classdef Model
    properties
        epi,
        endo,
        electrode,
        activeSites,
        iAS,
        fascIds,
        fibers,
        Q,
        fiberActive,
        motorFasc = 0,
        touchFasc = 0,
        IaFiberId,
        IbFiberId,
        AlphaFiberId,
        IIFiberId,
        V,
        referenceCurrent  % [A]
    end
    
    methods
        function obj = Model(epi, endo, electrode, activeSites, iAS, fascIds, fibers, Q, fiberActive)
            obj.epi = epi;
            obj.endo = endo;
            obj.electrode = electrode;
            obj.activeSites = activeSites;
            obj.iAS = iAS;
            obj.fascIds = fascIds;
            obj.fibers = fibers;
            obj.Q = Q;
            obj.fiberActive = fiberActive;
        end
        
        function recr = recruitment(obj, iFasc, fiberId)
            currFiberActive = obj.fiberActive{obj.fascIds == iFasc};
            if nargin > 2
                currFiberActive = currFiberActive(fiberId);
            end
            recr = mean(currFiberActive > 0 & currFiberActive <= obj.Q);
        end
        
        function view(obj, ax)
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
            idCrosses = 1:idCrossStep:size(obj.endo.data,2);
            for idFascicle = 1:size(obj.endo.data,1)
                for idCross = idCrosses
                    branches = obj.endo.data{idFascicle, idCross};
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
                    plot3(obj.epi{idCross}(:,1), obj.epi{idCross}(:,2), obj.epi{idCross}(:,3), 'Color', [0.7 0.7 0.7]);
                end
            end
            
            for idCross = 1:numel(obj.electrode)
                if obj.electrode(idCross).NumRegions > 0
                    elec_regions = regions(obj.electrode(idCross));
                    for idElReg = 1 : numel(elec_regions)
                        plot3(elec_regions(idElReg).Vertices([1:end,1],1), ...
                            elec_regions(idElReg).Vertices([1:end,1],2), ...
                            repmat(obj.epi{idCross}(1,3), [length(elec_regions( ...
                            idElReg).Vertices([1:end,1], 1)) 1]), 'm');
                    end
                end
            end
            as = obj.activeSites(obj.iAS).coord;
            plot3(as(1), as(2),as(3),'xr', 'LineWidth', 3);
            
            % Plot fibers
            maxCurr = max(cellfun(@max, obj.fiberActive));
            caxis([0 maxCurr]);
            cvalues = linspace(0, maxCurr, size(cmap,1));
            for idFascicle = 1:numel(obj.fascIds)
                activationCurr = obj.fiberActive{idFascicle};
                act = activationCurr > 0;
                colors = zeros(numel(activationCurr), 3);
                colors(act, :) = interp1(cvalues, cmap, activationCurr(act));
                for idFiber = 1:height(obj.fibers{idFascicle})
                    centers = obj.fibers{idFascicle}.center(idFiber, idCrosses, :);
                    plot3(centers(:, :, 1), centers(:, :, 2), centers(:, :, 3), 'Color', colors(idFiber, :));
                end
            end
            hold off;
            axis off;
            view(3);
        end
    end
    
    methods(Static)
        function obj = with_potentials(epi, endo, electrode, activeSites, iAS, fascIds, fibers, V, referenceCurrent)
            obj = Model(epi, endo, electrode, activeSites, iAS, fascIds, fibers, [], cell(numel(fascIds), 1));
            obj.V = V;
            obj.referenceCurrent = referenceCurrent;
        end
    end
end