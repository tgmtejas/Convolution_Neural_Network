clc;
clear all;
close all;

dataDir= './data/wallpapers/';
checkpointDir = 'modelCheckpoints/alexnet';

rng(1) % For reproducibility
Symmetry_Groups = {'P1', 'P2', 'PM' ,'PG', 'CM', 'PMM', 'PMG', 'PGG', 'CMM',...
    'P4', 'P4M', 'P4G', 'P3', 'P3M1', 'P31M', 'P6', 'P6M'};

%train_folder = 'train';
%test_folder  = 'test';
% uncomment after you create the augmentation dataset
train_folder = 'train_alex';
test_folder  = 'test_alex';
fprintf('Loading Train Filenames and Label Data...'); t = tic;
train_all = imageDatastore(fullfile(dataDir,train_folder),'IncludeSubfolders',true,'LabelSource',...
    'foldernames');
train_all.Labels = reordercats(train_all.Labels,Symmetry_Groups);


%%
% Split with validation set
[train, val] = splitEachLabel(train_all,.9);
fprintf('Done in %.02f seconds\n', toc(t));

fprintf('Loading Test Filenames and Label Data...'); t = tic;
test = imageDatastore(fullfile(dataDir,test_folder),'IncludeSubfolders',true,'LabelSource',...
    'foldernames');
test.Labels = reordercats(test.Labels,Symmetry_Groups);
fprintf('Done in %.02f seconds\n', toc(t));

%% Alexnet Training
rng('default');
numEpochs = 10; % 10 for both learning rates
batchSize = 100;
nTraining = length(train.Labels);
net = alexnet;
layerTransfer = net.Layers(1:end-3);
layers = [
  layerTransfer;
  fullyConnectedLayer(17,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20); % Fully connected with 17 layers
  softmaxLayer(); % Softmax normalization layer
  classificationLayer(); % Classification layer
];
if ~exist(checkpointDir,'dir'); mkdir(checkpointDir); end

options = trainingOptions('sgdm','MaxEpochs',25,... 
    'InitialLearnRate',5e-4,...% learning rate
    'CheckpointPath', checkpointDir,...
    'MiniBatchSize', batchSize, ...
    'MaxEpochs',numEpochs);

 t = tic;
[net1,info1] = trainNetwork(train,layers,options);
fprintf('Trained in in %.02f seconds\n', toc(t));

error_plot = figure;
plotTrainingAccuracy_All(info1,numEpochs);
saveas(error_plot, ['Alexnet Error plot for epoch 10', num2str(numEpochs), '.png']);


% Test on the training data
YTrain = classify(net1,train);
train_acc = mean(YTrain==train.Labels);

train_con_mat = confusionmat(sort(grp2idx(train.Labels)), sort(grp2idx(YTrain)));
train_class_mat = train_con_mat./(meshgrid(countcats(train.Labels))');

filename = ['AlexNet_Train_Confusion_Mat_', num2str(numEpochs), '.xlsx'];
xlswrite(filename, train_con_mat,'Sheet1','A1');

filename = ['AlexNet_Train_Classification_Mat_', num2str(numEpochs), '.xlsx'];
xlswrite(filename, train_class_mat,'Sheet1','A1');



% Test on the validation data
YVal = classify(net1,val);
val_acc = mean(YVal==val.Labels);

val_con_mat = confusionmat(sort(grp2idx(val.Labels)), sort(grp2idx(YVal)));
val_class_mat = val_con_mat./(meshgrid(countcats(val.Labels))');

filename = ['AlexNet_Val_Confusion_Mat_', num2str(numEpochs), '.xlsx'];
xlswrite(filename, val_con_mat,'Sheet1','A1');

filename = ['AlexNet_Val_Classification_Mat_', num2str(numEpochs), '.xlsx'];
xlswrite(filename, val_class_mat,'Sheet1','A1');

% Test on the Test data
YTest = classify(net1,test);
test_acc = mean(YTest==test.Labels);

test_con_mat = confusionmat(sort(grp2idx(test.Labels)), sort(grp2idx(YTest)));
test_class_mat = test_con_mat./(meshgrid(countcats(test.Labels))');

filename = ['AlexNet_Test_Confusion_Mat_', num2str(numEpochs), '.xlsx'];
xlswrite(filename, test_con_mat,'Sheet1','A1');

filename = ['AlexNet_Test_Classification_Mat_', num2str(numEpochs), '.xlsx'];
xlswrite(filename, test_class_mat,'Sheet1','A1');

%% Visualization using DeepDreamImage

channel2 = net1.Layers(2,1).NumFilters;

I2 = deepDreamImage(net1,2,channel2,'PyramidLevels',1);

figure;
montage(I2);
title('First Convolutional Layer visualisation');