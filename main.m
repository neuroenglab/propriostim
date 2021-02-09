function main()
%MAIN Summary of this function goes here
%   Detailed explanation goes here

close all;

subjectNames = {'Subject1','Subject3'};
placements = {'TIME4H_8','TIME4H_11','TIME4H_14','TIME4H_15';
    'TIME4H_?','TIME4H_?','TIME4H_?','TIME4H_?'};

% tf = false;
% while ~tf
%     [iSubj, tf] = listdlg('ListString',{'Subject1','Subject3'},'SelectionMode','single');
%     if ~tf
%         continue;
%     end
%     subjPlacements = placements(iSubj, :);
%     [iPlac, tf] = listdlg('ListString', subjPlacements,'SelectionMode','single');
% end

% Setup figure
fig = uifigure('HandleVisibility', 'on');
fig.Position = [100 100 820 620];
g = uigridlayout(fig);
g.RowHeight = {22,'1x'};
g.ColumnWidth = {'1x','1x','1x','1x'};

ddSubj = uidropdown(g,'Items', subjectNames, 'ValueChangedFcn', @selection_subj);
ddElec = uidropdown(g,'Items',placements(1,:), 'ValueChangedFcn', @selection_elec);
ddAs = uidropdown(g,'Items',arrayfun(@num2str, 1:14, 'UniformOutput', false), ...
    'Value', '1', 'ValueChangedFcn', @selection_as);

ax = uiaxes(g);
ax.Layout.Row = 2;
ax.Layout.Column = [1 3];

model = [];
update_model();

    function selection_subj(dd, event)
        ddElec.Items = placements(strcmp(subjectNames, dd.Value),:);
        ddElec.Value = ddElec.Items{1};
    end

    function selection_elec(dd, event)
        update_model();
    end

    function selection_as(dd, event)
        update_model();
    end

    function update_model()
        model = load_model(ddSubj.Value, ddElec.Value, ddAs.Value);
        plot_cross_section(model, ax);
        drawnow;
    end

    function update_plot()
        
    end
end
