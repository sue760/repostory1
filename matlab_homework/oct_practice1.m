% Coherence demo
% 杨氏双缝干涉
clear, close all;
%%
lambda = 632.8e-9;  % 氦氖激光波长 632.8nm
d = 1;              % 观察屏与双缝间距，单位为m
a = 0.08e-3;        % 双缝间隙，单位为m
H = 0.1;            % 观察屏尺寸，单位为m
x01 = a/2;          % 第一个狭缝位置
x02 = -a/2;         % 第二个狭缝位置
%%
y = linspace(-H/2, H/2, 501); % 屏的横坐标
x = linspace(-H/2, H/2, 501); % 屏的纵坐标
[X, Y] = meshgrid(x, y);      % 生成二维网格（PPT原代码定义了但未正确使用）

%% 
% 【修正说明】：PPT原代码使用了小写的 y (一维向量)，这会导致计算出的一维数组，
% 无法直接绘制出右侧的二维条纹。这里改为使用 meshgrid 生成的二维矩阵 Y。
L1 = sqrt((Y - x01).^2 + d^2); % 坐标(Y,0)到第一个狭缝的光程
L2 = sqrt((Y - x02).^2 + d^2); % 坐标(Y,0)到第二个狭缝的光程

% 计算波动方程
A1 = exp(1i * 2 * pi / lambda * L1); % 第一个狭缝光的复振幅
A2 = exp(1i * 2 * pi / lambda * L2); % 第二个狭缝光的复振幅

% 计算干涉光强
I = (A1 + A2) .* conj(A1 + A2); % 双缝干涉光强
I = I / max(I(:));              % 【修正说明】：原代码 max(I) 对矩阵会按列求最大值，需用 I(:) 求全局最大值

%% 绘图
figure;
imagesc(x, y, I);    % 绘制二维干涉图样
colormap(gray);      % 使用灰度色图，呈现黑白条纹
axis equal tight;    % 设置坐标轴比例
title('杨氏双缝干涉图样');
xlabel('x (m)');
ylabel('y (m)');