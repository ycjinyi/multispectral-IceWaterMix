clc;
clear;
close all;

data = ...
[0.856, 0.972;
 1.342, 1.458;
 2.036, 2.129;
 2.452, 2.591;
 2.869, 3.031;
 3.378, 3.517;
 3.817, 4.003;
 4.396, 4.535;
 4.997, 5.090;
 5.576, 5.715;
 6.131, 6.386;
 6.826, 7.034;
 7.312, 7.566;
 7.936, 8.237;
 8.561, 8.839;
 8.978, 9.255;];

data1 = [data(1:8, :); data(11: end, :)];
x1 = data1(:, 1);
y1 = data1(:, 2) - data1(:, 1);
figure;
scatter(x1, y1, 16, "filled"); hold on;
[fitresult, R] = cruvFit(x1, y1, "poly1");
plot(x1, fitresult(x1), "LineWidth", 1.5);
xlabel("测量厚度(mm)");
ylabel("补偿厚度(mm)");
grid on;

p = fitresult(x1);
count = size(p, 1);
s = 0;
%计算RMSE
for i = 1: count
    s = s + power(y1(i, 1) - p(i, 1), 2);
end
RMSE = sqrt(s / count);

x = data(:, 1);
y = data(:, 2);
pre = fitresult(x);