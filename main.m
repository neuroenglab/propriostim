function main()

close all;

subjectNames = {'Subject1','Subject3'};
placements = {'TIME4H_8','TIME4H_11','TIME4H_14','TIME4H_15';
    'TIME4H_?','TIME4H_?','TIME4H_?','TIME4H_?'};

model = [];
selectionMode = '';

% Setup figure
fig = uifigure('HandleVisibility', 'on');  % to be able to 'close' it
fig.Position = [100 100 1080 500];
g = uigridlayout(fig);
g.RowHeight = {22, 22, 22, '1x', 22};
g.ColumnWidth = {200,'1x','1x','1x','1x'};

uilabel(g, 'Text', 'Model selection:', 'FontWeight', 'bold');
ddSubj = uidropdown(g,'Items', subjectNames, 'ValueChangedFcn', @selection_subj);
ddElec = uidropdown(g,'Items', placements(1,:), 'ValueChangedFcn', @selection_elec_as);
as = arrayfun(@num2str, 1:14, 'UniformOutput', false);
ddAs = uidropdown(g, 'Items', strcat({'AS '}, as), 'ItemsData', as, ...
    'Value', '1', 'ValueChangedFcn', @selection_elec_as);
uibutton(g, 'Text', 'Load', 'ButtonPushedFcn', @load_button_pushed);

uilabel(g, 'Text', 'Fascicles selection:', 'FontWeight', 'bold');
%lblMotorFascNo = 'No motor fascicle selected';
%lblMotorFasc = uilabel(g,'Text', lblMotorFascNo, 'HorizontalAlignment', 'right');
btnMotorFascText = 'Select motor fascicle';
btnMotorFasc = uibutton(g, 'Text', btnMotorFascText, 'ButtonPushedFcn', @motor_button_pushed);
btnMotorFasc.Layout.Column = [2 3];
%lblTouchFascNo = 'No reference touch fascicle selected';
%lblTouchFasc = uilabel(g, 'Text', lblTouchFascNo, 'HorizontalAlignment', 'right');
btnTouchFascText = 'Select touch fascicle';
btnTouchFasc = uibutton(g, 'Text', btnTouchFascText, 'ButtonPushedFcn', @touch_button_pushed);
btnTouchFasc.Layout.Column = [4 5];

uilabel(g, 'Text', 'Motor fascicle fibers selection:', 'FontWeight', 'bold');
btnMotorRandom = uibutton(g, 'Text', 'Random', 'ButtonPushedFcn', @random_button_pushed);
btnMotorCluster = uibutton(g, 'Text', 'Cluster', 'ButtonPushedFcn', @cluster_button_pushed);
ddPace = uidropdown(g, 'Items', {'Slow pace (2 s)', 'Mid pace (1.6 s)', 'Fast pace (1.2 s)'}, 'ItemsData', 1:3);
btnRun = uibutton(g, 'Text', 'Run stimulation', 'ButtonPushedFcn', @run_button_pushed);

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

btn3DView = uibutton(g, 'Text', '3D View (slow)', 'ButtonPushedFcn', @view_button_pushed);
btn3DView.Layout.Column = 2;

refresh_view();

    function refresh_view()
        btn3DView.Enable = ~isempty(model);
        btnMotorFasc.Enable = ~isempty(model);
        btnTouchFasc.Enable = ~isempty(model);
        btnMotorRandom.Enable = ~isempty(model) && model.motorFasc ~= 0;
        btnMotorCluster.Enable = btnMotorRandom.Enable;
        btnRun.Enable = ~isempty(model) && ~isempty(model.IaFiberId) && model.touchFasc ~= 0;
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

    function view_button_pushed(~, ~)
        model.view();
    end

    function motor_button_pushed(~, ~)
        draw_fasc_selection('motor');
    end

    function touch_button_pushed(~, ~)
        draw_fasc_selection('touch');
    end

    function random_button_pushed(~, ~)
        model = select_fibers(model, []);
        draw_cross_section();
    end

    function cluster_button_pushed(~, ~)
        % Both with ginput and drawpoint there is an offset (MATLAB bug?),
        % calibration necessary
        axes(axCross);
        h = [text(0.05, 1, 'Align for calibration.', 'Units', 'normalized', 'FontWeight', 'bold'), ...
            xline(0), yline(0)];
        [x0, y0] = ginput(1);  % Calibration
        delete(h);
        h = text(0.05, 1, 'Select center of Ia and Ib fibers', 'Units', 'normalized', 'FontWeight', 'bold');
        drawnow;
        [x, y] = ginput(2);
        delete(h);
        model = select_fibers(model, [x - x0, y - y0]);
        draw_cross_section();
    end

    function run_button_pushed(~, ~)
        proprio_stim(model, ddPace.Value);
    end

    function update_model()
        model = load_model(ddSubj.Value, ddElec.Value, ddAs.Value);
        draw_fasc_selection(); % Calls draw_cross_section too
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
                assert(fascPatch.UserData ~= model.touchFasc);
                model.motorFasc = fascPatch.UserData;
                model.IaFiberId = [];
                model.IbFiberId = [];
                model.AlphaFiberId = [];
                draw_fasc_selection();
            case 'touch'
                assert(fascPatch.UserData ~= model.motorFasc);
                model.touchFasc = fascPatch.UserData;
                draw_fasc_selection();
        end
    end

    function draw_fasc_selection(state)
        if nargin == 0
            state = '';
        end
        selectionMode = state;
        if isempty(state)
            fig.Pointer = 'arrow';
            if model.motorFasc == 0
                btnMotorFasc.Text = btnMotorFascText;
            else
                btnMotorFasc.Text = ['Reselect motor fascicle (no. ' num2str(model.motorFasc) ')'];
            end
            if model.touchFasc == 0
                btnTouchFasc.Text = btnTouchFascText;
            else
                btnTouchFasc.Text = ['Reselect touch fascicle (no. ' num2str(model.touchFasc) ')'];
            end
            draw_cross_section();
        else
            fig.Pointer = 'hand';
            drawnow;
        end
    end
end
