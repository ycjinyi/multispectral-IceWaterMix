clc;
clear;
close all;

%此脚本主要用于手动划分训练集和测试集合, 并对数据进行训练测试, 最后展示结果

%-------->1 加载数据
DM = DataManagement();
%载入数据
DM.readFile(pwd + "\冰水混合数据");

% [testThick, testThickPredict, testRatio, testRatioPredict, dataSet, k] ...
%     = crossValidation(DM, 3);

load 2024031401.mat;

CG = ColorGenerator();
[colorTable, ~] = CG.generate(zeros(1, 17));

sidx = 3;
eidx = 16;

%数据展示
DP = DataProc();

[~, idxThick] = sort(testThick);

R2Thick = DP.computeR2(testThick, testThickPredict);
RMSEThick = DP.computeRMSE(testThick, testThickPredict);
fprintf("厚度预测的R方为: %0.3f\n", R2Thick);
fprintf("厚度预测的RMSE为: %0.3f\n", RMSEThick);

tT = testThick(idxThick, 1);
tTP = testThickPredict(idxThick, 1);
res = tTP - tT;

figure(1);
subplot(2, 1, 1);
scatter(tT, tTP, 6, "filled"); hold on;
x1 = 1:0.05:9.5;
plot(x1, x1, "LineWidth", 1.5);
xlabel("实际厚度(mm)");
ylabel("预测厚度(mm)");
title("总厚度预测的R方为: " + num2str(floor(R2Thick * 1000) / 1000));
grid on;
subplot(2, 1, 2);
histfit(res);
xlabel("预测厚度误差(mm)");
ylabel("累计个数");
title("误差均值:" + num2str(floor(mean(res) * 1000) / 1000) + ...
    " 标准差: " + num2str(floor(std(res) * 1000) / 1000));
grid on;


% a = (0: 0.01: 10)';
% [color] = DP.colorMap(res, 255);
% color = color * 2;
% color = min(color ,255);
% 
b = (-0.39: 0.02: 0.39)';
[color1] = DP.colorMap(b, 255);
color1 = color1 * 2;
color1 = min(color1 ,255);



[~, idxRatio] = sort(testRatio);

%将预测结果限制在0到1之间
testRatioPredict = max(testRatioPredict, 0);
testRatioPredict = min(testRatioPredict, 1);

R2Ratio = DP.computeR2(testRatio, testRatioPredict);
fprintf("水占比预测的R方为: %0.3f\n", R2Ratio);
RMSERatio = DP.computeRMSE(testRatio, testRatioPredict);
fprintf("水占比预测的RMSE为: %0.3f\n", RMSERatio);

tR = testRatio(idxRatio, 1);
tRP = testRatioPredict(idxRatio, 1);
res2 = tRP - tR;

figure(2);
subplot(2, 1, 1);
scatter(tR, tRP, 6, "filled"); hold on;
x2 = 0:0.05:0.9;
plot(x2, x2, "LineWidth", 2);
xlabel("实际占比");
ylabel("预测占比");
title("水占比预测的R方为: " + num2str(floor(R2Ratio * 1000) / 1000));
grid on;
subplot(2, 1, 2);
histfit(res2);
xlabel("预测误差");
ylabel("累计个数");
title("误差均值:" + num2str(floor(mean(res2) * 1000) / 1000) + ...
    " 标准差: " + num2str(floor(std(res2) * 1000) / 1000));
grid on;

% a = (0.01: 0.01: 1)';
[color] = DP.colorMap(res2, 255);
color = color * 2;
color = min(color ,255);
% 
% b = (-0.78: 0.04: 0.78)';
% [color1] = DP.colorMap(b, 255);
% color1 = color1 * 2;
% color1 = min(color1 ,255);



%计算冰厚水厚度的预测值
pIce = testThickPredict .* (1 - testRatioPredict);
pWater = testThickPredict .* testRatioPredict;
%冰厚水厚的实际值
rIce = testThick .* (1 - testRatio);
rWater = testThick .* testRatio;

%展示结果
R2ice = DP.computeR2(rIce, pIce);
fprintf("冰厚预测的R方为: %0.3f\n", R2ice);
RMSEice = DP.computeRMSE(rIce, pIce);
fprintf("冰厚预测的RMSE为: %0.3f\n", RMSEice);

[~, idxIce] = sort(rIce);

rI = rIce(idxIce, 1);
pI = pIce(idxIce, 1);
res3 = pI - rI;

figure(3);
subplot(2, 1, 1);
scatter(rI, pI, 6, "filled"); hold on;
x1 = 0.5:0.05:6.4;
plot(x1, x1, "LineWidth", 1.5);
xlabel("实际冰厚度(mm)");
ylabel("预测冰厚度(mm)");
title("冰厚度预测的R方为: " + num2str(floor(R2ice * 1000) / 1000));
grid on;
subplot(2, 1, 2);
histfit(res3);
xlabel("冰厚预测误差(mm)");
ylabel("累计个数");
title("误差均值:" + num2str(floor(mean(res3) * 1000) / 1000) + ...
    " 标准差: " + num2str(floor(std(res3) * 1000) / 1000));
grid on;

a = (0.01: 0.01: 8)';
[color] = DP.colorMap(res3, 255);
color = floor(color * 1.5);
color = min(color ,255);
% 
b = (1: 1: 40)';
[color1] = DP.colorMap(b, 255);
color1 = floor(color1 * 2);
color1 = min(color1 ,255);


R2water = DP.computeR2(rWater, pWater);
fprintf("水厚预测的R方为: %0.3f\n", R2water);
RMSEwater = DP.computeRMSE(rWater, pWater);
fprintf("水厚预测的RMSE为: %0.3f\n", RMSEwater);

[~, idxWater] = sort(rWater);

rW = rWater(idxWater, 1);
pW = pWater(idxWater, 1);
res4 = pW - rW;

figure(4);
subplot(2, 1, 1);
scatter(rW, pW, 6, "filled"); hold on;
x1 = 0.1:0.05:5.6;
plot(x1, x1, "LineWidth", 1.5);
xlabel("实际水厚度(mm)");
ylabel("预测水厚度(mm)");
title("水厚度预测的R方为: " + num2str(floor(R2water * 1000) / 1000));
grid on;
subplot(2, 1, 2);
histfit(res4);
xlabel("水厚预测误差(mm)");
ylabel("累计个数");
title("误差均值:" + num2str(floor(mean(res4) * 1000) / 1000) + ...
    " 标准差: " + num2str(floor(std(res4) * 1000) / 1000));
grid on;

a = (0.01: 0.01: 6)';
[color] = DP.colorMap(res4, 255);
color = floor(color * 1.2);
color = min(color ,255);
% 
b = (1: 1: 40)';
[color1] = DP.colorMap(b, 255);
color1 = floor(color1 * 1.2);
color1 = min(color1 ,255);
