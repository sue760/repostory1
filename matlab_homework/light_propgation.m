% 光传播仿真参数
xsize=100;
ysize=100;
dh=1;
vmmesh=createRectangularMesh(xsize,ysize,dh);
vmmedia.absorption_coeff=0.01;
vmmedia.scattering_coeff=0.5;
vmmedia.scattering_anis=-0.8;
vmmedia.refraction_index=1.5;


vmcboundary = struct();

vmcboundary.lightsource = cell(length(vmmesh.y), length(vmmesh.x));  % Create cell array matching grid size


center_start = 40;
center_end = 60;
for i = center_start:center_end  % i是行索引，对应Y坐标
    for j = center_start:center_end  % j是列索引，对应X坐标
        vmcboundary.lightsource{i, j} = 'cosinic';
    end
end

% 验证光源设置
light_count = 0;
light_positions = [];
for i = 1:100
    for j = 1:100
        if ~isempty(vmcboundary.lightsource{i, j})
            light_count = light_count + 1;
            light_positions = [light_positions; i, j];
        end
    end
end
fprintf('Total light sources set: %d\n', light_count);
fprintf('Light source positions (first 10):\n');
disp(light_positions(1:min(10, size(light_positions,1)), :));

solution=ValoMC(vmmesh,vmmedia,vmcboundary);

% 检查结构体字段
disp('vmmesh fields:');
disp(fieldnames(vmmesh));
disp('solution fields:');
disp(fieldnames(solution));

% 检查光源信息
if isfield(solution, 'light_sources')
    disp(['Number of light sources: ', num2str(length(solution.light_sources))]);
    disp('Light source positions:');
    disp(solution.light_sources);
else
    disp('Warning: No light_sources field found in solution');
end

% 检查网格尺寸
disp(['Grid size: ', num2str(length(vmmesh.x)), ' x ', num2str(length(vmmesh.y))]);

% Visualization
figure('Position', [100, 100, 1200, 800]);

% 1. 绘制网格结构 - 使用正确的字段名
subplot(2,3,1);
% 检查可用的坐标字段
if isfield(vmmesh, 'H') && isfield(vmmesh, 'V')
    plot(vmmesh.H, vmmesh.V, 'k-', 'LineWidth', 0.5);
elseif isfield(vmmesh, 'x') && isfield(vmmesh, 'y')
    plot(vmmesh.x, vmmesh.y, 'k-', 'LineWidth', 0.5);
elseif isfield(vmmesh, 'nodes')
    % 如果nodes是Nx2矩阵 [x, y]
    plot(vmmesh.nodes(:,1), vmmesh.nodes(:,2), 'k-', 'LineWidth', 0.5);
else
    % 创建简单的网格可视化
    [X, Y] = meshgrid(0:dh:xsize, 0:dh:ysize);
    plot(X, Y, 'k-', 'LineWidth', 0.5);
    hold on;
    plot(X', Y', 'k-', 'LineWidth', 0.5);
end
title('Mesh Structure');
xlabel('X (mm)');
ylabel('Y (mm)');
axis equal;
grid on;

% 2. 绘制吸收系数分布
subplot(2,3,2);
if isfield(vmmedia, 'absorption_coeff')
    imagesc([0 xsize], [0 ysize], vmmedia.absorption_coeff);
    colorbar;
    title('Absorption Coefficient');
    xlabel('X (mm)');
    ylabel('Y (mm)');
end

% 3. 绘制散射系数分布
subplot(2,3,3);
if isfield(vmmedia, 'scattering_coeff')
    imagesc([0 xsize], [0 ysize], vmmedia.scattering_coeff);
    colorbar;
    title('Scattering Coefficient');
    xlabel('X (mm)');
    ylabel('Y (mm)');
end

% 4. 绘制光通量分布（如果solution包含相关数据）
subplot(2,3,4);
if isfield(solution, 'fluence')
    imagesc([0 xsize], [0 ysize], solution.fluence);
    colorbar;
    title('Fluence Distribution');
    xlabel('X (mm)');
    ylabel('Y (mm)');
elseif isfield(solution, 'photon_count')
    imagesc([0 xsize], [0 ysize], solution.photon_count);
    colorbar;
    title('Photon Count Distribution');
    xlabel('X (mm)');
    ylabel('Y (mm)');
