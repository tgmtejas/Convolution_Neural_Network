Please execute file in following order:

1) Execute 'Basic_net.m' which is basic net as per given in starter code for two learning rates

2) 'Augmentation.m' to augment train data into train_aug folder

3) 'Skinny_main' to run skinny model on augmented data and save last check point and workspace

4) Load last check point of skinny and run 'Skinny_transfer' for transfer learning

5) 'wide_main' to run wide model on augmented data and save last check point and workspace

6) Load last check point of wide and run 'wide_transfer' for transfer learning

7) Run 'Augmentatio_test_og' to creat test_og which has 128 x128 images from test folder
   
8) Run 'Augmentatio_train_og' to creat train_og which has 128 x128 images from train folder

9) Run 'Skinny_Og' and 'wide_Og' which will run skinny and wide model on original(un-augmented) dataset

10) Run 'Alex_Train_generater' and 'Alex_Test_generater' to generate dataset for alexnet

11) Run 'Alexnet.main' to run alexnet model

12) Load wide_main workspace and run 'TSNE_main' to get tSNE visualisation of wide network

13) Load skinny_main workspace and run 'TSNE_main' to get tSNE visualisation of skinny network

Note: I am uploading this project on 4th April. I am using 2 days out of 3 late day policy
      Also I have completed all 3 extra credit assignments, you can see results in project report.