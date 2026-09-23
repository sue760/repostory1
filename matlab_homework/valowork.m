xsize= 10
ysize= 10
dh= 1
vmcmesh=createRectangularMesh(xsize,ysize,dh);


vmcmedium.absorption_coefficient = 0.01;  % 吸收系数 [1/mm]
vmcmedium.scattering_coefficient = 1.0;   % 散射系数 [1/mm]
vmcmedium.scattering_anisotropy = 0.9;    % 各向异性因子 g 
vmcmedium.refractive_index = 1.3;         % 折射率 (无单位)

vmcboundary.lightsource(8:13)={'cosinic'};
solution=ValoMC(vmcmesh,vmcmedium,vmcboundary);
subplot(1,2,1)
patch('faces',vmcmesh.H,'Vertices',vmcmesh.r,'FacevertexCData',...
    solution.element_fluence,'facecolor','flat','Linewidth',1.5);
hold on;
xlabel('[mm]');
ylabel('[mm]');
c=colorbar;
ylabel(c, 'Fluence[W/mm^2]');
hold off;

vmcmedium.absorption_coefficient = 0.01;  % 吸收系数 [1/mm]
vmcmedium.scattering_coefficient = 1.0;   % 散射系数 [1/mm]
vmcmedium.scattering_anisotropy = 0.9;    % 各向异性因子 g 
vmcmedium.refractive_index = 1.3;         % 折射率 (无单位)

vmcboundary.lightsource(4:7)={'cosinic'};
solution=ValoMC(vmcmesh,vmcmedium,vmcboundary);
subplot(1,2,2)
patch('faces',vmcmesh.H,'Vertices',vmcmesh.r,'FacevertexCData',...
    solution.element_fluence,'facecolor','flat','Linewidth',1.5);
hold on;
xlabel('[mm]');
ylabel('[mm]');
c=colorbar;
ylabel(c, 'Fluence[W/mm^2]');
hold off