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

x = data(:, 1);
y = data(:, 2) - data(:, 1);
figure;
scatter(x, y, 16, "filled"); hold on;
[fitresult, R] = cruvFit(x, y, "poly1");
plot(x, fitresult(x), "LineWidth", 1.5);
xlabel("测量厚度(mm)");
ylabel("补偿厚度(mm)");
grid on;