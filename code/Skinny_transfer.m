dataDir= './data/wallpapers/';
checkpointDir = 'modelCheckpoints_skinny_transfer_transferLearn';

rng(1) % For reproducibility
Symmetry_Groups = {'P1', 'P2', 'PM' ,'PG', 'CM', 'PMM', 'PMG', 'PGG', 'CMM',...
    'P4', 'P4M', 'P4G', 'P3', 'P3M1', 'P31M', 'P6', 'P6M'};

% train_folder = 'train';
% test_folder  = 'test';
% uncomment after you create the augmentation dataset
train_folder = 'train';
test_folder  = 'test';
fprintf('Loading Train Filenames and Label Data...'); t = tic;
train_all = imageDatastore(fullfile(dataDir,train_folder),'IncludeSubfolders',true,'LabelSource',...
    'foldernames');
train_all.Labels = reordercats(train_all.Labels,Symmetry_Groups);
% Split with validation set
[train, val] = splitEachLabel(train_all,.9);
fprintf('Done in %.02f seconds\n', toc(t));

fprintf('Loading Test Filenames and Label Data...'); t = tic;
test = imageDatastore(fullfile(dataDir,test_folder),'IncludeSubfolders',true,'LabelSource',...
    'foldernames');
test.Labels = reordercats(test.Labels,Symmetry_Groups);
fprintf('Done in %.02f seconds\n', toc(t));

%%
rng('default');
numEpochs = 5; % 5 for both learning rates
batchSize = 32;
nTraining = length(train.Labels);

% Define the Network Structure, To add more layers, copy and paste the
% lines such as the example at the bottom of the code
%  CONV -> ReLU -> POOL -> FC -> DROPOUT -> FC -> SOFTMAX 
% layers = [
%     imageInputLayer([128 128 1]); % Input to the network is a 256x256x1 sized image 
%     convolution2dLayer(5,40,'Padding',[2 2],'Stride', [1,1]);  % convolution layer with 20, 5x5 filters
%     reluLayer();  % ReLU layer
%     maxPooling2dLayer(2,'Stride',2); % Max pooling layer
%     convolution2dLayer(5,40,'Padding',[1 1],'Stride', [1,1]);  % convolution layer with 20, 5x5 filters
%     reluLayer();  % ReLU layer
%     maxPooling2dLayer(2,'Stride',2); % Max pooling layer
%     convolution2dLayer(3,80,'Padding',[1 1],'Stride', [1,1]);  % convolution layer with 20, 5x5 filters
%     reluLayer();  % ReLU layer
%     maxPooling2dLayer(2,'Stride',2); % Max pooling layer
% 
%     fullyConnectedLayer(100); % Fullly connected layer with 50 activations
%     dropoutLayer(.25); % Dropout layer
%     fullyConnectedLayer(17); % Fully connected with 17 layers
%     softmaxLayer(); % Softmax normalization layer
%     classificationLayer(); % Classification layer
%     ];


if ~exist(checkpointDir,'dir'); mkdir(checkpointDir); end
% Set the training options
options = trainingOptions('sgdm','MaxEpochs',20,... 
    'InitialLearnRate',1e-3,...% learning rate
    'CheckpointPath', checkpointDir,...
    'MiniBatchSize', batchSize, ...
    'MaxEpochs',numEpochs);
    % uncommand and add the line below to the options above if you have 
    % version 17a or above to see the learning in realtime
    %'OutputFcn',@plotTrainingAccuracy,... 

% Train the network, info contains information about the training accuracy
% and loss


 t = tic;
[net1,info1] = trainNetwork(train,net.Layers,options);
fprintf('Trained in in %.02f seconds\n', toc(t));


%%
% Test on the training data
YTrain = classify(net1,train);
train_acc = mean(YTrain==train.Labels)

