% S_q3draw.m
% 旋转平面得到立体图形：
% 初始为垂直于 XY 平面的正方形区域（位于 Y-Z 平面，x=0），
% 围绕一条垂直于 XY 平面的边（沿 Z 轴，位于 y=-L/2）在 0~30° 范围内转动，
% 显示由此生成的三维立体（旋转体的边界面），并在每 5° 标注一次候选点（红点）。
clc; clear; close all;

% 几何参数（单位：m）
L = 40;                 % 正方形边长（在 Y、Z 方向）
theta_final = 30;       % 旋转终角（度）
% 调整角度步长，减少标注密度
angles = 0:10:theta_final;   % 每 10° 标注一次，减少密度

% 可视化设置
fig = figure('Name','S_q3draw | 旋转平面得到立体（候选点标注）','Color','w','Position',[80 60 1060 780]);
ax = axes('Parent',fig); hold(ax,'on'); grid(ax,'on'); box(ax,'on'); axis(ax,'equal'); view(ax, 40, 24);
set(ax,'FontName','Times New Roman','FontSize',10,'LineWidth',1.0,'GridAlpha',0.20);
colSurf = [0.78 0.88 1.00]; edgSurf = [0.55 0.75 0.95];
colSide = [0.90 1.00 0.92]; edgSide = [0.65 0.90 0.70];

% 旋转轴：过 (x,y)=(0,-L/2)，沿 z 方向（垂直于 XY 平面）
Axy = [0, -L/2];   % 旋转中心在 XY 平面的坐标

% —— 构造旋转体的边界面（参数化） ——
% 参数范围：
% r ∈ [0, L]（对应初始平面上 y 从 -L/2 到 +L/2 的距离到轴的半径）
% phi ∈ [0, theta_final]（旋转角，度）
% z ∈ [-L/2, L/2]

% 1) 外侧曲面（r = L）：phi × z 网格
ph = linspace(0, theta_final, 60);
zv = linspace(-L/2, L/2, 36);
[PH1, Z1] = meshgrid(ph, zv);
X1 = -L * sind(PH1);
Y1 =  L * cosd(PH1) - L/2;
Z1 =  Z1;
% 外侧曲面绘制，隐藏到图例
surf(ax, X1, Y1, Z1, 'FaceColor',colSurf, 'FaceAlpha',0.30, 'EdgeColor',edgSurf, 'EdgeAlpha',0.55, 'DisplayName','外侧曲面', 'HandleVisibility','off');

% 2) 顶/底面（z = ±L/2）：phi × r 网格
r = linspace(0, L, 60);
[PH2, R2] = meshgrid(ph, r);
Xt = -R2 .* sind(PH2); Yt = R2 .* cosd(PH2) - L/2; Zt =  L/2 * ones(size(R2));
Xb = -R2 .* sind(PH2); Yb = R2 .* cosd(PH2) - L/2; Zb = -L/2 * ones(size(R2));
% 顶/底面绘制，隐藏到图例
surf(ax, Xt, Yt, Zt, 'FaceColor',colSurf, 'FaceAlpha',0.22, 'EdgeColor',edgSurf, 'EdgeAlpha',0.45, 'DisplayName','顶面', 'HandleVisibility','off');
surf(ax, Xb, Yb, Zb, 'FaceColor',colSurf, 'FaceAlpha',0.18, 'EdgeColor',edgSurf, 'EdgeAlpha',0.35, 'DisplayName','底面', 'HandleVisibility','off');

% 3) 径向侧面（phi = 0 和 phi = theta_final）：r × z 网格
[R3, Z3] = meshgrid(r, zv);
phi0 = 0; phif = theta_final;
% phi=0 面（初始平面）
X20 = zeros(size(R3));
Y20 = R3 - L/2;   % y = r - L/2
Z20 = Z3;
% 径向侧面（phi=0 和 phi=theta_final），隐藏到图例
surf(ax, X20, Y20, Z20, 'FaceColor',colSide, 'FaceAlpha',0.18, 'EdgeColor',edgSide, 'EdgeAlpha',0.55, 'DisplayName','径向面', 'HandleVisibility','off');
% phi=theta 面
X2f = -R3 * sind(phif);
Y2f =  R3 * cosd(phif) - L/2;
Z2f =  Z3;
surf(ax, X2f, Y2f, Z2f, 'FaceColor',colSide, 'FaceAlpha',0.18, 'EdgeColor',edgSide, 'EdgeAlpha',0.55, 'HandleVisibility','off');

% —— 候选点定义与标注 ——
% 选取：
% - 前“初始平面”内部均匀网格交点（不含边界，y,z 方向各取 6×6），作为“内部候选点”；
% - 圆柱外侧（r=L）在 z ∈ {-L/2, 0, L/2} 三条高度的点，在每个角度上显示，作为“侧面候选点”。
% 调整内部网格密度为 3×3（减少候选点数量）
Yi = linspace(-L/2, L/2, 5); Yi = Yi(2:end-1);
Zi = linspace(-L/2, L/2, 5); Zi = Zi(2:end-1);
[YYi, ZZi] = meshgrid(Yi, Zi);     % 初始平面内的网格交点（x=0）
% 将 (x=0, y, z) 用 r = y + L/2 映射并按角度旋转：
legendAdded = false;
for th = angles
    % 内部候选点
    r_in = YYi(:) + L/2;            % 半径 >= 0
    x_in = - r_in .* sind(th);
    y_in =   r_in .* cosd(th) - L/2;
    z_in = ZZi(:);
    if ~legendAdded
        scatter3(ax, x_in, y_in, z_in, 16, 'r', 'filled', 'DisplayName','部分候选点');
        legendAdded = true;
    else
        scatter3(ax, x_in, y_in, z_in, 16, 'r', 'filled', 'HandleVisibility','off');
    end
    
    % 外侧候选点（r=L，z 三层）
    z_side = [-L/2, 0, L/2]; z_side = z_side(:);
    r_out = L * ones(size(z_side));
    x_out = - r_out .* sind(th);
    y_out =   r_out .* cosd(th) - L/2;
    z_out = z_side;
    scatter3(ax, x_out, y_out, z_out, 20, 'r', 'filled', 'HandleVisibility','off');
end

% 旋转轴可视化（不进入图例）
z_axis = linspace(-L/2, L/2, 60).';
plot3(ax, zeros(size(z_axis)), -L/2*ones(size(z_axis)), z_axis, 'k-', 'LineWidth',1.5, 'DisplayName','转轴（垂直XY）', 'HandleVisibility','off');

% 标注与导出
% 去掉背景坐标轴（保留标题与图例）
xlabel(ax,'X / m'); ylabel(ax,'Y / m'); zlabel(ax,'Z / m');
% 去掉标题，保持画面简洁
% title(ax, sprintf('旋转平面（初始垂直于XY）绕垂直边形成立体，每5°标注候选点（终角=%.0f°）', theta_final));
axis(ax,'vis3d'); camlight(ax,'head'); lightangle(ax,48,22); material(ax,'dull');
% 关闭背景坐标轴
grid(ax,'off'); box(ax,'off'); axis(ax,'off');
% 图例仅保留候选点，并设置中文字体与美观样式
hLeg = legend(ax,'Location','northeast');
set(hLeg,'FontName','Microsoft YaHei','FontSize',10,'Box','off','Interpreter','none');
