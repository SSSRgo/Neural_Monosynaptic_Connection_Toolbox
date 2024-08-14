classdef MonoSynapticConnection_APP_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        FileMenu                    matlab.ui.container.Menu
        LoadDataMenu                matlab.ui.container.Menu
        SaveDataMenu                matlab.ui.container.Menu
        Image                       matlab.ui.control.Image
        Hyperlink                   matlab.ui.control.Hyperlink
        MethodButtonGroup           matlab.ui.container.ButtonGroup
        CoNNECTButton               matlab.ui.control.RadioButton
        GLMCCButton                 matlab.ui.control.RadioButton
        BzlabButton                 matlab.ui.control.RadioButton
        StarkButton                 matlab.ui.control.RadioButton
        DisplayWindowLabel          matlab.ui.control.Label
        Tree                        matlab.ui.container.CheckBoxTree
        MethodsNode                 matlab.ui.container.TreeNode
        starkNode                   matlab.ui.container.TreeNode
        BzlabNode                   matlab.ui.container.TreeNode
        GLMCCNode                   matlab.ui.container.TreeNode
        CoNNECTNode                 matlab.ui.container.TreeNode
        CoNNECTEditField            matlab.ui.control.NumericEditField
        CoNNECT_CheckBox            matlab.ui.control.CheckBox
        CoNNECTLabel                matlab.ui.control.Label
        GLMCCEditField              matlab.ui.control.NumericEditField
        GLMCC_CheckBox              matlab.ui.control.CheckBox
        GLMCCLabel                  matlab.ui.control.Label
        BzlabEditField              matlab.ui.control.NumericEditField
        Bzlab_CheckBox              matlab.ui.control.CheckBox
        BzlabLabel                  matlab.ui.control.Label
        ArtificialcheckDropDown     matlab.ui.control.DropDown
        click_neuron_pairs          matlab.ui.control.Label
        PreNeuronvsPostNeuronLabel  matlab.ui.control.Label
        StarkEditField              matlab.ui.control.NumericEditField
        Stark_CheckBox              matlab.ui.control.CheckBox
        starkLabel                  matlab.ui.control.Label
        PostNeuronEditField         matlab.ui.control.NumericEditField
        PostNeuronEditFieldLabel    matlab.ui.control.Label
        Button4                     matlab.ui.control.Button
        Data_path                   matlab.ui.control.Label
        PreNeuronEditField          matlab.ui.control.NumericEditField
        PreNeuronEditFieldLabel     matlab.ui.control.Label
        Save_data                   matlab.ui.control.Button
        onepairconnectioncheckviewPanel  matlab.ui.container.Panel
        Load_data                   matlab.ui.control.Button
        GraphAxes                   matlab.ui.control.UIAxes
        TagmapAxes                  matlab.ui.control.UIAxes
        HeatmapAxes                 matlab.ui.control.UIAxes
        ImageAxes                   matlab.ui.control.UIAxes
        ContextMenu                 matlab.ui.container.ContextMenu
        Menu                        matlab.ui.container.Menu
        Menu2                       matlab.ui.container.Menu
    end


    properties (Access = private)
        HeatmapData % Description
        data
        CCG_data
        TagmapData
        row
        col
        weights
        s
        t
        p
        G
        connection_matrix
        desired_nodes
        method
        connection_graph_order=2;
        Tagcolormap=[0.75, 0.75, 0.75;   % Grey
            0, 1, 0;         % Green
            1, 1, 0;         % Yellow
            1, 0, 0];        % Red
        Graphcolormap=b2rCD(5);
    end

    methods (Access = private)
        function plot_heatmap(app)
            cla(app.HeatmapAxes);
            %             imagesc(app.HeatmapAxes, app.HeatmapData,"HitTest","off");
            % Imagesc plot on the lower axes
            colormap(app.HeatmapAxes, "hot");
            imagesc(app.HeatmapAxes, 'XData', 1:size(app.HeatmapData, 2), ...
                'YData', 1:size(app.HeatmapData, 1), ...
                'CData', app.HeatmapData, ...
                'HitTest', 'off');

            % Set axis properties for the heatmap
            axis(app.HeatmapAxes, 'xy');  % Ensure 'xy' direction for proper display
            % Hide the axis labels and only show the tick marks
            app.HeatmapAxes.XLabel.String = 'Post-neuron';
            app.HeatmapAxes.YLabel.String = 'Pre-neuron';
            %     app.HeatmapAxes.XColor = 'none';
            %     app.HeatmapAxes.YColor = 'none';

            title(app.HeatmapAxes, 'Connection Matrix', 'FontWeight', 'bold'); % Adjust as needed
            % Adjust the limits and other properties if necessary
            app.HeatmapAxes.XLim = [0, size(app.HeatmapData, 2)];
            app.HeatmapAxes.YLim = [0, size(app.HeatmapData, 1)];

            % Set the tick marks from 0 to the size of the matrix
            xticks(app.HeatmapAxes, [0:5:size(app.HeatmapData, 2) size(app.HeatmapData, 2)]);
            yticks(app.HeatmapAxes, [0:5:size(app.HeatmapData, 1) size(app.HeatmapData, 1)]);
        end

        function PairTextUpdate(app)

            app.click_neuron_pairs.Text=[num2str(app.row) ' vs ' num2str(app.col) ];

        end


        function heatmapClickCallback(app, event)
            % Get the click position
            cp = event.IntersectionPoint;
            row = round(cp(2));
            col = round(cp(1));
            app.row=row;
            app.col=col;

            %%

            %             app.ArtificialcheckDropDown.Text=[num2str(row) ' vs ' num2str(col) ];
            app.ArtificialcheckDropDown.Value=app.ArtificialcheckDropDown.Items{app.TagmapData(app.row,app.col)};


            app.Stark_CheckBox.Value=1;
            app.Bzlab_CheckBox.Value=1;
            app.GLMCC_CheckBox.Value=1;
            app.CoNNECT_CheckBox.Value=1;

            app.CoNNECTEditField.Value=app.data.monosyn_data.connection_matrix.CoNNECTMatrix(app.row,app.col);
            app.BzlabEditField.Value= app.data.monosyn_data.connection_matrix.BzlabMatrix(app.row,app.col);
            app.GLMCCEditField.Value = app.data.monosyn_data.connection_matrix.GLMCCMatrix(app.row,app.col);
            app.StarkEditField.Value=app.data.monosyn_data.connection_matrix.starkMatrix(app.row,app.col);



            % Ensure the click is within the heatmap bounds
            if row > 0 && row <= size(app.HeatmapData, 1) && col > 0 && col <= size(app.HeatmapData, 2)
                % Display an image in the ImageAxes
                % Replace this with actual image data loading if needed
                % Get the size for the heatmap

                % Generate random heatmap data
                plot_CCG(app)
                PairTextUpdate(app)
                %                 set()


                % Plot the heatmap
                %                 imagesc(app.HeatmapyAxes, app.HeatmapData);
                %                 colorbar(app.ImageAxes);

                %                 img = imread('your_image_file.png'); % Example placeholder
                %                 imshow(img, 'Parent', app.ImageAxes);
                %                 title(app.ImageAxes, ['Cell (' num2str(row) ', ' num2str(col) ')']);
            end
        end


        function plot_tagmap(app)
            cla(app.TagmapAxes);
            %             imagesc(app.HeatmapAxes, app.HeatmapData,"HitTest","off");
            % Imagesc plot on the lower axes

            imagesc(app.TagmapAxes, 'XData', 1:size(app.TagmapData, 2), ...
                'YData', 1:size(app.TagmapData, 1), ...
                'CData', app.TagmapData,'AlphaData',0.5, ...
                'HitTest', 'off');
            colormap(app.TagmapAxes, app.Tagcolormap);
            set(app.TagmapAxes,'clim',[1 4]);

            % Set axis properties for the heatmap
            axis(app.TagmapAxes, 'xy');  % Ensure 'xy' direction for proper display
            % Hide the axis labels and only show the tick marks
            app.TagmapAxes.XLabel.String = 'Post-neuron';
            app.TagmapAxes.YLabel.String = 'Pre-neuron';
            %     app.TagmapAxes.XColor = 'none';
            %     app.TagmapAxes.YColor = 'none';

            title(app.TagmapAxes, 'Tag Matrix', 'FontWeight', 'bold'); % Adjust as needed
            % Adjust the limits and other properties if necessary
            app.TagmapAxes.XLim = [0, size(app.TagmapData, 2)];
            app.TagmapAxes.YLim = [0, size(app.TagmapData, 1)];

            % Set the tick marks from 0 to the size of the matrix
            xticks(app.TagmapAxes, [0:5:size(app.TagmapData, 2) size(app.TagmapData, 2)]);
            yticks(app.TagmapAxes, [0:5:size(app.TagmapData, 1) size(app.TagmapData, 1)]);
        end

        function Display(app,text)
            app.DisplayWindowLabel.Text=text;

        end

        function plot_graph(app)

            Bzlab_pre_connect=find(app.data.monosyn_data.connection_matrix.BzlabMatrix(app.row,:)==1);
            stark_pre_connect=find(app.data.monosyn_data.connection_matrix.starkMatrix(app.row,:)==1);
            GLMCC_pre_connect=find(app.data.monosyn_data.connection_matrix.GLMCCMatrix(app.row,:)==1);
            CoNNECT_pre_connect=find(app.data.monosyn_data.connection_matrix.CoNNECTMatrix(app.row,:)==1);



            app.s=[ones(size(Bzlab_pre_connect))*app.row ones(size(stark_pre_connect))*app.row ones(size(GLMCC_pre_connect))*app.row ones(size(CoNNECT_pre_connect))*app.row];
            app.t = [Bzlab_pre_connect stark_pre_connect GLMCC_pre_connect CoNNECT_pre_connect];
            app.weights=[app.data.monosyn_data.weight_matrix.BzlabMatrix(app.row,Bzlab_pre_connect) ...
                app.data.monosyn_data.weight_matrix.starkMatrix(app.row,stark_pre_connect) ...
                app.data.monosyn_data.weight_matrix.GLMCCMatrix(app.row,GLMCC_pre_connect) ...
                app.data.monosyn_data.weight_matrix.CoNNECTMatrix(app.row,CoNNECT_pre_connect)];

            %             app.weights=abs(app.weights);

            % min_weight = 1;
            % max_weight = 5;
            % app.weights = min_weight + (app.weights - min(app.weights)) * (max_weight - min_weight) / (max(app.weights) - min(app.weights));


            l1=length(Bzlab_pre_connect);
            l2=length(stark_pre_connect);
            l3=length(GLMCC_pre_connect);
            l4=length(CoNNECT_pre_connect);


            % p.LineStyle(1:length(Bzlab_pre_connect)) = {'--'};
            % p.LineStyle(1:length(Bzlab_pre_connect)) = {'--'};


            %       app.s = [1 1 1 2 2 3 3 4 4 5];
            % app.t = [2 3 4 5 6 7 8 9 10 1];
            % app.weights = [0.1 0.5 2.0 1.5 0.8 3.0 1.0 0.3 2.5 1.2];

            %             %  p.LineStyle{2}='--'
            %             app.method
            %

            method(1:l1)={'Bzlab'};
            method(l1+1:l1+l2)={'stark'};
            method(l1+l2+1:l1+l2+l3)={'GLMCC'};
            method(l1+l2+l3+1:length(app.t))={'CoNNECT'};



            % names = {'USA' 'GBR' 'DEU' 'FRA'}';
            % country_code = {'1' '44' '49' '33'}';
            % NodeTable = table(names,country_code,'VariableNames',{'Name' 'Country'})

            NodeTable = table(1:length(app.t),'VariableNames',{'Name' });

            EdgeTable = table([app.s' app.t'],app.weights',method', ...
                'VariableNames',{'EndNodes' 'Weight' 'Method'});
            G_total= graph(EdgeTable);

            %             G_total = graph(app.s, app.t, app.weights);
            app.desired_nodes=[unique(app.s) unique(app.t)];
            G = subgraph(G_total, app.desired_nodes);
            % G.Edges.EndNodes=[app.t' app.s'];

            % Plot the graph with initial settings
            p = plot(app.GraphAxes, G, 'NodeLabel', app.desired_nodes, 'Layout', 'force', ...
                'NodeColor', 'black', 'EdgeColor', 'magenta', 'HitTest', 'off', ...
                'PickableParts', 'all');
            app.GraphAxes.Color = 'white';
            p.NodeLabelColor = 'black';


            % Define the target row
            target_row = app.desired_nodes([1 2]);
            % Use ismember to find the matching rows
            [~, pos] = ismember(target_row, G.Edges.EndNodes, 'rows');
            % Find all positions
            positions = find(ismember(G.Edges.EndNodes, target_row, 'rows'));




            % Adjust line widths based on edge weights
            LineWidth = 2 * abs(G.Edges.Weight);
            min_weight = 1;
            max_weight = 3;
            app.weights = min_weight + (LineWidth - min(LineWidth)) * (max_weight - min_weight) / (max(LineWidth) - min(LineWidth));

            p.LineWidth=LineWidth;

            % Define line styles and colors for different segments
            LineStyle = cell(1, length(app.t));  % Preallocate cell array for line styles
            LineColors = cell(1, length(app.t));  % Preallocate cell array for line colors

            % [p1,~]=find(G.Edges.Weight==app.weights(1:l1));
            % [p2,~]=find(G.Edges.Weight==app.weights(l1+1:l1+l2));
            % [p3,~]=find(G.Edges.Weight==app.weights(l1+l2+1:l1+l2+l3));
            % [p4,~]=find(G.Edges.Weight==app.weights(l1+l2+l3+1:length(app.t)));

            p1 = find(strcmp(G.Edges.Method, 'Bzlab'));
            p2 = find(strcmp(G.Edges.Method, 'stark'));
            p3 = find(strcmp(G.Edges.Method, 'GLMCC'));
            p4 = find(strcmp(G.Edges.Method, 'CoNNECT'));

            % Assign line styles
            LineStyle(p1) = {'-'};
            LineStyle(p2) = {'--'};
            LineStyle(p3) = {':'};
            LineStyle(p4) = {'-.'};

            ep1 = find(strcmp(G.Edges.Method, 'Bzlab')&G.Edges.Weight>0);
            ep2 = find(strcmp(G.Edges.Method, 'stark')&G.Edges.Weight>0);
            ep3 = find(strcmp(G.Edges.Method, 'GLMCC')&G.Edges.Weight>0);
            ep4 = find(strcmp(G.Edges.Method, 'CoNNECT')&G.Edges.Weight>0);

            ip1 = find(strcmp(G.Edges.Method, 'Bzlab')&G.Edges.Weight<0);
            ip2 = find(strcmp(G.Edges.Method, 'stark')&G.Edges.Weight<0);
            ip3 = find(strcmp(G.Edges.Method, 'GLMCC')&G.Edges.Weight<0);
            ip4 = find(strcmp(G.Edges.Method, 'CoNNECT')&G.Edges.Weight<0);

            % a = find(strcmp(G.Edges.Method, 'GLMCC')&G.Edges.Weight>0)

            % Assign line colors (you can customize the colors)
            % [ep1,~]=find(G.Edges.Weight==app.weights(app.weights(1:l1)>0));
            % [ep2,~]=find(G.Edges.Weight==app.weights(app.weights(l1+1:l1+l2)>0));
            % [ep3,~]=find(G.Edges.Weight==app.weights(app.weights(l1+l2+1:l1+l2+l3)>0));
            % [ep4,~]=find(G.Edges.Weight==app.weights(app.weights(l1+l2+l3+1:length(app.t))>0));
            %
            % [ip1,~]=find(G.Edges.Weight==app.weights(app.weights(1:l1)<0));
            % [ip2,~]=find(G.Edges.Weight==app.weights(app.weights(l1+1:l1+l2)<0));
            % [ip3,~]=find(G.Edges.Weight==app.weights(app.weights(l1+l2+1:l1+l2+l3)<0));
            % [ip4,~]=find(G.Edges.Weight==app.weights(app.weights(l1+l2+l3+1:length(app.t))<0));


            LineColors(ip1) = {app.Graphcolormap(1,:)};
            LineColors(ip2) = {app.Graphcolormap(2,:)};
            LineColors(ip3) = {app.Graphcolormap(3,:)};
            LineColors(ip4) = {app.Graphcolormap(4,:)};

            LineColors(ep1) = {app.Graphcolormap(7,:)};
            LineColors(ep2) = {app.Graphcolormap(8,:)};
            LineColors(ep3) = {app.Graphcolormap(9,:)};
            LineColors(ep4) = {app.Graphcolormap(10,:)};

            LineColors_matrix = reshape(cell2mat(LineColors), 3, []).';

            % % Apply the styles and colors
            % for i = 1:length(app.t)
            %     highlight(p, 'Edges', i, 'LineStyle', LineStyle{i}, 'EdgeColor', LineColors{i});
            % end
            p.LineStyle=LineStyle;
            p.EdgeColor=LineColors_matrix;
            % Set the background and node label colors



            app.p = p;
            app.G = G;

            app.GraphAxes.XLabel.String = '';
            app.GraphAxes.YLabel.String = '';
            app.GraphAxes.XColor = 'none';
            app.GraphAxes.YColor = 'none';

        end

        function graphClickCallback(app, event)
            % Get click position in the axes
            clickPosition = event.IntersectionPoint(1:2);

            % Determine if a node was clicked
            [nodeClicked, nodeIndex] = detectNodeClick(app,clickPosition);

            if nodeClicked
                % Handle node click
                disp(['Node ' num2str(app.desired_nodes(nodeIndex)) ' was clicked']);
                return;
            end

            % Determine if an edge was clicked
            [edgeClicked, edgeIndex] = detectEdgeClick(app,clickPosition);



            if edgeClicked
                % Handle edge click
                app.row=app.desired_nodes(app.G.Edges.EndNodes(edgeIndex, 1));
                app.col=app.desired_nodes(app.G.Edges.EndNodes(edgeIndex, 2));
                disp(['Edge from node ' num2str(app.row) ...
                    ' to node ' num2str(app.col) ' was clicked']);

                plot_CCG(app)
                PairTextUpdate(app)
            end
        end

        function [nodeClicked, nodeIndex] = detectNodeClick(app,clickPosition)
            % Calculate distance from click to each node
            distances = sqrt((app.p.XData - clickPosition(1)).^2 + (app.p.YData - clickPosition(2)).^2);
            [minDistance, nodeIndex] = min(distances);

            % Define a threshold for click detection (adjustable)
            threshold = 0.1;

            % Check if click is close enough to a node
            nodeClicked = minDistance < threshold;
        end

        function [edgeClicked, edgeIndex] = detectEdgeClick(app,clickPosition)
            p=app.p;
            G=app.G;

            edgeClicked = false;
            edgeIndex = -1;

            % Loop through each edge
            for i = 1:numedges(G)
                % Get the coordinates of the edge's endpoints
                x1 = p.XData(G.Edges.EndNodes(i, 1));
                y1 = p.YData(G.Edges.EndNodes(i, 1));
                x2 = p.XData(G.Edges.EndNodes(i, 2));
                y2 = p.YData(G.Edges.EndNodes(i, 2));

                % Project the click onto the edge line
                u = ((clickPosition(1) - x1) * (x2 - x1) + (clickPosition(2) - y1) * (y2 - y1)) / ...
                    ((x2 - x1)^2 + (y2 - y1)^2);

                % Clamp u to the range [0, 1]
                u = max(min(u, 1), 0);

                % Get the closest point on the edge line
                closestPoint = [x1 + u * (x2 - x1), y1 + u * (y2 - y1)];

                % Calculate distance from click to closest point on the edge
                distanceToEdge = norm(clickPosition - closestPoint);

                % Define a threshold for click detection (adjustable)
                threshold = 0.05;

                % Check if click is close enough to the edge
                if distanceToEdge < threshold
                    edgeClicked = true;
                    edgeIndex = i;
                    break;
                end
            end
        end


        function plot_CCG(app)
            t=linspace(-50,50,301);
            app.CCG_data = app.data.monosyn_data.CCG(:,app.row,app.col);
            bar(app.ImageAxes,t,app.CCG_data,'k')
            set (app.ImageAxes, 'xlim',[-10,10])
            %             hold(app.ImageAxes, 'on');
            xline(app.ImageAxes,0,'--b')
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

        end

        % Callback function
        function GenerateButtonPushed(app, event)
            %%%%%%%%%%% delected %%%%%%%%%%%%%%%%%%%


            % Get the size for the heatmap
            %             N = app.SizeEditField.Value;
            %             app.HeatmapData=rand(10);

            if app.StarkButton.Value==1
                %                 app.data.monosyn_data.connection_matrix.starkMatrix
                app.HeatmapData = app.data.monosyn_data.connection_matrix.starkMatrix;
            end
            if app.BzlabButton.Value==1
                %                 app.data.monosyn_data.connection_matrix.starkMatrix
                app.HeatmapData = app.data.monosyn_data.connection_matrix.BzlabMatrix;
            end

            if app.CoNNECTButton.Value==1
                app.HeatmapData = app.data.monosyn_data.connection_matrix.CoNNECTMatrix;
            end
            if app.GLMCCButton.Value==1
                app.HeatmapData = app.data.monosyn_data.connection_matrix.GLMCCMatrix;
            end


            % Generate random heatmap data
            plot_heatmap(app)


            %             heatmap(app.HeatmapAxes,rand(10));
            a=1;
            %             colorbar off

            %             h = heatmap(app.UIFigure,rand(10));
            %             h1.ButtonDownFcn = @(src, event) click_callback(src, event, N);
            %             set(app.UIFigure, 'ButtonDownFcn', @click_callback);


            % Function to handle click events
            %             function click_callback(src, event)
            %                 % Get the coordinates of the click
            %                 point = get(gca, 'CurrentPoint');
            %                 x = round(point(1, 1));
            %                 y = round(point(1, 2));
            %
            %                 % Ensure the coordinates are within bounds
            %                 if x >= 1 && x <= N && y >= 1 && y <= N
            %                     % Display the clicked coordinates
            %                     disp(['Clicked at: (', num2str(x), ', ', num2str(y), ')']);
            %
            %                     % Generate and display another image (random example)
            %                     generate_another_image(x, y);
            %                 end
            %
            %
            %             end

            % Plot the heatmap
            %             imagesc(app.HeatmapAxes, app.HeatmapData);
            %             colorbar(app.HeatmapAxes);

            % Set up callback for cell click
            %             app.HeatmapAxes.ButtonDownFcn = @(src, event) heatmapClickCallback(app, event);
        end

        % Button down function: HeatmapAxes, TagmapAxes
        function HeatmapAxesButtonDown(app, event)

            heatmapClickCallback(app, event)
            plot_graph(app)

        end

        % Callback function: LoadDataMenu, Load_data
        function Load_dataPushed(app, event)
            %             app.CheckviewLabel.Text='Waiting...';


            [filename,pathname] = uigetfile('*');
            fullpath = fullfile(pathname,filename);
            app.Data_path.Text=filename;
            app.data=load(fullpath);
