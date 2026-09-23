clc;clear;close all;


xsize = 10; ysize = 10; dh = 0.5;
vmcmesh = createRectangularMesh(xsize, ysize, dh);

vmcboundary.lightsource(4:7) = {'cosinic'};


vmcmedium_bg.absorption_coefficient = 0.01; % 纯背景，全是0.01
vmcmedium_bg.scattering_coefficient = 1.0;
vmcmedium_bg.scattering_anisotropy = 0.9;
vmcmedium_bg.refractive_index = 1.3;
vmcmedium_bg = createMedium(vmcmesh, vmcmedium_bg);

solution_bg = ValoMC(vmcmesh, vmcmedium_bg, vmcboundary);


vmcmedium_ball = vmcmedium_bg; % 复制背景参数
radius = 2.5;
centercoords = [0.0 0.0];
elements_of_the_circle = findElements(vmcmesh, 'circle', centercoords, radius);

% 赋予吸收系数
vmcmedium_ball.absorption_coefficient(elements_of_the_circle) = 0.8; 

solution_ball = ValoMC(vmcmesh, vmcmedium_ball, vmcboundary);

%差值
diff_fluence = solution_ball.element_fluence - solution_bg.element_fluence;

% 画图展示
figure('Name', 'ValoMC 对比图');

% 画图1：有球的光分布
subplot(1, 3, 1);
patch('faces', vmcmesh.H, 'Vertices', vmcmesh.r, 'FaceVertexCData', ...
      solution_ball.element_fluence, 'facecolor', 'flat', 'Linewidth', 1.5);
axis equal; title('With Ball'); colorbar;

% 画图2：没球的光分布
subplot(1, 3, 2);
patch('faces', vmcmesh.H, 'Vertices', vmcmesh.r, 'FaceVertexCData', ...
      solution_bg.element_fluence, 'facecolor', 'flat', 'Linewidth', 1.5);
axis equal; title('No Ball'); colorbar;

% 画图3：差分图（重点，老师要看的）
subplot(1, 3, 3);
patch('faces', vmcmesh.H, 'Vertices', vmcmesh.r, 'FaceVertexCData', ...
      diff_fluence, 'facecolor', 'flat', 'Linewidth', 1.5);
axis equal; title('Difference (With - No)'); 
colorbar;
colormap(jet); % 给差值图上色