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
% testSet = [8, 11, 23, 24, 26];
testSet = [7, 19, 9, 27, 29];
%根据测试集得出训练集和
testRow = size(testSet, 2);
dataRow = size(dataSet, 1);
trainSet = zeros(dataRow - testRow, 1);
%根据上述选择方式重新调整trainSet, 从索引转换为编号
cIdx = 1;
for i = 1: dataRow
    nowNumber = dataSet(i, 1);
    if ~isempty(find(testSet == nowNumber, 1))
        continue;
    end
    trainSet(cIdx, 1) = nowNumber;
    cIdx = cIdx + 1;
end
%获得划分后的训练集和测试集数据
[trainData, trainThick, trainRatio, ...
            testData, testThick, testRatio] = DM.generateData(trainSet);

%数据处理
DP = DataProc();

%----step1 构建用于厚度回归的数据, 目标是厚度
[trainData1, testData1] = DP.thickModel(trainData, testData, 1);
%训练厚度回归模型
[thickModel, ~] = trainThickModel(trainData1, trainThick);
%预测厚度
testThickPredict = thickModel.predictFcn(testData1);

%----step2 构建用于比例回归的数据, 目标是水占比
[trainData2, testData2] = DP.ratioModel(trainData, trainThick, testData, testThickPredict, 1);
%训练比例回归模型
[ratioModel, ~] = trainRatioModel(trainData2, trainRatio);
%预测比例
testRatioPredict = ratioModel.predictFcn(testData2);
 
CG = ColorGenerator();
[colorTable, ~] = CG.generate(zeros(1, 17));

sidx = 3;
eidx = 16;

[~, idxThick] = sort(testThick);

%数据展示
% figure(1);
% plot(testThick(idxThick, 1), 'Color', ...
%         [colorTable(sidx, :), 0.6], LineWidth=1); hold on;
% plot(testThickPredict(idxThick, 1), 'Color', ...
%         [colorTable(eidx, :), 0.6], LineWidth=1);
% legend("实际", "预测");
% xlabel("数据点");
% ylabel("厚度(mm)");
% grid on;

figure(1);
scatter(testThick(idxThick, 1), testThickPredict(idxThick, 1)); hold on;
plot(1.5:0.05:9.5, 1.5:0.05:9.5);
xlabel("实际厚度(mm)");
ylabel("预测厚度(mm)");
grid on;

R2Thick = DP.computeR2(testThick, testThickPredict);
fprintf("厚度预测的R方为: %0.3f\n", R2Thick);


[~, idxRatio] = sort(testRatio);

% figure(2);
% plot(testRatio(idxRatio, 1), 'Color', ...
%         [colorTable(sidx, :), 0.6], LineWidth=1); hold on;
% testRatioPredict = max(testRatioPredict, 0);
% plot(testRatioPredict(idxRatio, 1), 'Color', ...
%         [colorTable(eidx, :), 0.6], LineWidth=1);
% legend("实际", "预测");
% xlabel("数据点");
% ylabel("比例");
% grid on;

figure(2);
scatter(testRatio(idxRatio, 1), testRatioPredict(idxRatio, 1)); hold on;
plot(0.05:0.05:0.75, 0.05:0.05:0.75);
xlabel("实际占比");
ylabel("预测占比");
grid on;

R2Ratio = DP.computeR2(testRatio, testRatioPredict);
fprintf("占比预测的R方为: %0.3f\n", R2Ratio);
