function plot_cross_section(model, ax)
%LOAD_CROSS_SECTION Summary of this function goes here
%   Detailed explanation goes here

% Choose z closest to the active site
z = model.activeSites(model.iAS).coord(3);
zs = cellfun(@(x) x(1,3), model.epi);
[~, iCross] = min(abs(zs - z));

%iCross = ceil(numel(model.epi)/2);
epi = model.epi{iCross};
elec = model.electrode(:, iCross);

logScale = false;
showScaleBar = false;

axes(ax);
cla(ax);
hold on;
axis image;

colormap(flipud(parula));

% Plot epi
plot(epi(:,1), epi(:,2),'k');

%         oldunits = get(gca, 'Units');
%         set(gca, 'Units', 'points');
%         pos = get(gca, 'Position');    %[X Y width height]
%         xl = xlim();
%         set(gca, 'Units', oldunits');
%         pointsPerDataUnit = pos(3) / (xl(2) - xl(1));

minCurr = Inf;
maxCurr = -Inf;
for iFasc = 1:numel(model.fiberActive)
    % Plot fibers
    % N.B. fibers are plotted at a fixed radius
    fibers = model.fibers{iFasc};
    activationCurr = model.fiberActive{iFasc};
    act = activationCurr > 0;
    x = fibers.center(:,iCross,1);
    y = fibers.center(:,iCross,2);
    %sz = pi*(fibers.r/pointsPerDataUnit.^2);  % ISSUE works in points, not data units
    % Plot inactive fibers in black
    scatter(x(~act), y(~act), 5, 'k', 'filled');
    % Plot active fibers with current thresh. mapped to color
    scatter(x(act), y(act), 5, activationCurr(act), 'filled');
    minCurr = min(minCurr, min(activationCurr(act)));
    maxCurr = max(maxCurr, max(activationCurr(act)));
end

c = colorbar;
if logScale
    set(gca,'ColorScale','log');
    % Different tick styles:
    %set(h,'YTick',round(linspace(minCurr, maxCurr, 6), -floor(log10(minCurr))));
    %set(h,'YTick',round(linspace(minCurr, maxCurr, 6), 2, 'significant'));
    %set(h,'YTick',floor(log10(minCurr)):ceil(log10(maxCurr)));
    %d = floor(log10(maxCurr))-1;
    %set(h,'YTick',round(minCurr, 1, 'significant'):10^d:round(maxCurr, 1, 'significant'));
    minExp = floor(log10(minCurr));
    %maxExp = round(log10(maxCurr));
    %set(h,'YTick',10.^(minExp:maxExp)); % Same as default
    c.Limits = [10.^minExp, maxCurr];
    %h.Ticks = unique(10^minExp, h.Ticks, round(maxCurr, 1, 'significant')]);
end
c.TickLength = 0.03;
ylabel(c, 'Charge threshold (nC)');

% Plot endo
for iFasc = 1:size(model.endo.data, 1)
    branches = model.endo.data{iFasc, iCross};
    for idBranch = 1 : numel(branches)
        plot(branches{idBranch}(:,1), branches{idBranch}(:,2), 'Color', [0.5 0.5 0.5]);
    end
end

% Plot electrode
plot(elec, 'FaceColor', [0.4 0.8 0.7]);

% Plot active site position
xy = model.activeSites(model.iAS).coord(1:2);
plot(xy(1), xy(2),'or', 'LineWidth', 3)

if showScaleBar
    % Plot scale bar
    xl = xlim();
    yl = ylim();
    dy = diff(yl);
    %d = 0.05*dy;
    d = 0.1*dy;
    x = xl(2) - [1000+d d];
    y = yl(1) + d;
    plot(x, [y y], 'k', 'LineWidth', 2);
    text(mean(x), y+0.05*dy, '1 mm', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    % NOTE these methods remove the title
    %set(gca,'visible','off');
    %axis off;
    set(gcf,'color','w');
    set(gca,'XColor','w','YColor','w','TickDir','out')
end

end
