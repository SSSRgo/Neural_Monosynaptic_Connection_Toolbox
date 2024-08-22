% generate_GUI_data                 
% to generated data used for gui. 
% It will readout 2 results of GLMCC and CoNNECT methods from ./detection_result folder
% , compute 1 result by stark's lab method, and retrive 1 result of
% buzsaki's lab data structure
%
% 12-Aug-24 rui shen, mursel karadas, yiyao zhang

set(0, 'DefaultLineLineWidth', 3);
set(0,'defaultTextFontSize', 10);
set(0,'defaultAxesFontSize',10);
set(0,'defaultfigurecolor',[1 1 1])
set(0,'DefaultAxesTitleFontWeight', 'normal')
addpath(genpath('G:\.shortcut-targets-by-id\15VUj8SjiotBS2_A46-lt6ibycakPHBwb\ACh_OXT_Analysis\buzcode-dev'));

% LOAD currated connections
% clear all
addpath('CCH-deconvolution-main');
addpath('matlab_colormaps-master');
ses_name = 'ACh_OXT004_012';
ses_mat = dir(['../../Opto_activation/', ses_name, '*.CellData.mat']);
load(fullfile(ses_mat.folder,ses_mat.name));
    
if exist('Data', 'var') == 1
    disp('File loaded successfully');
else
    disp('Failed to load file');
end

% control
sess_spikes_control         = Data.Cell_info.All.spikes.times;
connections_control         = Data.MonosynConn.mono_res_ExoptoACT.sig_con;

%manipulation
sess_spikes_manipulation    = Data.Cell_info.All_optoACT.spikes.times;
connections_manipulation    = Data.MonosynConn.mono_res_optoACT.sig_con;

sess_control        = calculate_monosynaptic_params(sess_spikes_control );

% [a,b]=find(Data.MonosynConn.mono_res_ExoptoACT.Pcausal>0.9999999)

%% Load or define your matrices
% starkMatrix = rand(10); % Replace with your actual matrix data
% GLMCCMatrix = rand(10); % Replace with your actual matrix data
% CoNNECTMatrix = rand(10); % Replace with your actual matrix data

StarkMatrix=sess_control.eSTG;
BzlabMatrix = Data.MonosynConn.mono_res_ExoptoACT.Pcausal;
GLMCCMatrix = readmatrix('.\detection_result\result_GLMCC.csv');
CoNNECTMatrix = readmatrix('.\detection_result\result_CoNNECT.csv');

StarkMatrix(isnan(StarkMatrix))=0;
BzlabMatrix(isnan(BzlabMatrix))=0;
GLMCCMatrix(isnan(GLMCCMatrix))=0;
CoNNECTMatrix(isnan(CoNNECTMatrix))=0;

StarkMatrix(logical(diag(ones(1,length(BzlabMatrix)))))=0;
BzlabMatrix(logical(diag(ones(1,length(BzlabMatrix)))))=0;
GLMCCMatrix(logical(diag(ones(1,length(BzlabMatrix)))))=0;
CoNNECTMatrix(logical(diag(ones(1,length(BzlabMatrix)))))=0;

% GLMCCMatrix = readmatrix('.\connection_result_threeMethods\W_py_5400_default.csv');
% CoNNECTMatrix = readmatrix('.\connection_result_threeMethods\estimated_default.csv');

BzlabMatrix(find(Data.MonosynConn.mono_res_ExoptoACT.Pcausal<0.999))=0;

GLMCCMatrix=flipud(GLMCCMatrix);
GLMCCMatrix=rot90(GLMCCMatrix,3);

%% determine connection matrix based on these methods
connection_matrix=zeros(length(BzlabMatrix),length(BzlabMatrix),4);
% connection_matrix(:,:,1)=


%%


CCG=Data.MonosynConn.mono_res.ccgR;
CCG_reversed = flip(CCG, 1);
monosyn_data.CCG=CCG_reversed;
monosyn_data.tagmap=ones(length(BzlabMatrix));



monosyn_data.connection_matrix.BzlabMatrix=double(BzlabMatrix>0);
monosyn_data.connection_matrix.starkMatrix=double(StarkMatrix>0.01);
monosyn_data.connection_matrix.CoNNECTMatrix=double(CoNNECTMatrix>0);
monosyn_data.connection_matrix.GLMCCMatrix=double(abs(GLMCCMatrix)>0);

monosyn_data.weight_matrix.BzlabMatrix=BzlabMatrix;
monosyn_data.weight_matrix.starkMatrix=StarkMatrix;
monosyn_data.weight_matrix.CoNNECTMatrix=CoNNECTMatrix;
monosyn_data.weight_matrix.GLMCCMatrix=GLMCCMatrix;

