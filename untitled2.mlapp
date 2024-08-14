classdef NeuronalConnectivityApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        UploadButton             matlab.ui.control.Button
        MethodDropDownLabel      matlab.ui.control.Label
        MethodDropDown           matlab.ui.control.DropDown
        ParametersPanel          matlab.ui.container.Panel
        TauEditFieldLabel        matlab.ui.control.Label
        TauEditField             matlab.ui.control.NumericEditField
        MinSEditFieldLabel       matlab.ui.control.Label
        MinSEditField            matlab.ui.control.NumericEditField
        DSEditFieldLabel         matlab.ui.control.Label
        DSEditField              matlab.ui.control.EditField
        RunButton                matlab.ui.control.Button
        ResultsAxes              matlab.ui.control.UIAxes
    end

    properties (Access = private)
        SpikeTrainData           % Data variable for storing spike train data
        SelectedMethod           % Variable for storing selected method
    end

    methods (Access = private)

        % Button pushed function: UploadButton
        function UploadButtonPushed(app, event)
            [file, path] = uigetfile('*.txt', 'Select Spike Train Data');
            if isequal(file, 0)
                disp('User selected Cancel');
            else
                fullPath = fullfile(path, file);
                app.SpikeTrainData = load(fullPath);
                disp(['User selected ', fullPath]);
            end
        end

        % Value changed function: MethodDropDown
        function MethodDropDownValueChanged(app, event)
            app.SelectedMethod = app.MethodDropDown.Value;
            disp(['Selected Method: ', app.SelectedMethod]);
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            tau = app.TauEditField.Value;
            min_s = app.MinSEditField.Value;
            ds = str2num(app.DSEditField.Value);

            % Implement connectivity estimation based on selected method
            results = app.estimate_connectivity(app.SpikeTrainData, tau, min_s, ds, app.SelectedMethod);

            % Display results
            app.plot_results(results);
        end

        function results = estimate_connectivity(app, data, tau, min_s, ds, method)
            % Placeholder function for estimating connectivity
            % Implement the actual algorithm based on the selected method
            results = rand(10); % Replace with actual computation
        end

        function plot_results(app, results)
            % Plot the results in the UIAxes
            plot(app.ResultsAxes, results);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100, 100, 640, 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UploadButton
            app.UploadButton = uibutton(app.UIFigure, 'push');
            app.UploadButton.Position = [26, 424, 100, 22];
            app.UploadButton.Text = 'Upload Data';
            app.UploadButton.ButtonPushedFcn = createCallbackFcn(app, @UploadButtonPushed, true);

            % Create MethodDropDownLabel
            app.MethodDropDownLabel = uilabel(app.UIFigure);
            app.MethodDropDownLabel.HorizontalAlignment = 'right';
            app.MethodDropDownLabel.Position = [26, 390, 93, 22];
            app.MethodDropDownLabel.Text = 'Select Method';

            % Create MethodDropDown
            app.MethodDropDown = uidropdown(app.UIFigure);
            app.MethodDropDown.Items = {'CoNNECT', 'Revised GLMCC', 'Original GLMCC'};
            app.MethodDropDown.Position = [134, 390, 150, 22];
            app.MethodDropDown.ValueChangedFcn = createCallbackFcn(app, @MethodDropDownValueChanged, true);

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.UIFigure);
            app.ParametersPanel.Title = 'Set Parameters';
            app.ParametersPanel.Position = [26, 240, 258, 135];

            % Create TauEditFieldLabel
            app.TauEditFieldLabel = uilabel(app.ParametersPanel);
            app.TauEditFieldLabel.HorizontalAlignment = 'right';
            app.TauEditFieldLabel.Position = [16, 80, 25, 22];
            app.TauEditFieldLabel.Text = 'Tau';

            % Create TauEditField
            app.TauEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.TauEditField.Position = [56, 80, 100, 22];

            % Create MinSEditFieldLabel
            app.MinSEditFieldLabel = uilabel(app.ParametersPanel);
            app.MinSEditFieldLabel.HorizontalAlignment = 'right';
            app.MinSEditFieldLabel.Position = [16, 48, 39, 22];
            app.MinSEditFieldLabel.Text = 'Min S';

            % Create MinSEditField
            app.MinSEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.MinSEditField.Position = [70, 48, 100, 22];

            % Create DSEditFieldLabel
            app.DSEditFieldLabel = uilabel(app.ParametersPanel);
            app.DSEditFieldLabel.HorizontalAlignment = 'right';
            app.DSEditFieldLabel.Position = [16, 16, 25, 22];
            app.DSEditFieldLabel.Text = 'DS';

            % Create DSEditField
            app.DSEditField = uieditfield(app.ParametersPanel, 'text');
            app.DSEditField.Position = [56, 16, 178, 22];

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.Position = [26, 200, 100, 22];
            app.RunButton.Text = 'Run';
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);

            % Create ResultsAxes
            app.ResultsAxes = uiaxes(app.UIFigure);
            app.ResultsAxes.Position = [300, 50, 300, 300];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App initialization and construction
    methods (Access = public)

        % Construct app
        function app = NeuronalConnectivityApp

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
