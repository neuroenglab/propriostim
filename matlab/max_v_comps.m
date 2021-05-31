function [maxCompsV, varargout] = max_v_comps(compartsV, nNodesMax, nCompartsPerSect)
% MAX_V_COMPS  selects the voltage value of the node on or next to the
% highest voltage provided, together with as many compartments as possible
% up to the amount corresponding to the maximum number of nodes.
%   maxCompsV = MAX_V_COMPS(compsV, nNodMax, nSectComps) returns voltages
%   for as many nodes and corresponding internodal compartments as
%   possible, up to the maximum number of nodes specified, around the
%   highest voltage value

% number of compartment voltage values
nCompartsAvailable = length(compartsV);
% maximum number of compartments desired
nCompartsMax = (nNodesMax - 1) * nCompartsPerSect + 1;
% desired number of nodes to one side of the middle node
nSideComparts = (nCompartsMax - 1) / 2;
% index of compartment with highest voltage
[~, iMax] = max(compartsV);
% index of the node closest to the highest voltage value
iNodeAdjMax = round((iMax - 1) / nCompartsPerSect) * nCompartsPerSect + 1;

% default start node index
iStartNode = iNodeAdjMax - nSideComparts;
iEndNode = iNodeAdjMax + nSideComparts;

% if before the node closest to the maximum voltage value there are not
% enough voltage values to cover all allowed output values...
if iStartNode < 1
	% ... set the first node to the beginning
	iStartNode = 1;
	% ... set the end node accordingly
	iEndNode = nCompartsMax;
% ... else if there are not enough voltage values after the node ...
elseif iEndNode > nCompartsAvailable
	% ... set the last node to the end
	iEndNode = nCompartsAvailable;
	% ... shift the start node accordingly
	iStartNode = max(1, 1 + nCompartsAvailable - nCompartsMax);
end
% store the output value
maxCompsV = compartsV(iStartNode : iEndNode);
% if there aren't half the necessary indices available before the node ...

if nargout == 2
	varargout{1} = iStartNode : iEndNode;
end
end
