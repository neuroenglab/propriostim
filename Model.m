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
        nrnModel = '',
        motorFasc = 0,
        refFasc = 0,
        fiberType = logical.empty,  % logical iFiber x iFiberType
        fiberTypeName = {'Alpha Motor', 'Ia', 'Ib', 'II', 'III'},
        V,
        referenceCurrent  % [A]
    end
    
    methods
        function obj = Model(epi, endo, electrode, activeSites, iAS, fascIds, fibers, Q, fiberActive, nrnModel)
            obj.epi = epi;
            obj.endo = endo;
            obj.electrode = electrode;
            obj.activeSites = activeSites;
            obj.iAS = iAS;
            obj.fascIds = fascIds;
            obj.fibers = fibers;
            obj.Q = Q;
            obj.fiberActive = fiberActive;
            obj.nrnModel = nrnModel;
        end
        
        function recr = recruitment(obj, iFasc, fibersId)
            % fiberId can be linear or logical indexes
            currFiberActive = obj.fiberActive{obj.fascIds == iFasc};
            if nargin > 2
                currFiberActive = currFiberActive(fibersId);
            else
                currFiberActive = currFiberActive(~isnan(currFiberActive));
            end
            if numel(currFiberActive) == 1
                % Just a trick to have it treated as a column
                currFiberActive = [currFiberActive; currFiberActive];
            end
            recr = mean(currFiberActive > 0 & currFiberActive <= obj.Q);
        end
        
        function recr = recruitment_motor_by_type(obj, fiberType)
            if isletter(fiberType)
                fibersId = obj.get_fibers_by_type(fiberType);
            else
                fibersId = obj.fiberType(:, fiberType);
            end
            recr = obj.recruitment(obj.motorFasc, fibersId);
        end
        
        function iFasc = motorFascRel(obj)
            iFasc = find(obj.fascIds == obj.motorFasc, 1);
        end
        
        function fibersId = get_fibers_by_type(obj, fiberTypeName)
            iFiberType = obj.get_fiber_type_index(fiberTypeName);
            fibersId = obj.fiberType(:, iFiberType);
        end
        
        function obj = set_fiber_type(obj, fiberTypeName, fiberId)
            iFiberType = obj.get_fiber_type_index(fiberTypeName);
            obj.fiberType(:, iFiberType) = false;
            obj.fiberType(fiberId, iFiberType) = true;
        end
        
        function iFiberType = get_fiber_type_index(obj, fiberTypeName)
            iFiberType = find(strcmp(obj.fiberTypeName, fiberTypeName));
            assert(numel(iFiberType) == 1, 'Invalid fiber type');
        end
        
        function val = fiberTypeNameExt(obj, ind)
            if nargin > 1
                val = strcat(obj.fiberTypeName(ind), ' fibers');
            else
                val = strcat(obj.fiberTypeName, ' fibers');
            end
        end
        
        function val = nFiberType(obj)
            val = numel(obj.fiberTypeName);
        end
        
        function val = fiberTypeVector(obj)
            % Returns the fiber type as vector
            if any(sum(obj.fiberType, 2) > 1)
                warning('Some fibers are assigned more than one type, incoherent output.');
            end
            [t, val] = max(obj.fiberType, [], 2);
            if t == 0
                val = 0;
            end
        end
    end
    
    methods(Static)
        function obj = with_potentials(epi, endo, electrode, activeSites, iAS, fascIds, fibers, V, referenceCurrent)
            obj = Model(epi, endo, electrode, activeSites, iAS, fascIds, fibers, [], cell(numel(fascIds), 1), '');
            obj.V = V;
            obj.referenceCurrent = referenceCurrent;
        end
    end
end