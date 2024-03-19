clc;
clear;
close all;

%此脚本用于展示所有实验组的温度变化范围

%-------->1 加载数据
DM = DataManagement();
%载入数据
DM.readFileALLParam(pwd + "\冰水混合数据");

%获取所有的实验编号
numbers = keys(DM.number2Data);
%创建对应的数据, 5行，分别是初始冰厚度、最低温度、最高温度、均值和中位值
tempData = zeros(5, size(numbers, 2));

for i = 1: size(numbers, 2)
    data = DM.number2Data(numbers{1, i});
    tempData(1, i) = data(1, 2);
    temp = data(:, 4);
    tempData(2, i) = max(temp);
    tempData(3, i) = min(temp);
    tempData(4, i) = mean(temp);
    tempData(5, i) = median(temp);
end

%按照初始厚度对数据进行排序
% [~, idx] = sort(tempData(1, :));
% tempData = tempData(:, idx);
x = 1: size(tempData, 2);
% x = tempData(1, :);

%作图
figure(1);
scatter(x, tempData(2, :), 18, "filled"); hold on;
scatter(x, tempData(3, :), 18, "filled"); hold on;
scatter(x, tempData(4, :), 18, "filled"); hold on;
scatter(x, tempData(5, :), 18, "filled");
legend("max", "min", "mean", "median");
ylabel("温度值(℃)");
xlabel("初始冰厚值(mm)");
grid on;





