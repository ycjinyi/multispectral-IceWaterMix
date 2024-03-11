clc;
clear;
close all;

%此脚本主要用于手动划分训练集和测试集合, 并对数据进行训练测试, 最后展示结果

%-------->1 加载数据
DM = DataManagement();
%载入数据
DM.readFile(pwd + "\冰水混合数据");

%-------->2 划分数据集合
%首先获取所有数据编号信息
dataSet = DM.getNumber();
snum = size(dataSet, 1);

%训练集合包含的数据编号索引, 其余数据将作为测试集数据
trainSet = [1, 3, 5, 7, 9, 11, 13, 15];
%根据上述选择方式重新调整trainSet, 从索引转换为编号
trainSet = dataSet(trainSet, 1);
%获得划分后的训练集和测试集数据
[trainData, trainTar, testData, testTar] = DM.generateData(trainSet);

traint = trainTar(:, 1);
trainr = trainTar(:, 2);
testt = testTar(:, 1);
testr = testTar(:, 2);

%数据处理+特征选取
% DP = DataProc();
% [trainData, testData] = DP.dataProc(trainData, testData, 0.90);

% % %------->3 模型训练和预测交由matlab工具箱
% % save 2024031001.mat trainedModel trainData testData trainLabel testLabel DM DP;
% 
% load 2024031001.mat;
% %进行数据预测和分析
% [testPredict, ~] = trainedModel.predictFcn(testData);

%拆成2个模型，第一个模型用于总厚度的测量, 第二个模型用于水占比的测量
%在划分了训练集和测试集的数据后需要分别导出不同模型的数据
%结冰实验需要保证环境温度一致