elseif isfield(solution, 'solution')
    % 尝试显示solution.solution
    imagesc([0 xsize], [0 ysize], solution.solution);
    colorbar;
    title('Solution Distribution');
    xlabel('X (mm)');
    ylabel('Y (mm)');
else
    % 显示solution结构体的第一个数值字段
    fields = fieldnames(solution);
    for i = 1:length(fields)
        if isnumeric(solution.(fields{i})) && numel(solution.(fields{i})) > 1
            imagesc([0 xsize], [0 ysize], solution.(fields{i}));
            colorbar;
            title(['Solution: ' fields{i}]);
            xlabel('X (mm)');
            ylabel('Y (mm)');
            break;
        end
    end
end

% 5. 绘制中心光源位置
subplot(2,3,5);
% 重新绘制网格
if isfield(vmmesh, 'H') && isfield(vmmesh, 'V')
    plot(vmmesh.H, vmmesh.V, 'k-', 'LineWidth', 0.5);
    x_coords = vmmesh.H;
    y_coords = vmmesh.V;
elseif isfield(vmmesh, 'x') && isfield(vmmesh, 'y')
    plot(vmmesh.x, vmmesh.y, 'k-', 'LineWidth', 0.5);
    x_coords = vmmesh.x;
    y_coords = vmmesh.y;
elseif isfield(vmmesh, 'nodes')
    plot(vmmesh.nodes(:,1), vmmesh.nodes(:,2), 'k-', 'LineWidth', 0.5);
    x_coords = vmmesh.nodes(:,1);
    y_coords = vmmesh.nodes(:,2);
else
    [X, Y] = meshgrid(0:dh:xsize, 0:dh:ysize);
    plot(X, Y, 'k-', 'LineWidth', 0.5);
    hold on;
    plot(X', Y', 'k-', 'LineWidth', 0.5);
    x_coords = X(:);
    y_coords = Y(:);
end

hold on;
% 标记中心正方形光源位置
if isfield(solution, 'light_sources') && ~isempty(solution.light_sources)
    fprintf('Displaying %d light sources from solution\n', length(solution.light_sources));
    for i = 1:length(solution.light_sources)
        % 注意：ind2sub的第一个参数是矩阵大小 [行数, 列数]
        [sy, sx] = ind2sub([length(vmmesh.y), length(vmmesh.x)], solution.light_sources(i));
        plot(vmmesh.x(sx), vmmesh.y(sy), 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'red');
    end
