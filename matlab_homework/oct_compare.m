clear, close all;

% ================== 1. 基础物理参数 ==================
lambda = 632.8e-9;  % 氦氖激光波长 (m)
d = 1;              % 观察屏与双缝间距 (m)
H = 0.1;            % 观察屏尺寸 (m)
N = 500;            % 屏幕采样点数

% ================== 2. 核心变量：调整光程差 ==================
% 【调整项 A】：改变双缝间距 a。间距越大，光程差随 y 变化越剧烈，条纹越密
a1 = 0.08e-3;       % 原始双缝间隙 (m) -> 对应 PPT 中的条纹
a2 = 0.16e-3;       % 调整后的双缝间隙 (m) -> 条纹变密一倍

% 【调整项 B】：直接施加额外光程差 delta_L (例如在单缝前插入介质片)
% 公式：delta_L = (n-1)*t。这里默认设为 0，你可以手动改成正数或负数试试
delta_L = 0;        % 额外光程差 (m)，例如 0.5*lambda 会引起条纹移动

% ================== 3. 生成坐标网格 ==================
y = linspace(-H/2, H/2, N); % 屏的横坐标
x = linspace(-H/2, H/2, N); % 屏的纵坐标
[X, Y] = meshgrid(x, y);    % 生成二维网格 (注意这里 X 其实没用上，主要用 Y)

% ================== 4. 计算干涉图样 ==================
% 函数定义：计算给定双缝间隙 a 和额外光程差 delta_L 时的光强
get_Intensity = @(a, delta_L) ...
    calculate_interference(Y, d, a, lambda, delta_L);

I1 = get_Intensity(a1, delta_L);
I2 = get_Intensity(a2, delta_L);

% ================== 5. 绘图对比 ==================
figure('Name', '光程差调整对比', 'Position', [100, 100, 800, 400]);

% 绘制第一个图 (原始间隙 a1)
subplot(1, 2, 1);
imagesc(x, y, I1);
colormap(gray);
axis equal tight;
title(['双缝间隙 a = ', num2str(a1*1000), ' mm']);
xlabel('x (m)'); ylabel('y (m)');

% 绘制第二个图 (调整间隙 a2)
subplot(1, 2, 2);
imagesc(x, y, I2);
colormap(gray);
axis equal tight;
title(['双缝间隙 a = ', num2str(a2*1000), ' mm (条纹变密)']);
xlabel('x (m)'); ylabel('y (m)');

% ================== 内部函数：计算光强 ==================
function I = calculate_interference(Y, d, a, lambda, delta_L)
x01 = a/2;          % 第一个狭缝位置
x02 = -a/2;         % 第二个狭缝位置

% 计算光程 (考虑额外光程差)
L1 = sqrt((Y - x01).^2 + d^2); 
L2 = sqrt((Y - x02).^2 + d^2) + delta_L; % 在第二路光中直接加入额外光程差

% 计算复振幅
A1 = exp(1i * 2 * pi / lambda * L1);
A2 = exp(1i * 2 * pi / lambda * L2);

% 计算光强并归一化
I = (A1 + A2) .* conj(A1 + A2);
I = I / max(I(:)); % 避免除以0，使用全局最大值归一化
end