train_conf_mat = confusionmat(sort(grp2idx(train.Labels)), sort(grp2idx(YTrain)));
train_class_mat = train_conf_mat./meshgrid(countcats(train.Labels)');

filename = strcat('Sk_transfer_Train_confusion_matrix_',num2str(numEpochs),'.xlsx');
xlswrite(filename, train_conf_mat,1,'A1');

filename = strcat('Sk_transfer_Train_classification_matrix_',num2str(numEpochs),'.xlsx');
xlswrite(filename, train_class_mat,1,'A1');

% Test on the validation data
YVal = classify(net1,val);
val_acc = mean(YVal==val.Labels)

val_conf_mat = confusionmat(sort(grp2idx(val.Labels)), sort(grp2idx(YVal)));
val_class_mat = val_conf_mat./meshgrid(countcats(val.Labels)');

filename = strcat('Sk_transfer_Validation_confusion_matrix_',num2str(numEpochs),'.xlsx');
xlswrite(filename, val_conf_mat,1,'A1');

filename = strcat('Sk_transfer_Validation_classification_matrix_',num2str(numEpochs),'.xlsx');
xlswrite(filename, val_class_mat,1,'A1');

% Test on the testing data
YTest = classify(net1,test);
test_acc = mean(YTest==test.Labels)

test_conf_mat = confusionmat(sort(grp2idx(test.Labels)), sort(grp2idx(YTest)));
test_class_mat = test_conf_mat./meshgrid(countcats(test.Labels)');

filename = strcat('Sk_transfer_Test_confusion_matrix_',num2str(numEpochs),'.xlsx');
xlswrite(filename, test_conf_mat,1,'A1');

filename = strcat('Sk_transfer_Test_classification_matrix_',num2str(numEpochs),'.xlsx');
xlswrite(filename, test_class_mat,1,'A1');

f=figure;
plotTrainingAccuracy_All(info1,numEpochs);
saveas(f,'Sk_transfer_Skinny_10Epoc.png');

% It seems like it isn't converging after looking at the graph but lets
%   try dropping the learning rate to show you how.  

% options = trainingOptions('sgdm','MaxEpochs',20,...
%     'InitialLearnRate',1e-4,... % learning rate
%     'CheckpointPath', checkpointDir,...
%     'MiniBatchSize', batchSize, ...
%     'MaxEpochs',numEpochs);
%     % uncommand and add the line below to the options above if you have 
%     % version 17a or above to see the learning in realtime
% %     'OutputFcn',@plotTrainingAccuracy,...
% 
%  t = tic;
% [net2,info2] = trainNetwork(train,net1.Layers,options);
% fprintf('Trained in in %.02f seconds\n', toc(t));
% 
% % Test on the validation data
% YTest = classify(net2,val);
% val_acc = mean(YTest==val.Labels)
% 
% 
% % Test on the Testing data
% YTest = classify(net2,test);
% test_acc = mean(YTest==test.Labels)
% 
% plotTrainingAccuracy_All(info2,numEpochs);

% It seems like continued training would improve the scores


%%  Example of adding more layers

% here we add another set of "CONV -> ReLU -> POOL ->" to make the network:
% CONV -> ReLU -> POOL -> CONV -> ReLU -> POOL -> FC -> DROPOUT -> FC -> SOFTMAX 
% layers = [
%     imageInputLayer([256 256 1]); % Input to the network is a 256x256x1 sized image 
%     convolution2dLayer(5,20,'Padding',[2 2],'Stride', [1,1]);  % convolution layer with 20, 5x5 filters
%     reluLayer();  % ReLU layer
%     maxPooling2dLayer(2,'Stride',2); % Max pooling layer
%     convolution2dLayer(3,40,'Padding',[1 1],'Stride', [1,1]);  % convolution layer with 20, 5x5 filters
%     reluLayer();  % ReLU layer
%     maxPooling2dLayer(2,'Stride',2); % Max pooling layer
%     fullyConnectedLayer(25); % Fullly connected layer with 50 activations
%     dropoutLayer(.25); % Dropout layer
%     fullyConnectedLayer(17); % Fully connected with 17 layers
%     softmaxLayer(); % Softmax normalization layer
%     classificationLayer(); % Classification layer
%     ];
 
%% Visualization using DeepDreamImage

channel2 = net1.Layers(2,1).NumFilters;

I2 = deepDreamImage(net1,2,channel2,'PyramidLevels',1);

figure;
montage(I2);
title('First Convolutional Layer visualisation for Skinny Aug');
