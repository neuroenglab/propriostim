function plot_cross_section(model, ax, fascClickCallback)
%LOAD_CROSS_SECTION Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    fascClickCallback = @(~, ~) [];
end

% Choose z closest to the active site
z = model.activeSites(model.iAS).coord(3);
zs = cellfun(@(x) x(1,3), model.epi);
[~, iCross] = min(abs(zs - z));

hLegend = [];
textLegend = {};

%iCross = ceil(numel(model.epi)/2);
epi = model.epi{iCross};
elec = model.electrode(:, iCross);

axes(ax);
cla(ax);

% Plot epi
patch(epi(:,1), epi(:,2),[0.9 0.9 0.9]);

% Plot endo
endoColor = [0.7 0.7 0.7];
for iFasc = 1:size(model.endo.data, 1)
    branches = model.endo.data{iFasc, iCross};
    for idBranch = 1 : numel(branches)
        patch(branches{idBranch}(:,1), branches{idBranch}(:,2), endoColor, 'UserData', iFasc, 'ButtonDownFcn', fascClickCallback);
    end
end

% oldunits = get(gca, 'Units');
% set(gca, 'Units', 'points');
% pos = get(gca, 'Position');    %[X Y width height]
% xl = xlim();
% set(gca, 'Units', oldunits');
% pointsPerDataUnit = pos(3) / (xl(2) - xl(1));

% Plot fibers
for iFasc = 1:numel(model.fiberActive)
    % N.B. fibers are plotted at a fixed radius
    fibers = model.fibers{iFasc};
    activationCurr = model.fiberActive{iFasc};
    act = activationCurr > 0;
    x = fibers.center(:,iCross,1);
    y = fibers.center(:,iCross,2);
    %sz = pi*(fibers.r/pointsPerDataUnit.^2);  % ISSUE works in points, not data units
    % Plot inactive fibers in black
    scatter(x(~act), y(~act), 4, 'k', 'filled', 'PickableParts', 'none', 'HitTest', false);
    % Plot active fibers with current thresh. mapped to color
    scatter(x(act), y(act), 4, activationCurr(act), 'filled', 'PickableParts', 'none', 'HitTest', false);
    if ~isempty(model.IaFiberId) && (iFasc == find(model.motorFasc == model.fascIds))
        hAlpha = scatter(x(model.AlphaFiberId), y(model.AlphaFiberId), 4, 'xg', 'PickableParts', 'none', 'HitTest', false);
        hIa = scatter(x(model.IaFiberId), y(model.IaFiberId), 4, 'xm', 'PickableParts', 'none', 'HitTest', false);
        hIb = scatter(x(model.IbFiberId), y(model.IbFiberId), 4, 'xc', 'PickableParts', 'none', 'HitTest', false);
        hLegend = [hLegend hIa hIb hAlpha];
        textLegend = [textLegend {'Ia fibers', 'Ib fibers', 'Alpha motor fibers'}];
    end
end

% Mark edge of selected fascicles
motorColor = [0 0 1];
refColor = [1 0 0];
if model.refFasc ~= 0
    branches = model.endo.data{model.refFasc, iCross};
    for idBranch = 1 : numel(branches)
        h = plot(branches{idBranch}(:,1), branches{idBranch}(:,2), 'Color', refColor, 'LineWidth', 2);
    end
    hLegend = [h hLegend];
    textLegend = [{'Reference fascicle'} textLegend];
end
if model.motorFasc ~= 0
    branches = model.endo.data{model.motorFasc, iCross};
    for idBranch = 1 : numel(branches)
        h = plot(branches{idBranch}(:,1), branches{idBranch}(:,2), 'Color', motorColor, 'LineWidth', 2);
    end
    hLegend = [h hLegend];
    textLegend = [{'Motor fascicle'} textLegend];
end

% Plot electrode
plot(elec, 'FaceColor', [0.4 0.8 0.7]);

% Plot active site position
xy = model.activeSites(model.iAS).coord(1:2);
plot(xy(1), xy(2),'or', 'LineWidth', 3)

if numel(hLegend) > 0
    legend(hLegend, textLegend, 'AutoUpdate', false);
else
    legend off;
end

end
