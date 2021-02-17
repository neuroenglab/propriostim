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
    end
    
    methods(Static)
        function obj = with_potentials(epi, endo, electrode, activeSites, iAS, fascIds, fibers, V, referenceCurrent)
            obj = Model(epi, endo, electrode, activeSites, iAS, fascIds, fibers, [], cell(numel(fascIds), 1));
            obj.V = V;
            obj.referenceCurrent = referenceCurrent;
        end
    end
end