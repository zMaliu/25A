% 画问题一烟幕形成时无人机 导弹 烟幕的情形
clc;clear;
param=makeParam();
%参量准备
tRelease=1.5;
tBurst=3.6;
t3=20;
v_fly=120;
v_missile=param.const.missileV;

fly1_pos=param.plane(1).pos0;
fly1_h=fly1_pos(3);
missile1_pos=param.missiles(1).pos0;
missile1_h=missile1_pos(3);
posFake=param.target.posFake;
% 方向向量
action_fly=posFake - param.plane(1).pos0;
action_fly(3)=0;
action_missile=posFake - missile1_pos;

% 时间向量
t_vec = 0:0.1:27;
d2_vec = zeros(size(t_vec));

%从0到27，烟幕中心到第二条线之间的距离
for i = 1:length(t_vec)
    t = t_vec(i);
    [posSmoke,posRelease,posBurst]=F_frogmove(v_fly,action_fly,fly1_pos,t,tRelease,tBurst,param);
    [posMissile]=F_missilemove(v_missile,action_missile,missile1_pos,t);
    odown=param.target.posTrue; 
    oin=odown + [0 0  5];
    dist = @(P,A,B) norm(cross(P-A, B-A)) / norm(B-A);
    d2_vec(i) = dist(posSmoke, posMissile, oin);  % 存储
end

figure; hold on; box on;

% 主曲线
plot(t_vec, d2_vec, ...
     'Color', [0.2 0.5 0.9], 'LineWidth', 1.7);

% 三个关键圆点
yval = interp1(t_vec, d2_vec, [1.5 3.6 25.1]);
plot(1.5,  yval(1), 'o', 'Color', [0.00 0.75 0.75], 'MarkerSize', 7, ...
     'MarkerFaceColor', [0.00 0.75 0.75], 'MarkerEdgeColor', 'none');
plot(3.6,  yval(2), 'o', 'Color', [0.95 0.50 0.20], 'MarkerSize', 7, ...
     'MarkerFaceColor', [0.95 0.50 0.20], 'MarkerEdgeColor', 'none');
plot(25.1, yval(3), 'o', 'Color', [0.60 0.40 0.90], 'MarkerSize', 7, ...
     'MarkerFaceColor', [0.60 0.40 0.90], 'MarkerEdgeColor', 'none');

% y = 10 虚线
yline(10, 'Color', [0.4 0.4 0.4], 'LineStyle', '--', 'LineWidth', 1.2);

% 高亮 d2 ≤ 10 的区域
idxEff = d2_vec <= 10;                 % 有效索引
area(t_vec(idxEff), d2_vec(idxEff), ...
     'FaceColor', [0.85 0.95 1], ...    % 淡蓝色
     'EdgeColor', 'none', ...
     'FaceAlpha', 0.6);
plot(t_vec(idxEff),  d2_vec(idxEff),  ...
     'Color', 'r', 'LineWidth', 3.0);

% 找到有效段中心时刻
tEff   = t_vec(idxEff);
tText  = mean([tEff(1) tEff(end)]);
dText  = 13;                            % 文字纵坐标位置
text(tText, dText, '有效时间', ...
     'HorizontalAlignment', 'center', ...
     'FontSize', 15, ...
     'Color', [0.2 0.2 0.2], ...
     'BackgroundColor', [1 1 1], ...   % 白底
     'Margin', 1);

legend({'d_2 距离', ...
        '投放点 (t=1.5 s)', ...
        '爆炸点 (t=3.6 s)', ...
        '消失点 (t=25.1 s)'}, ...
       'Location', 'best', 'Box', 'on', 'FontSize', 20);

xlabel('时间 t (s)','FontSize', 20);
ylabel('烟幕中心到导弹-目标连线距离 d_2 (m)','FontSize', 20);
grid off;


