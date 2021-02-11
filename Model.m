classdef Model
    properties
        epi,
        endo,
        electrode,
        activeSites,
        iAS,
        fascIds,
        fibers,
        fiberActive,
        motorFasc = 0,
        touchFasc = 0,
        IaFiberId,
        IbFiberId,
        AlphaFiberId
    end
    methods
        function obj = Model(epi, endo, electrode, activeSites, iAS, fascIds, fibers, fiberActive)
            obj.epi = epi;
            obj.endo = endo;
            obj.electrode = electrode;
            obj.activeSites = activeSites;
            obj.iAS = iAS;
            obj.fascIds = fascIds;
            obj.fibers = fibers;
            obj.fiberActive = fiberActive;
        end
    end
end