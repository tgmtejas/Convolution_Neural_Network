clc;
mkdir('data\wallpapers', 'train_alex')

str =["P1", "P2", "PM" ,"PG", "CM", "PMM", "PMG", "PGG", "CMM", "P4", "P4M", "P4G", "P3", "P3M1", "P31M", "P6", "P6M"];
szdim = size(str,2);


for i = 1: szdim
    
    %subfolder = str{i};
    dirpath = strcat('data\wallpapers\Train\', str{i});
    mkdir('data\wallpapers\train_alex\', str{i})
    dirpath2 = strcat('data\wallpapers\train_alex\');
    p= strcat(dirpath,'\*.png');

    imagefiles = dir(p);      
    numfiles = length(imagefiles);
    %q =imagefiles(1)

    for j=1:numfiles
        currentfilename = strcat(imagefiles(j).folder, '\',imagefiles(j).name);
        
        I = imread(currentfilename);
        %I = imresize(I, 0.5);
        %t= strcat(dirpath2, "\", str{i}, "\", str{i}, "_",int2str(j), ".png");
        %imwrite(I, char(t));
        
        for k =1 :5
            
            %imwrite(im_aug, dirpath2 , s);
            [im_aug,rot_angle,scale_ratio, tran_out] = augmentImage(I);
            
            im_out = imresize(im_aug,[227, 227]); 
            im_out_rgb = repmat(im_out,[1,1,3]);
            s= strcat(dirpath2, "\", str{i}, "\", str{i}, "_",int2str(j),"_", int2str(k), ".png");
            imwrite(im_out_rgb, char(s));
            
        end
       
    end

end

 

% for i = 1: len()
% intermediate_dir = strcat()
% 
% 
% 
% srcFiles = dir('E:\New Folder\IM_*.dcm');
% for i = 1 : length(srcfiles)
%   filename = strcat('E:\New Folder\',srcFiles(i).name);
%   I = dicomread(filename);
%   figure, imshow(I);
% end


%% Exporting data to Excel

filename = 'Augmentation_data.xlsx';

col_header={'Rotation','Scaling','Trans (x)', 'Trans (y)'};
xlswrite(filename,col_header,'Sheet1','A1');   
xlswrite(filename, aug_data.rot_angle,'Sheet1','A2');
xlswrite(filename, aug_data.scale_ratio,'Sheet1','B2');
xlswrite(filename, aug_data.tran_out(:,1),'Sheet1','C2');
xlswrite(filename, aug_data.tran_out(:,2),'Sheet1','D2');

%% Plotting Rotation angle statistics

rotation_plot = figure;
histogram(aug_data.rot_angle, 'BinWidth', 1, 'facecolor',[0.4 0.6 0.4]);
grid on;
xlabel('Angle of Rotation');
ylabel('No. of Images');
saveas(rotation_plot, 'Histogram of Rotations.png');

%% Plotting Translation statistics

translation_plot = figure;
hist3(aug_data.tran_out, 'facecolor',[0.4 0.6 0.4]);
grid on;
x = xlabel('Translation in x direction', 'Rotation',15);
set(x, 'Units', 'Normalized', 'Position', [0.75, 0.02, 0]);
y = ylabel('Translation in y direction', 'Rotation',-25);
set(y, 'Units', 'Normalized', 'Position', [0.15, 0.05, 0]);
zlabel('No. of Images');
saveas(translation_plot, 'Histogram of translation.png');

%% Plotting Scale Ratio statistics

scale_plot = figure;
histogram(aug_data.scale_ratio, 20, 'facecolor',[0.4 0.6 0.4]);
grid on;
xlabel('Scaling ratio');
ylabel('No. of Images');
saveas(scale_plot, 'Histogram of scaling.png');
