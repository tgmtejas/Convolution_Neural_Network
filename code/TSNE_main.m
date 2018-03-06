clc;
clear all;
close all;

% plotting t-SNE visualization of fc layer activations 

%% load trained networks 
% load workspace_wide.mat 
% load workspace_skinny.mat
% load data & labels 
dataDir= './data/wallpapers/';
checkpointDir = 'modelCheckpoints_tsne';

rng(1) % For reproducibility
Symmetry_Groups = {'P1', 'P2', 'PM' ,'PG', 'CM', 'PMM', 'PMG', 'PGG', 'CMM',...
    'P4', 'P4M', 'P4G', 'P3', 'P3M1', 'P31M', 'P6', 'P6M'};

%train_folder = 'train';
%test_folder  = 'test';
% uncomment after you create the augmentation dataset
 train_folder = 'train_aug';
 test_folder  = 'test_aug';
fprintf('Loading Train Filenames and Label Data...'); t = tic;
train_all = imageDatastore(fullfile(dataDir,train_folder),'IncludeSubfolders',true,'LabelSource',...
    'foldernames');
train_all.Labels = reordercats(train_all.Labels,Symmetry_Groups);
%% Split with validation set
[train, val] = splitEachLabel(train_all,.9);
fprintf('Done in %.02f seconds\n', toc(t));

fprintf('Loading Test Filenames and Label Data...'); t = tic;
test = imageDatastore(fullfile(dataDir,test_folder),'IncludeSubfolders',true,'LabelSource',...
    'foldernames');
test.Labels = reordercats(test.Labels,Symmetry_Groups);
fprintf('Done in %.02f seconds\n', toc(t));

%% Visualization training
features_train = activations(net1,train,'fc_1');
features_test = activations(net1,test,'fc_1');
features_val = activations(net1,val,'fc_1');

y_train = tsne(features_train,'Standardize',true);

h1=figure();
gscatter(y_train(:,1),y_train(:,2),train.Labels(:));
xlabel('feature 1');
ylabel('feature 2');
saveas(h1,['tSNE_visualization_train.png']);


y_test = tsne(features_test,'Standardize',true);

h2=figure();
gscatter(y_test(:,1),y_test(:,2),test.Labels(:));
xlabel('feature 1');
ylabel('feature 2');
saveas(h2,['tSNE_visualization_test.png']);


y_val = tsne(features_val,'Standardize',true);

h3=figure();
gscatter(y_val(:,1),y_val(:,2),val.Labels(:));
xlabel('feature 1');
ylabel('feature 2');
saveas(h3,['tSNE_visualization_val.png']);

