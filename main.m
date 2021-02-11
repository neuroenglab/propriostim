function main()
%MAIN Summary of this function goes here
%   Detailed explanation goes here

close all;

subjectNames = {'Subject1','Subject3'};
placements = {'TIME4H_8','TIME4H_11','TIME4H_14','TIME4H_15';
    'TIME4H_?','TIME4H_?','TIME4H_?','TIME4H_?'};

model = [];
selectionMode = '';

% Setup figure
fig = uifigure('HandleVisibility', 'on');  % to be able to 'close' it
fig.Position = [100 100 820 620];
g = uigridlayout(fig);
g.RowHeight = {22, 22, 22, '1x'};
g.ColumnWidth = {120,'1x','1x','1x','1x'};

uilabel(g, 'Text', 'Model selection:', 'FontWeight', 'bold');
ddSubj = uidropdown(g,'Items', subjectNames, 'ValueChangedFcn', @selection_subj);
ddElec = uidropdown(g,'Items', placements(1,:), 'ValueChangedFcn', @selection_elec_as);
as = arrayfun(@num2str, 1:14, 'UniformOutput', false);
ddAs = uidropdown(g, 'Items', strcat({'AS '}, as), 'ItemsData', as, ...
    'Value', '1', 'ValueChangedFcn', @selection_elec_as);
uibutton(g, 'Text', 'Load', 'ButtonPushedFcn', @load_button_pushed);

uilabel(g, 'Text', 'Fascicles selection:', 'FontWeight', 'bold');
lblMotorFascNo = 'No motor fascicle selected';
lblMotorFasc = uilabel(g,'Text', lblMotorFascNo, 'HorizontalAlignment', 'right');
btnMotorFasc = uibutton(g, 'Text', 'Select', 'ButtonPushedFcn', @motor_button_pushed);
lblTouchFascNo = 'No reference touch fascicle selected';
lblTouchFasc = uilabel(g, 'Text', lblTouchFascNo, 'HorizontalAlignment', 'right');
btnTouchFasc = uibutton(g, 'Text', 'Select', 'ButtonPushedFcn', @touch_button_pushed);

uilabel(g, 'Text', 'Fibers selection:', 'FontWeight', 'bold');
btnMotorRandom = uibutton(g, 'Text', 'Random', 'ButtonPushedFcn', @random_button_pushed);

axCross = uiaxes(g);
axCross.Layout.Row = 4;
axCross.Layout.Column = [1 3];
hold(axCross, 'on');
axis(axCross, 'equal');
title(axCross, 'Cross-section');
xlabel(axCross, 'x [um]');
ylabel(axCross, 'y [um]');
colormap(axCross, flipud(parula));
c = colorbar(axCross);
c.Label.String = 'Charge threshold [nC]';

axRecr = uiaxes(g);
axRecr.Layout.Row = 4;
axRecr.Layout.Column = [4 5];
xlabel(axRecr, 'Injected Charge [nC]');
ylabel(axRecr, 'Relative recruitment [%]');
ylim(axRecr, [0 100]);
title(axRecr, 'Recruitment');
    
refresh_view();

    function refresh_view()
        btnMotorFasc.Enable = ~isempty(model);
        btnTouchFasc.Enable = ~isempty(model);
        btnMotorRandom.Enable = ~isempty(model) && model.motorFasc ~= 0;
        drawnow;
    end

    function selection_subj(~, ~)
        ddElec.Items = placements(strcmp(subjectNames, ddSubj.Value),:);
        ddElec.Value = ddElec.Items{1};
    end

    function selection_elec_as(~, ~)
        % Less reliable than the Load button
        %update_model();
    end

    function load_button_pushed(~, ~)
        update_model();
    end

    function motor_button_pushed(~, ~)
        set_fasc_selection('motor');
    end

    function touch_button_pushed(~, ~)
        set_fasc_selection('touch');
    end

    function random_button_pushed(~, ~)
        model = select_fibers(model, []);
        draw_cross_section();
        %set_fasc_selection('touch');
    end

    function update_model()
        model = load_model(ddSubj.Value, ddElec.Value, ddAs.Value);
        set_fasc_selection(); % Calls draw_cross_section too
    end

    function draw_cross_section()
        plot_cross_section(model, axCross, @fasc_click);
        if model.motorFasc ~= 0 || model.touchFasc ~= 0
            plot_recruitment(model, axRecr);
        else
            cla(axRecr);
        end
        refresh_view();
    end

    function fasc_click(fascPatch, ~)
        if ~ismember(fascPatch.UserData, model.fascIds)
            return;
        end
        switch selectionMode
            case ''
            case 'motor'
                model.motorFasc = fascPatch.UserData;
                model.IaFiberId = [];
                model.IbFiberId = [];
                model.AlphaFiberId = [];
                set_fasc_selection();
            case 'touch'
                model.touchFasc = fascPatch.UserData;
                set_fasc_selection();
        end
    end

    function set_fasc_selection(state)
        if nargin == 0
            state = '';
        end
        selectionMode = state;
        if isempty(state)
            fig.Pointer = 'arrow';
            if model.motorFasc == 0
                lblMotorFasc.Text = lblMotorFascNo;
            else
                lblMotorFasc.Text = ['Motor fascicle: ' num2str(model.motorFasc)];
            end
            if model.touchFasc == 0
                lblTouchFasc.Text = lblTouchFascNo;
            else
                lblTouchFasc.Text = ['Reference touch fascicle: ' num2str(model.touchFasc)];
            end
            draw_cross_section();
        else
            fig.Pointer = 'hand';
            drawnow;
        end
    end
end
