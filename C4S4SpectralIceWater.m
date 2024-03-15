clc;
clear;
close all;

%此脚本主要用于手动划分训练集和测试集合, 并对数据进行训练测试, 最后展示结果

%-------->1 加载数据
DM = DataManagement();
%载入数据
DM.readFile(pwd + "\冰水混合数据");

[testThick, testThickPredict, testRatio, testRatioPredict, dataSet, k] ...
    = crossValidation(DM, 3);

load 2024031401.mat;

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
x1 = 1.5:0.05:9.5;
plot(x1, x1);
xlabel("实际厚度(mm)");
ylabel("预测厚度(mm)");
grid on;

res1 = testThickPredict - testThick;

DP = DataProc();

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
x2 = 0.05:0.05:0.75;
plot(x2, x2);
xlabel("实际占比");
ylabel("预测占比");
grid on;

res2 = testRatioPredict - testRatio;

R2Ratio = DP.computeR2(testRatio, testRatioPredict);
fprintf("水占比预测的R方为: %0.3f\n", R2Ratio);