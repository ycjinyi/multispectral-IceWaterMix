clc;
close all;
clear;

load dinoThickCompensate.mat

%波段数目
pNum = 4;
%接收管数目
rNum = 3;

%读取目标文件夹下的所有数据
path = "冰水混合数据\";
files = dir(fullfile(path,"*.xlsx"));
fileNames = {files.name};

%保存数据
data = zeros(1, 1);
ridx = 1;
for i = 1: size(fileNames, 2)
    name = cell2mat(fileNames(1, i));
    file = fullfile(path, name);
    d = readmatrix(file);
    %仅保留水的厚度在0.1mm以上的情况
    idx = find(d(:, 3) >= 0.1, 1);
    d = d(idx: end, :);
    %水厚度在7mm以上的情况也需要排除
    idx = find(d(:, 3) > 7.0, 1);
    if ~isempty(idx)
        d = d(1: idx - 1, :);
    end
    %对水的厚度进行补偿
    d(:, 3) = d(:, 3) + fitresult(d(:, 3));
    %保存数据
    [r, c] = size(d);
    data(ridx: ridx + r -1, 1: c) = d;
    ridx = ridx + r;
end

x = data(:, 2);
y = data(:, 3);
z1890 = data(:, 5);
z11350 = data(:, 6);
z11450 = data(:, 7);
z11550 = data(:, 8);
z2890 = data(:, 9);
z21350 = data(:, 10);
z21450 = data(:, 11);
z21550 = data(:, 12);
z3890 = data(:, 13);
z31350 = data(:, 14);
z31450 = data(:, 15);
z31550 = data(:, 16);

%<<<<<<<<<1、展示数据分布>>>>>>>>>>>
%作图展示, 三维坐标
for i = 1: rNum
    figure(i);
    for j = 1: pNum
        colum = 5 + (i - 1) * pNum + (j - 1);
        x = data(:, 2);
        y = data(:, 3);
        z = data(:, colum);
        scatter3(data(:, 2), data(:, 3), data(:, colum), 5, 'filled'); hold on;
    end
    % legend("890");
    % legend("890", "1350", "1450", "1550");
    % legend("1465", "1575");
    legend("890", "1350", "1450", "1550");
    ylabel("水厚(mm)");
    xlabel("冰厚(mm)");
    zlabel("电压响应(V)");
    %set(gca, "YScale", "log");
    grid on;
end


%<<<<<<<<<2、展示热力图>>>>>>>>>>>

%根据数据进行拟合
features = [z1890, z2890, z3890, z11350, z11450, z11550];
squares = zeros(1, size(features, 2));
type = "lowess";
spans = [0.3, 0.3, 0.25, 0.2, 0.2, 0.2];
fitModelMap = containers.Map("KeyType", 'double', "ValueType", 'any');
%拟合的参数设置
ft = fittype( 'lowess' );
opts = fitoptions( 'Method', 'LowessFit' );
for i = 1: size(features, 2)
    opts.Span = spans(1, i);
    [fittedmodel, gof] = fit([x, y], features(:, i), ft);
    squares(1, i) = ceil(gof.rsquare * 1000) / 1000;
    fitModelMap(i) = fittedmodel;
end 
%展示的数据范围
ice = (1: 0.1: 6);
water = (1: 0.1: 6);
%X只包含ice的数据点, Y只包含water的数据点
[X, Y] = meshgrid(ice, water);

level = 8;
step = 8;

%890nm
figure(4);

subplot(2, 3, 1);
fitresult = fitModelMap(1);
[C,h] = contourf(X, Y, fitresult(X, Y), level, 'LineWidth', 0.9, 'ShowText', 'on');
h.LevelList = round(h.LevelList, 1);
clabel(C,h, 'LabelSpacing', 270);
xlabel("冰厚(mm)");
ylabel("水厚(mm)");
title("890nm-1, Rsquare:" + num2str(squares(1, 1)));


subplot(2, 3, 2);
fitresult = fitModelMap(2);
[C,h] = contourf(X, Y, fitresult(X, Y), level, 'LineWidth', 0.9, 'ShowText', 'on');
h.LevelList = round(h.LevelList, 1);
clabel(C, h, 'LabelSpacing', 270);
title("890nm-2, Rsquare:" + num2str(squares(1, 2)));

subplot(2, 3, 3);
fitresult = fitModelMap(3);
[C,h] = contourf(X, Y, fitresult(X, Y), level, 'LineWidth', 0.9, 'ShowText', 'on');
h.LevelList = round(h.LevelList, 1);
clabel(C, h, 'LabelSpacing', 270);
title("890nm-3, Rsquare:" + num2str(squares(1, 3)));

subplot(2, 3, 4);
fitresult = fitModelMap(4);
[C,h] = contourf(X, Y, fitresult(X, Y), level, 'LineWidth', 0.9, 'ShowText', 'on');
h.LevelList = round(h.LevelList, 1);
clabel(C, h, 'LabelSpacing', 270);
xlabel("冰厚(mm)");
ylabel("水厚(mm)");
title("1350nm-1, Rsquare:" + num2str(squares(1, 4)));

subplot(2, 3, 5);
fitresult = fitModelMap(5);
Z = fitresult(X, Y);
Ma = max(max(Z));
Mi = min(min(Z));
interval = Ma - Mi;
s = interval / step;
levels = Mi: s: Ma - s;
levels = round(levels * 100, 1) / 100;
[C,h] = contourf(X, Y, Z, levels, 'LineWidth', 0.9, 'ShowText', 'on');
clabel(C, h, 'LabelSpacing', 270);
xlabel("冰厚(mm)");
title("1450nm-1, Rsquare:" + num2str(squares(1, 5)));

subplot(2, 3, 6);
fitresult = fitModelMap(6);
Z = fitresult(X, Y);
Ma = max(max(Z));
Mi = min(min(Z));
interval = Ma - Mi;
s = interval / step;
levels = Mi: s: Ma - s;
levels = round(levels * 100, 1) / 100;
[C,h] = contourf(X, Y, Z, levels, 'LineWidth', 0.9, 'ShowText', 'on');
clabel(C, h, 'LabelSpacing', 270);
xlabel("冰厚(mm)");
title("1550nm-1, Rsquare:" + num2str(squares(1, 6)));

colormap("cool");