%             MethodButtonGroupSelectionChanged(app, event)

            app.TagmapData=app.data.monosyn_data.tagmap;

            app.connection_matrix=app.data.monosyn_data.connection_matrix;
%             plot_heatmap(app)
%             plot_tagmap(app)
            %             plot_graph(app)

            Display(app,'Load data successfully')

            %             databasemaker2_2(fullpath);
            %             app.ego=data_tranform_RUI('cb.txt');
            %             app.CheckviewLabel.Text='Finished';
        end

        % Selection changed function: MethodButtonGroup
        function MethodButtonGroupSelectionChanged(app, event)
            selectedButton = app.MethodButtonGroup.SelectedObject;

            if strcmp(selectedButton.Text,'stark')
                app.HeatmapData = app.data.monosyn_data.connection_matrix.starkMatrix;
            end
            if strcmp(selectedButton.Text,'Bzlab')
                app.HeatmapData = app.data.monosyn_data.connection_matrix.BzlabMatrix;
            end
            if strcmp(selectedButton.Text,'GLMCC')
                app.HeatmapData = app.data.monosyn_data.connection_matrix.GLMCCMatrix;
            end
            if strcmp(selectedButton.Text,'CoNNECT')
                app.HeatmapData = app.data.monosyn_data.connection_matrix.CoNNECTMatrix;
            end

            plot_heatmap(app);
            % Display(app,['Load data successfully')

        end

        % Value changed function: ArtificialcheckDropDown
        function ArtificialcheckDropDownValueChanged(app, event)
            value = app.ArtificialcheckDropDown.Value;
            switch value
                case 'No tag'
                    app.TagmapData(app.row,app.col)=1;
                case 'Good'
                    app.TagmapData(app.row,app.col)=2;
                case 'Weak'
                    app.TagmapData(app.row,app.col)=3;
                case 'Bad'
                    app.TagmapData(app.row,app.col)=4;
            end
            plot_tagmap(app);
        end

        % Callback function: SaveDataMenu, Save_data
        function Save_dataButtonPushed(app, event)

            % Specify the filename for the .mat file
            filename = app.Data_path.Text;

            % Save the app.data into the specified .mat file
            monosyn_data = app.data.monosyn_data; % Assuming app.data contains the data you want to save
            save(filename, 'monosyn_data');

            % Optionally, you can display a message indicating the data has been saved
            Display(app,'Save data successfully')

        end

        % Button down function: GraphAxes
        function GraphAxesButtonDown(app, event)
            graphClickCallback(app,event)
        end

        % Callback function: Tree
        function TreeCheckedNodesChanged(app, event)
            checkedNodes = app.Tree.CheckedNodes;

            if isempty(checkedNodes)
                return
            end

            MethodText={app.Tree.CheckedNodes.Text};

            if length(MethodText)==5
                MethodText=MethodText(2:end);
            end


            if length(MethodText)==1
                if strcmp(checkedNodes.Text,'stark')
                    app.HeatmapData = app.data.monosyn_data.connection_matrix.starkMatrix;
                end
                if strcmp(checkedNodes.Text,'Bzlab')
                    app.HeatmapData = app.data.monosyn_data.connection_matrix.BzlabMatrix;
                end

                if strcmp(checkedNodes.Text,'GLMCC')
                    app.HeatmapData = app.data.monosyn_data.connection_matrix.GLMCCMatrix;
                end
                if strcmp(checkedNodes.Text,'CoNNECT')
                    app.HeatmapData = app.data.monosyn_data.connection_matrix.CoNNECTMatrix;
                end



            elseif length(MethodText)>1
                A=[];
                for i=1:length(MethodText)
                    A(:,:,i)=app.data.monosyn_data.connection_matrix.([MethodText{i},'Matrix']);
                end

                combinedMatrix = zeros(size(app.data.monosyn_data.connection_matrix.CoNNECTMatrix));

                combinedMatrix((min(A, [], 3) > 0)) = 1;

                app.HeatmapData=combinedMatrix;

            end

            plot_heatmap(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [1 1 1];
            app.UIFigure.Position = [100 100 1046 756];
            app.UIFigure.Name = 'MATLAB App';

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Tooltip = {'Load and Save Data'};
            app.FileMenu.Text = 'File';

            % Create LoadDataMenu
            app.LoadDataMenu = uimenu(app.FileMenu);
            app.LoadDataMenu.MenuSelectedFcn = createCallbackFcn(app, @Load_dataPushed, true);
            app.LoadDataMenu.Tooltip = {'Load data from a .mat file to analyze neuronal connections'};
            app.LoadDataMenu.Text = 'Load Data';

            % Create SaveDataMenu
            app.SaveDataMenu = uimenu(app.FileMenu);
            app.SaveDataMenu.MenuSelectedFcn = createCallbackFcn(app, @Save_dataButtonPushed, true);
            app.SaveDataMenu.Tooltip = {'Save the current data and analysis results to a .mat file.'};
            app.SaveDataMenu.Text = 'Save Data';

            % Create ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            title(app.ImageAxes, 'CCG')
            xlabel(app.ImageAxes, 'Time (ms)')
            ylabel(app.ImageAxes, 'Num')
            zlabel(app.ImageAxes, 'Z')
            app.ImageAxes.TitleFontWeight = 'normal';
            app.ImageAxes.Position = [241 456 350 183];

            % Create HeatmapAxes
            app.HeatmapAxes = uiaxes(app.UIFigure);
            xlabel(app.HeatmapAxes, 'Post-neuron')
            ylabel(app.HeatmapAxes, 'Pre-neuron')
            app.HeatmapAxes.XColor = [0 0 0];
            app.HeatmapAxes.XTick = [];
            app.HeatmapAxes.YTick = [];
            app.HeatmapAxes.LineWidth = 0.1;
            app.HeatmapAxes.Color = 'none';
            app.HeatmapAxes.FontSize = 14;
            app.HeatmapAxes.TitleFontWeight = 'normal';
            app.HeatmapAxes.GridColor = 'none';
            app.HeatmapAxes.MinorGridColor = 'none';
            app.HeatmapAxes.Box = 'on';
            app.HeatmapAxes.ButtonDownFcn = createCallbackFcn(app, @HeatmapAxesButtonDown, true);
            app.HeatmapAxes.Position = [232 15 394 352];

            % Create TagmapAxes
            app.TagmapAxes = uiaxes(app.UIFigure);
            xlabel(app.TagmapAxes, 'Post-neuron')
            app.TagmapAxes.XColor = [0 0 0];
            app.TagmapAxes.XTick = [];
            app.TagmapAxes.YTick = [];
            app.TagmapAxes.LineWidth = 0.1;
            app.TagmapAxes.Color = 'none';
            app.TagmapAxes.FontSize = 14;
            app.TagmapAxes.TitleFontWeight = 'normal';
            app.TagmapAxes.GridColor = [0.15 0.15 0.15];
            app.TagmapAxes.MinorGridColor = 'none';
            app.TagmapAxes.Box = 'on';
            app.TagmapAxes.ButtonDownFcn = createCallbackFcn(app, @HeatmapAxesButtonDown, true);
            app.TagmapAxes.Position = [635 17 394 350];

            % Create GraphAxes
            app.GraphAxes = uiaxes(app.UIFigure);
            title(app.GraphAxes, 'Connectivity graph of pre-neuron')
            zlabel(app.GraphAxes, 'Z')
            app.GraphAxes.TitleFontWeight = 'normal';
            app.GraphAxes.ButtonDownFcn = createCallbackFcn(app, @GraphAxesButtonDown, true);
            app.GraphAxes.Position = [603 366 425 384];

            % Create Load_data
            app.Load_data = uibutton(app.UIFigure, 'push');
            app.Load_data.ButtonPushedFcn = createCallbackFcn(app, @Load_dataPushed, true);
            app.Load_data.Tooltip = {'What will gonna happen, what should I load?'};
            app.Load_data.Position = [31 802 79 58];
            app.Load_data.Text = 'Load Data';

            % Create onepairconnectioncheckviewPanel
            app.onepairconnectioncheckviewPanel = uipanel(app.UIFigure);
            app.onepairconnectioncheckviewPanel.Tooltip = {'Results from different analysis methods'};
            app.onepairconnectioncheckviewPanel.Title = 'one-pair connection check view';
            app.onepairconnectioncheckviewPanel.BackgroundColor = [1 1 1];
            app.onepairconnectioncheckviewPanel.Position = [22 507 176 191];

            % Create Save_data
            app.Save_data = uibutton(app.UIFigure, 'push');
            app.Save_data.ButtonPushedFcn = createCallbackFcn(app, @Save_dataButtonPushed, true);
            app.Save_data.Tooltip = {'What will be saved if I clicked here?'};
            app.Save_data.Position = [136 802 79 58];
            app.Save_data.Text = 'Save Data';

            % Create PreNeuronEditFieldLabel
            app.PreNeuronEditFieldLabel = uilabel(app.UIFigure);
            app.PreNeuronEditFieldLabel.HorizontalAlignment = 'right';
            app.PreNeuronEditFieldLabel.Position = [-142 735 67 22];
            app.PreNeuronEditFieldLabel.Text = 'Pre-Neuron';

            % Create PreNeuronEditField
            app.PreNeuronEditField = uieditfield(app.UIFigure, 'numeric');
            app.PreNeuronEditField.Position = [-60 735 30 22];

            % Create Data_path
            app.Data_path = uilabel(app.UIFigure);
            app.Data_path.HorizontalAlignment = 'center';
            app.Data_path.FontSize = 14;
            app.Data_path.Position = [3 724 271 22];
            app.Data_path.Text = '';

            % Create Button4
            app.Button4 = uibutton(app.UIFigure, 'push');
            app.Button4.Position = [-130 703 100 23];
            app.Button4.Text = 'Button4';

            % Create PostNeuronEditFieldLabel
            app.PostNeuronEditFieldLabel = uilabel(app.UIFigure);
            app.PostNeuronEditFieldLabel.HorizontalAlignment = 'right';
            app.PostNeuronEditFieldLabel.Position = [-142 679 72 22];
            app.PostNeuronEditFieldLabel.Text = 'Post-Neuron';

            % Create PostNeuronEditField
            app.PostNeuronEditField = uieditfield(app.UIFigure, 'numeric');
            app.PostNeuronEditField.Position = [-55 679 30 22];

            % Create starkLabel
            app.starkLabel = uilabel(app.UIFigure);
            app.starkLabel.Tooltip = {'Results from different analysis methods'};
            app.starkLabel.Position = [48 640 31 22];
            app.starkLabel.Text = 'stark';

            % Create Stark_CheckBox
            app.Stark_CheckBox = uicheckbox(app.UIFigure);
            app.Stark_CheckBox.Tooltip = {'Results from different analysis methods'};
            app.Stark_CheckBox.Text = '';
            app.Stark_CheckBox.Position = [154 641 26 22];

            % Create StarkEditField
            app.StarkEditField = uieditfield(app.UIFigure, 'numeric');
            app.StarkEditField.Tooltip = {'Results from different analysis methods'};
            app.StarkEditField.Position = [101 640 43 22];

            % Create PreNeuronvsPostNeuronLabel
            app.PreNeuronvsPostNeuronLabel = uilabel(app.UIFigure);
            app.PreNeuronvsPostNeuronLabel.Tooltip = {'Displays the IDs of the current pre-neuron and post-neuron'};
            app.PreNeuronvsPostNeuronLabel.Position = [263 660 156 22];
            app.PreNeuronvsPostNeuronLabel.Text = 'Pre-Neuron vs Post-Neuron:';

            % Create click_neuron_pairs
            app.click_neuron_pairs = uilabel(app.UIFigure);
            app.click_neuron_pairs.HorizontalAlignment = 'center';
            app.click_neuron_pairs.Tooltip = {'Cross-correlogram (CCG) plot showing the temporal relationship between the pre-neuron and post-neuron'};
            app.click_neuron_pairs.Position = [413 660 78 22];
            app.click_neuron_pairs.Text = 'Pairs';

            % Create ArtificialcheckDropDown
            app.ArtificialcheckDropDown = uidropdown(app.UIFigure);
            app.ArtificialcheckDropDown.Items = {'No tag', 'Good', 'Weak', 'Bad'};
            app.ArtificialcheckDropDown.ValueChangedFcn = createCallbackFcn(app, @ArtificialcheckDropDownValueChanged, true);
            app.ArtificialcheckDropDown.Tooltip = {'Assign a tag to the selected neuron pair (e.g., Good, Weak, Bad). Matrix showing tagged connections between pre-neurons and post-neurons, categorized by tag'};
            app.ArtificialcheckDropDown.Position = [499 660 100 22];
            app.ArtificialcheckDropDown.Value = 'No tag';

            % Create BzlabLabel
            app.BzlabLabel = uilabel(app.UIFigure);
            app.BzlabLabel.Tooltip = {'Results from different analysis methods'};
            app.BzlabLabel.Position = [46 611 35 22];
            app.BzlabLabel.Text = 'Bzlab';

            % Create Bzlab_CheckBox
            app.Bzlab_CheckBox = uicheckbox(app.UIFigure);
            app.Bzlab_CheckBox.Tooltip = {'Results from different analysis methods'};
            app.Bzlab_CheckBox.Text = '';
            app.Bzlab_CheckBox.Position = [154 612 26 22];

            % Create BzlabEditField
            app.BzlabEditField = uieditfield(app.UIFigure, 'numeric');
            app.BzlabEditField.Tooltip = {'Results from different analysis methods'};
            app.BzlabEditField.Position = [101 611 43 22];

            % Create GLMCCLabel
            app.GLMCCLabel = uilabel(app.UIFigure);
            app.GLMCCLabel.Tooltip = {'Results from different analysis methods'};
            app.GLMCCLabel.Position = [39 582 48 22];
            app.GLMCCLabel.Text = 'GLMCC';

            % Create GLMCC_CheckBox
            app.GLMCC_CheckBox = uicheckbox(app.UIFigure);
            app.GLMCC_CheckBox.Tooltip = {'Results from different analysis methods'};
            app.GLMCC_CheckBox.Text = '';
            app.GLMCC_CheckBox.Position = [154 583 26 22];

            % Create GLMCCEditField
            app.GLMCCEditField = uieditfield(app.UIFigure, 'numeric');
            app.GLMCCEditField.Tooltip = {'Results from different analysis methods'};
            app.GLMCCEditField.Position = [101 582 43 22];

            % Create CoNNECTLabel
            app.CoNNECTLabel = uilabel(app.UIFigure);
            app.CoNNECTLabel.Tooltip = {'Results from different analysis methods'};
            app.CoNNECTLabel.Position = [32 553 62 22];
            app.CoNNECTLabel.Text = 'CoNNECT';

            % Create CoNNECT_CheckBox
            app.CoNNECT_CheckBox = uicheckbox(app.UIFigure);
            app.CoNNECT_CheckBox.Tooltip = {'Results from different analysis methods'};
            app.CoNNECT_CheckBox.Text = '';
            app.CoNNECT_CheckBox.Position = [154 554 26 22];

            % Create CoNNECTEditField
            app.CoNNECTEditField = uieditfield(app.UIFigure, 'numeric');
            app.CoNNECTEditField.Tooltip = {'Results from different analysis methods'};
            app.CoNNECTEditField.Position = [101 553 43 22];

            % Create Tree
            app.Tree = uitree(app.UIFigure, 'checkbox');
            app.Tree.Tooltip = {'Select the methods to include in the analysis'};
            app.Tree.Position = [24 311 176 146];

            % Create MethodsNode
            app.MethodsNode = uitreenode(app.Tree);
            app.MethodsNode.Text = 'Methods';

            % Create starkNode
            app.starkNode = uitreenode(app.MethodsNode);
            app.starkNode.Text = 'stark';

            % Create BzlabNode
            app.BzlabNode = uitreenode(app.MethodsNode);
            app.BzlabNode.Text = 'Bzlab';

            % Create GLMCCNode
            app.GLMCCNode = uitreenode(app.MethodsNode);
            app.GLMCCNode.Text = 'GLMCC';

            % Create CoNNECTNode
            app.CoNNECTNode = uitreenode(app.MethodsNode);
            app.CoNNECTNode.Text = 'CoNNECT';

            % Assign Checked Nodes
            app.Tree.CheckedNodesChangedFcn = createCallbackFcn(app, @TreeCheckedNodesChanged, true);

            % Create DisplayWindowLabel
            app.DisplayWindowLabel = uilabel(app.UIFigure);
            app.DisplayWindowLabel.Tooltip = {'Displays the current status or result of an action'};
            app.DisplayWindowLabel.Position = [27 218 130 71];
            app.DisplayWindowLabel.Text = 'DisplayWindowLabel';

            % Create MethodButtonGroup
            app.MethodButtonGroup = uibuttongroup(app.UIFigure);
            app.MethodButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @MethodButtonGroupSelectionChanged, true);
            app.MethodButtonGroup.TitlePosition = 'righttop';
            app.MethodButtonGroup.Title = 'Method          ';
            app.MethodButtonGroup.Position = [-222 556 211 144];

            % Create StarkButton
            app.StarkButton = uiradiobutton(app.MethodButtonGroup);
            app.StarkButton.Text = 'Stark';
            app.StarkButton.Position = [113 93 50 22];
            app.StarkButton.Value = true;

            % Create BzlabButton
            app.BzlabButton = uiradiobutton(app.MethodButtonGroup);
            app.BzlabButton.Text = 'Bzlab';
            app.BzlabButton.Position = [113 64 52 22];

            % Create GLMCCButton
            app.GLMCCButton = uiradiobutton(app.MethodButtonGroup);
            app.GLMCCButton.Text = 'GLMCC';
            app.GLMCCButton.Position = [113 35 66 22];

            % Create CoNNECTButton
            app.CoNNECTButton = uiradiobutton(app.MethodButtonGroup);
            app.CoNNECTButton.Text = 'CoNNECT';
            app.CoNNECTButton.Position = [113 7 79 22];

            % Create Hyperlink
            app.Hyperlink = uihyperlink(app.UIFigure);
            app.Hyperlink.Tooltip = {'Open the GitHub repository for more information or help'};
            app.Hyperlink.URL = 'https://github.com/SSSRgo/Neural_Monosynaptic_Connection_GUI';
            app.Hyperlink.Position = [41 104 31 22];
            app.Hyperlink.Text = 'Help';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [4 2 100 100];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'logo.png');

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create Menu
            app.Menu = uimenu(app.ContextMenu);
            app.Menu.Text = 'Menu';

            % Create Menu2
            app.Menu2 = uimenu(app.ContextMenu);
            app.Menu2.Text = 'Menu2';
            
            % Assign app.ContextMenu
            app.UIFigure.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MonoSynapticConnection_APP_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

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