function fibThreshold = find_threshold(fibId, rFib, fiberV, nrnModel, config, MRG_coeff)

switch nrnModel
    case 'Gaines/Motor'
        dirModel = 'neuron-demo\neuron\Gaines\';
        hocName = 'motor.hoc';
    case 'Gaines/Sensory'
        dirModel = 'neuron-demo\neuron\Gaines\';
        hocName = 'sensory.hoc';
    case 'MRG'
        dirModel = 'neuron-demo\neuron\MRG\';
        hocName = 'MRGaxon.hoc';
    otherwise
        error('nrnModel invalid');
end

[compartSelectedV, nNodeSelected] = select_v_comparts(fiberV, config.nbNod, 11);
if any(isnan(compartSelectedV))
    warning('%d NaN potentials in fiber %d', sum(isnan(compartSelectedV)), fibId);
    fiberV = fillmissing(fiberV, 'spline');
    [compartSelectedV, nNodeSelected] = select_v_comparts(fiberV, config.nbNod, 11);
end

nrnArgStr = make_param_str_argvec(rFib, MRG_coeff, config.stimStart, config.stimDur, ...
    nNodeSelected, compartSelectedV);

sysNrnCall = sprintf(['cd /d "%s" & %s\\nrniv.exe -nobanner -nopython "..\\init.hoc" ' ...
    '-c set_model_params(%s) -c a=load_file(\\"%s\\") -c FindThreshold(%f,%f) -c quit()'], ...
    dirModel, config.nrnBin, nrnArgStr, hocName, config.deltaQnC, config.qMaxnC);
[status, cmdout] = system(sysNrnCall);

fibThreshold = str2double(cmdout);
if status ~= 0 || isnan(fibThreshold)
    error('Neuron Error encountered in fiber %d:\n%s\n', fibId, cmdout);
end

end

function [compartSelectedV, nNodeSelected] = select_v_comparts(V, nNodesMax, nComparts)
% if there are more voltage values than allowed compartments ...
nNodesAvailable = (length(V) - 1) / nComparts + 1;
if nNodesAvailable > nNodesMax
    compartSelectedV = max_v_comps(V, nNodesMax, nComparts);
    nNodeSelected = nNodesMax;
else
    compartSelectedV = V;
    nNodeSelected = nNodesAvailable;
end
end

function nrnArgStr = make_param_str_argvec(rFib, MRG_coeff, start, stimDur, ...
    nNodeSelected, compartSelectedV)
% Saves MRG model parameters to file (for NEURON)

% Diameter for the fiber
D = 2 * rFib;
% Don't forget that nodeL and paraL1 are constant ;)
nodeD = polyval(MRG_coeff.nodeDC, D);		 % node diameter
paraD1 = polyval(MRG_coeff.paraD1C, D);	   % MYSA diameter (equal to node)
paraD2 = polyval(MRG_coeff.paraD2C, D);	   % FLUT diameter
interD = polyval(MRG_coeff.interDC, D);	   % STIN diameter (equal to FLUT)

nnL = polyval(MRG_coeff.nnLC, D);					 % internodal length
nodeL = MRG_coeff.nodeL;							  % node length
paraL1 = MRG_coeff.paraL1;							% MYSA length
paraL2 = polyval(MRG_coeff.paraL2C, D);			   % FLUT length
interL = (nnL-nodeL-(2*paraL1)-(2*paraL2))/6;   % SLIT length (one seg)

nbLam = polyval(MRG_coeff.nbLamC, D);		 % number of myelin lamella

nrnArgStr = [sprintf('%.10g,', D, start, stimDur, nNodeSelected, ...
    nodeD, paraD1, paraD2, interD, nnL, nodeL, paraL1, paraL2, interL, nbLam, ...
    compartSelectedV(1:end-1)) sprintf('%.10g', compartSelectedV(end))];
end
