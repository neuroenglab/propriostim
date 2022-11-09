function view_stored_data()
addpath('matlab');

close all;

[subjects, electrodes] = scrape_stored_data();

model = [];
selectionMode = '';

% Setup figure
fig = uifigure('HandleVisibility', 'on');  % to be able to 'close' it
fig.Position = [100 100 1280 640];
g = uigridlayout(fig);
g.RowHeight = {22, 22, 22, '1x', 22};
g.ColumnWidth = {200,'1x','1x','1x','1x'};

uilabel(g, 'Text', 'Model selection:', 'FontWeight', 'bold');
ddSubj = uidropdown(g,'Items', subjects, 'ValueChangedFcn', @selection_subj);
ddElec = uidropdown(g,'Items', electrodes{1}, 'ValueChangedFcn', @selection_elec_as);
as = arrayfun(@num2str, 1:14, 'UniformOutput', false);
ddAs = uidropdown(g, 'Items', strcat({'AS '}, as), 'ItemsData', as, ...
    'Value', '1', 'ValueChangedFcn', @selection_elec_as);
uibutton(g, 'Text', 'Load', 'ButtonPushedFcn', @load_button_pushed);

uilabel(g, 'Text', 'Fascicles selection:', 'FontWeight', 'bold');
btnMotorFascText = 'Select motor fascicle';
btnMotorFasc = uibutton(g, 'Text', btnMotorFascText, 'ButtonPushedFcn', @motor_button_pushed);
btnMotorFasc.Layout.Column = [2 3];
btnRefFascText = 'Select reference fascicle';
btnRefFasc = uibutton(g, 'Text', btnRefFascText, 'ButtonPushedFcn', @ref_button_pushed);
btnRefFasc.Layout.Column = [4 5];

uilabel(g, 'Text', 'Motor fascicle fibers selection:', 'FontWeight', 'bold');
btnMotorRandom = uibutton(g, 'Text', 'Random', 'ButtonPushedFcn', @random_button_pushed);
btnMotorCluster = uibutton(g, 'Text', 'Cluster', 'ButtonPushedFcn', @cluster_button_pushed);
ddPace = uidropdown(g, 'Items', list_pace(), 'ItemsData', 1:3);
btnRun = uibutton(g, 'Text', 'Run stimulation', 'ButtonPushedFcn', @run_button_pushed);

axCross = uiaxes(g);
axCross.Layout.Row = 4;
axCross.Layout.Column = [1 3];
prepare_plot_cross_section(axCross);

axRecr = uiaxes(g);
axRecr.Layout.Row = 4;
axRecr.Layout.Column = [4 5];
prepare_plot_recruitment(axRecr);

btn3DView = uibutton(g, 'Text', '3D View (slow)', 'ButtonPushedFcn', @view_button_pushed);
btn3DView.Layout.Column = 2;

refresh_view();

    function refresh_view()
        btn3DView.Enable = ~isempty(model);
        btnMotorFasc.Enable = ~isempty(model);
        btnRefFasc.Enable = ~isempty(model);
        btnMotorRandom.Enable = ~isempty(model) && model.motorFasc ~= 0;
        btnMotorCluster.Enable = btnMotorRandom.Enable;
        btnRun.Enable = ~isempty(model) && ~isempty(model.fiberType);
        drawnow;
    end

    function selection_subj(~, ~)
        ddElec.Items = electrodes{strcmp(subjects, ddSubj.Value)};
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
        view_3d_model(model);
    end

    function motor_button_pushed(~, ~)
        if model.motorFasc == 0
            draw_fasc_selection('motor');
        else
            model.motorFasc = 0;
            model.fiberType = logical.empty;
            draw_fasc_selection();
        end
    end

    function ref_button_pushed(~, ~)
        if model.refFasc == 0
            draw_fasc_selection('ref');
        else
            model.refFasc = 0;
            draw_fasc_selection();
        end
    end

    function random_button_pushed(~, ~)
        model = select_fibers(model, []);
        draw_cross_section();
    end

    function cluster_button_pushed(~, ~)
        % Both with ginput and drawpoint there is an offset (MATLAB bug?),
        % calibration necessary
        axes(axCross);
        [x, y] = cluster_selection();
        model = select_fibers(model, [x, y]);
        draw_cross_section();
    end

    function run_button_pushed(~, ~)
        muscle = select_muscle_dlg();
        proprio_stim(model, ddPace.Value, muscle, true);
    end

    function update_model()
        model = load_model(ddSubj.Value, ddElec.Value, ddAs.Value);
        draw_fasc_selection(); % Calls draw_cross_section too
    end

    function draw_cross_section()
        plot_cross_section(model, axCross, @fasc_click);
        if model.motorFasc ~= 0 || model.refFasc ~= 0
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
                if fascPatch.UserData == model.refFasc
                    % TODO display message
                    return;
                end
                model.motorFasc = fascPatch.UserData;
                model.fiberType = logical.empty;
                draw_fasc_selection();
            case 'ref'
                if fascPatch.UserData == model.motorFasc
                    % TODO display message
                    return;
                end
                model.refFasc = fascPatch.UserData;
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
                btnMotorFasc.Text = ['Deselect motor fascicle (no. ' num2str(model.motorFasc) ')'];
            end
            if model.refFasc == 0
                btnRefFasc.Text = btnRefFascText;
            else
                btnRefFasc.Text = ['Deselect reference fascicle (no. ' num2str(model.refFasc) ')'];
            end
            draw_cross_section();
        else
            fig.Pointer = 'hand';
            drawnow;
        end
    end
end