save(strcat(ses_name,'_monosyn_data','.mat'),'monosyn_data');

% 
% % len=20;
% % starkMatrix=starkMatrix(1:len,1:len);
% % CoNNECTMatrix=CoNNECTMatrix(1:len,1:len);
% % GLMCCMatrix=GLMCCMatrix(1:len,1:len);
% 
% %%
% corrcoef(CoNNECTMatrix,BzlabMatrix)
% corrcoef(CoNNECTMatrix,GLMCCMatrix)
% 
% % Create a new figure
% figure;
% 
% % Define the position for each subplot to make them square
% subplotPosition = [0.05, 0.15, 0.25, 0.25*1200/450]; % [left, bottom, width, height]
% 
% 
% % Heatmap for Stark method
% subplot('Position', subplotPosition);
% heatmap(BzlabMatrix);
% title('Stark Method');
% % xlabel('Columns');
% % ylabel('Rows');
% colormap('hot');
% % colorbar;
% 
% % Heatmap for GLMCC method
% subplot('Position', [0.35, 0.15, 0.25, 0.25*1200/450]); % Adjust left position
% heatmap(GLMCCMatrix);
% title('GLMCC Method');
% % xlabel('Columns');
% % ylabel('Rows');
% colormap('hot');
% colorbar;
% 
% % Heatmap for CoNNECT method
% subplot('Position', [0.65, 0.15, 0.25, 0.25*1200/450]); % Adjust left position
% heatmap(CoNNECTMatrix);
% title('CoNNECT Method');
% % xlabel('Columns');
% % ylabel('Rows');
% colormap('hot');
% % colorbar;
% 
% % Adjust the overall title
% sgtitle('Comparison of Neural Monoconnection Matrices');
% 
% % Display the figure
% set(gcf, 'Position', [100, 100, 1200, 450]); % Adjust the figure size

% LOCAL FUNCTIONS
function sess = calculate_monosynaptic_params(sess_spikes )                 
    Nconnections = length(sess_spikes);
    %% Use Eran Stark Lab deconvolution based method to get the dCCH and eSTG
    % global variables
    spkFs = 2e4;
    % parameters for CCH computations
    binSize                         = 0.001;                                    % [s]
    halfSize                        = 0.04;                                      % [s]
    W                               = 11;                                       % [samples]
    % constants for STG computations
    roiMS                           = [ NaN 5 ]; 
    convType                        = 'median';
    hollowF                         = 1; 
    
    sess = [];
    for  conid = 1:Nconnections
        for conid1 = 1:Nconnections
        cell1 = sess_spikes{conid}*spkFs;
        cell2 = sess_spikes{conid1}*spkFs;
        label = [ones(size(cell1,1),1)*1; ones(size(cell2,1),1)*2];
        T = [cell1;cell2];
    
        spkT                            = T;
        spkL                            = label;
        spkFS                           =spkFs;
    
        %-------------------------------------------------------------------------------------
        % 2.1. compute eSTGs from dcCCH for all pairs
        [ eSTG1, eSTG2, act, sil, dcCCH, crCCH, cchbins ] = call_cch_stg( spkT, spkL, spkFS, binSize, halfSize, W );
    
        Gsub                            = unique( spkL );
        bs                              = length( Gsub ) - 1;
    
        u1                              = 1;
        u2                              = 2;
        cidx                            = ( u2 - 1 ) * bs + u1;
        t                               = cchbins * 1000;                           % [ms]
        dt                              = diff( cchbins( 1 : 2 ) );                 % [s]
        if isnan( roiMS( 1 ) )
            roiMS( 1 )                  = ( dt * 1000 ) / 2;                        % causality imposed
        end

        t_ROI                           = t >= roiMS( 1 ) & t <= roiMS( 2 );
        [ g1, g2 ]                              = calc_stg( crCCH, t_ROI, dt ,0);
%         sess.dcCCH(conid,conid1,:,:) = dcCCH;
%         sess.eSTG(conid,conid1,:) = g1(2);
%         sess.crCCH(conid,conid1,:) = crCCH(:,cidx);
%         sess.cchbins = cchbins*1e3;
%         sess.act(conid,conid1,:) = act(cidx);
%         sess.sil(conid,conid1,:) = sil(cidx);

        sess.dcCCH(conid1,conid,:,:) = dcCCH;
        sess.eSTG(conid1,conid,:) = eSTG1(2);
        sess.neSTG(conid1,conid,:) = eSTG2(2);
        sess.crCCH(conid1,conid,:) = crCCH(:,cidx);
        sess.cchbins = cchbins*1e3;
        sess.act(conid1,conid,:) = act(cidx);
        sess.sil(conid1,conid,:) = sil(cidx);
        
    
        end
    end

end