else
    % 显示中心正方形区域 - 直接使用设置的光源位置
    fprintf('No light sources in solution, displaying from boundary settings\n');
    center_start = 45;
    center_end = 55;
    for i = center_start:center_end  % i是行索引，对应Y坐标
        for j = center_start:center_end  % j是列索引，对应X坐标
            if ~isempty(vmcboundary.lightsource{i, j})
                plot(vmmesh.x(j), vmmesh.y(i), 'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'red');
            end
        end
    end
end
title('Center Square Light Sources');
xlabel('X (mm)');
ylabel('Y (mm)');
axis equal;
grid on;
legend('Mesh', 'Light Sources', 'Location', 'best');

% 6. 绘制折射率分布
subplot(2,3,6);
if isfield(vmmedia, 'refraction_index')
    imagesc([0 xsize], [0 ysize], vmmedia.refraction_index);
    colorbar;
    title('Refractive Index');
    xlabel('X (mm)');
    ylabel('Y (mm)');
end

% 调整子图间距
sgtitle('ValoMC Simulation Results', 'FontSize', 16, 'FontWeight', 'bold');

% 保存图像
saveas(gcf, 'valomc_simulation_results.png');
disp('Visualization completed and saved as valomc_simulation_results.png');

%% 光传播路径可视化
figure('Position', [200, 200, 1200, 800]);

% 1. 显示光子路径示例
subplot(2,2,1);
% 绘制网格
if isfield(vmmesh, 'X') && isfield(vmmesh, 'Y')
    plot(vmmesh.X, vmmesh.Y, 'k-', 'LineWidth', 0.5, 'Color', [0.7 0.7 0.7]);
    hold on;
    plot(vmmesh.X', vmmesh.Y', 'k-', 'LineWidth', 0.5, 'Color', [0.7 0.7 0.7]);
else
    % 创建网格可视化
    [X, Y] = meshgrid(vmmesh.x, vmmesh.y);
    plot(X, Y, 'k-', 'LineWidth', 0.5, 'Color', [0.7 0.7 0.7]);
    hold on;
    plot(X', Y', 'k-', 'LineWidth', 0.5, 'Color', [0.7 0.7 0.7]);
end

% 模拟几条光子路径
num_paths = 30;
if isfield(solution, 'light_sources') && ~isempty(solution.light_sources)
    for i = 1:num_paths
        % 随机选择光源位置
        source_idx = randi(length(solution.light_sources));
        source_pos = solution.light_sources(source_idx);
        [source_y, source_x] = ind2sub([length(vmmesh.y), length(vmmesh.x)], source_pos);
        
        % 生成光子路径
        [path, ~] = propagate_photon(source_x, source_y, length(vmmesh.x), length(vmmesh.y), vmmedia);
        
        % 绘制路径
        if size(path, 1) > 1
            % path存储为 [行, 列]，需要转换为实际坐标
            x_path = vmmesh.x(path(:,2));  % 列索引对应X坐标
            y_path = vmmesh.y(path(:,1));  % 行索引对应Y坐标
            % 使用渐变色显示路径，从光源向外
            for j = 1:size(path, 1)-1
                alpha = 0.3 + 0.7 * (j / size(path, 1)); % 透明度随距离增加
                plot(x_path(j:j+1), y_path(j:j+1), 'b-', 'LineWidth', 1.5, 'Color', [0.2 0.4 1 alpha]);
            end
        end
    end
    
    % 标记光源位置
    for i = 1:length(solution.light_sources)
        [sy, sx] = ind2sub([length(vmmesh.y), length(vmmesh.x)], solution.light_sources(i));
        % sy是行索引，sx是列索引
        plot(vmmesh.x(sx), vmmesh.y(sy), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
    end
else
    % 如果没有光源信息，创建一些示例路径
    fprintf('Warning: No light sources found, creating example paths\n');
    for i = 1:num_paths
        % 从边界随机选择起点
        start_x = randi([1, length(vmmesh.x)]);
        start_y = randi([1, length(vmmesh.y)]);
        
        % 生成光子路径
        [path, ~] = propagate_photon(start_x, start_y, length(vmmesh.x), length(vmmesh.y), vmmedia);
        
        % 绘制路径
        if size(path, 1) > 1
            x_path = vmmesh.x(path(:,2));
            y_path = vmmesh.y(path(:,1));
            plot(x_path, y_path, 'b-', 'LineWidth', 1, 'Color', [0.3 0.3 1 0.6]);
        end
    end
end

title('Photon Propagation Paths');
xlabel('X (mm)');
ylabel('Y (mm)');
axis equal;
grid on;
legend('Mesh', 'Photon Paths', 'Light Sources', 'Location', 'best');

% 2. 光通量分布（热图）
subplot(2,2,2);
if isfield(solution, 'fluence')
    imagesc(vmmesh.x, vmmesh.y, solution.fluence);
    colorbar;
    title('Light Fluence Distribution');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    colormap('hot');
    axis equal;
end

% 3. 光子计数分布
subplot(2,2,3);
if isfield(solution, 'photon_count')
    imagesc(vmmesh.x, vmmesh.y, solution.photon_count);
    colorbar;
    title('Photon Count Distribution');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    colormap('jet');
    axis equal;
end

% 4. 光传播动画帧（静态显示）
subplot(2,2,4);
% 显示光传播的"快照"
if isfield(solution, 'fluence')
    % 创建光传播的等值线图
    contourf(vmmesh.X, vmmesh.Y, solution.fluence, 20);
    colorbar;
    title('Light Propagation Contours');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    colormap('parula');
    axis equal;
    
    % 添加光源位置
    hold on;
    if isfield(solution, 'light_sources')
        for i = 1:length(solution.light_sources)
            [sy, sx] = ind2sub([length(vmmesh.y), length(vmmesh.x)], solution.light_sources(i));
            plot(vmmesh.x(sx), vmmesh.y(sy), 'wo', 'MarkerSize', 10, 'MarkerFaceColor', 'white', 'LineWidth', 2);
        end
    end
end

sgtitle('Light Propagation Analysis', 'FontSize', 16, 'FontWeight', 'bold');

% 保存光传播可视化
saveas(gcf, 'light_propagation_analysis.png');
disp('Light propagation visualization completed and saved as light_propagation_analysis.png');


%% 函数定义
function mesh = createRectangularMesh(xsize, ysize, dh)
    % 创建矩形网格
    x = 0:dh:xsize;
    y = 0:dh:ysize;
    [X, Y] = meshgrid(x, y);
    
    % 创建网格结构
    mesh = struct();
    mesh.x = x;
    mesh.y = y;
    mesh.X = X;
    mesh.Y = Y;
    mesh.nodes = [X(:), Y(:)];
    mesh.dh = dh;
    mesh.xsize = xsize;
    mesh.ysize = ysize;
    
    % 创建边界信息
    mesh.boundary_nodes = [];
    % 左边界
    mesh.boundary_nodes = [mesh.boundary_nodes; find(mesh.nodes(:,1) == 0)];
    % 右边界
    mesh.boundary_nodes = [mesh.boundary_nodes; find(mesh.nodes(:,1) == xsize)];
    % 下边界
    mesh.boundary_nodes = [mesh.boundary_nodes; find(mesh.nodes(:,2) == 0)];
    % 上边界
    mesh.boundary_nodes = [mesh.boundary_nodes; find(mesh.nodes(:,2) == ysize)];
    mesh.boundary_nodes = unique(mesh.boundary_nodes);
end

function solution = ValoMC(mesh, media, boundary)
    % 简化的光传播蒙特卡洛仿真
    fprintf('Starting light propagation simulation...\n');
    
    % 初始化解
    solution = struct();
    
    % 创建网格矩阵
    nx = length(mesh.x);
    ny = length(mesh.y);
    
    % 初始化光通量分布
    fluence = zeros(ny, nx);
    photon_count = zeros(ny, nx);
    
    % 光源参数
    num_photons = 10000;
    light_sources = find_light_sources(boundary, mesh);
    
    fprintf('Simulating %d photons from %d light sources...\n', num_photons, length(light_sources));
    
    % 蒙特卡洛仿真
    for i = 1:num_photons
        % 随机选择光源
        source_idx = randi(length(light_sources));
        source_pos = light_sources(source_idx);
        
        % 获取光源坐标
        [source_y, source_x] = ind2sub([ny, nx], source_pos);
        % 注意：source_y是行索引，source_x是列索引
        
        % 光子传播
        [photon_path, ~] = propagate_photon(source_x, source_y, nx, ny, media);
        
        % 记录光子路径和累积光通量
        for j = 1:size(photon_path, 1)
            y_idx = round(photon_path(j, 1));
            x_idx = round(photon_path(j, 2));
            if y_idx >= 1 && y_idx <= ny && x_idx >= 1 && x_idx <= nx
                photon_count(y_idx, x_idx) = photon_count(y_idx, x_idx) + 1;
                % 沿路径累积光通量（考虑距离衰减）
                distance_from_source = sqrt((y_idx - source_y)^2 + (x_idx - source_x)^2);
                weight = exp(-media.absorption_coeff * distance_from_source);
                fluence(y_idx, x_idx) = fluence(y_idx, x_idx) + weight;
            end
        end
        
        % 显示进度
        if mod(i, 1000) == 0
            fprintf('Progress: %d/%d photons simulated\n', i, num_photons);
        end
    end
    
    % 归一化结果
    solution.fluence = fluence / max(fluence(:));
    solution.photon_count = photon_count;
    solution.total_photons = num_photons;
    solution.light_sources = light_sources;
    
    fprintf('Simulation completed!\n');
end

function light_sources = find_light_sources(boundary, mesh)
    % 找到光源位置
    light_sources = [];
    
    % 获取网格尺寸
    nx = length(mesh.x);
    ny = length(mesh.y);
    
    if isfield(boundary, 'lightsource')
        % 处理2D光源数组
        [boundary_ny, boundary_nx] = size(boundary.lightsource);
        for i = 1:boundary_ny
            for j = 1:boundary_nx
                if ~isempty(boundary.lightsource{i, j})
                    % 将2D索引转换为网格的线性索引
                    % 注意：i是行索引，j是列索引
                    linear_idx = sub2ind([ny, nx], i, j);
                    light_sources = [light_sources; linear_idx];
                end
            end
        end
    end
    
    % 如果没有找到光源，使用默认位置（中心区域）
    if isempty(light_sources)
        nx = length(mesh.x);
        ny = length(mesh.y);
        % 在中心区域放置光源 - 使用与设置相同的范围
        center_start = 45;
        center_end = 55;
        % 创建11x11的中心光源区域
        for i = center_start:center_end
            for j = center_start:center_end
                if i >= 1 && i <= ny && j >= 1 && j <= nx
                    linear_idx = sub2ind([ny, nx], i, j);
                    light_sources = [light_sources; linear_idx];
                end
            end
        end
    end
    
    fprintf('Found %d light sources\n', length(light_sources));
end

function [path, final_pos] = propagate_photon(start_x, start_y, nx, ny, media)
    % 改进的光子传播模型 - 修复路径问题
    % start_x: 列索引，start_y: 行索引
    path = [];
    current_x = start_x;
    current_y = start_y;
    
    % 传播参数
    max_steps = 100;  % 增加步数以获得更长的路径
    step_size = 0.3;  % 减小步长以获得更平滑的路径
    
    % 计算从光源中心到当前位置的方向（向外传播）
    center_x = nx / 2;  % 列中心
    center_y = ny / 2;  % 行中心
    
    % 初始方向：从光源中心向外
    if start_x ~= center_x || start_y ~= center_y
        % 注意：这里start_x是列索引，start_y是行索引
        angle = atan2(start_y - center_y, start_x - center_x);
    else
        % 如果就在中心，随机选择向外方向
        angle = 2 * pi * rand();
    end
    
    % 添加小的随机扰动
    angle = angle + (rand() - 0.5) * 2.0; % 小角度扰动
    
    for step = 1:max_steps
        % 记录当前位置（确保是整数索引）
        y_idx = round(current_y);  % 行索引
        x_idx = round(current_x);  % 列索引
        if y_idx >= 1 && y_idx <= ny && x_idx >= 1 && x_idx <= nx
            path = [path; y_idx, x_idx];  % 存储为 [行, 列]
        end
        
        % 计算移动方向
        dx = step_size * cos(angle);
        dy = step_size * sin(angle);
        
        % 更新位置
        new_x = current_x + dx;
        new_y = current_y + dy;
        
        % 边界检查
        if new_x < 1 || new_x > nx || new_y < 1 || new_y > ny
            break;
        end
        
        % 吸收概率（基于实际物理参数）
        absorption_prob = media.absorption_coeff * step_size;
        if rand() < absorption_prob
            break;
        end
        
        % 散射概率和方向改变
        scattering_prob = media.scattering_coeff * step_size;
        if rand() < scattering_prob
            % 使用Henyey-Greenstein散射模型
            g = media.scattering_anis; % 各向异性参数
            cos_theta = (1 + g^2 - ((1 - g^2) / (1 - g + 2*g*rand()))^2) / (2*g);
            cos_theta = max(-1, min(1, cos_theta)); % 确保在有效范围内
            
            % 计算新的散射角度
            theta = acos(cos_theta);
            phi = 2 * pi * rand(); % 方位角随机
            
            % 更新方向（简化处理）
            angle = angle + theta * (rand() - 0.5) * 2; % 限制散射角度变化
        else
            % 小幅度随机扰动（模拟自然扩散）
            angle = angle + (rand() - 0.5) * 0.1;
        end
        
        current_x = new_x;
        current_y = new_y;
    end
    
    % 确保最终位置在有效范围内
    final_y = round(current_y);
    final_x = round(current_x);
    final_y = max(1, min(ny, final_y));
    final_x = max(1, min(nx, final_x));
    final_pos = [final_y, final_x];
    
    % 确保路径不为空
    if isempty(path)
        path = [final_y, final_x];
    end
end