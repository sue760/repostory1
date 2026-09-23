clc; clear; close all; 


xsize = 10; 
ysize = 10; 
dh = 0.5;   
vmcmesh = createRectangularMesh(xsize, ysize, dh);

% 2. 背景光学参数
vmcmedium.absorption_coefficient = 0.01;
vmcmedium.scattering_coefficient = 1.0;
vmcmedium.scattering_anisotropy = 0.9;
vmcmedium.refractive_index = 1.3;


vmcmedium = createMedium(vmcmesh, vmcmedium);


radius = 2.5;             
centercoords = [0.0 0.0]; 
elements_of_the_circle = findElements(vmcmesh, 'circle', centercoords, radius);

vmcmedium.absorption_coefficient(elements_of_the_circle) = 10; 

vmcboundary.lightsource(4:7) = {'cosinic'}; 

% 6. 运行求解器
solution = ValoMC(vmcmesh, vmcmedium, vmcboundary);

patch('faces', vmcmesh.H, 'Vertices', vmcmesh.r, 'FaceVertexCData', ...
    solution.element_fluence, 'facecolor', 'flat', 'Linewidth', 1.5);

axis equal; 
xlabel('[mm]'); ylabel('[mm]');
c = colorbar;
ylabel(c, 'Fluence[W/mm^2]');
title('Circle Absorption = 5.0');