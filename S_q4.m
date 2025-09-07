clc;clear;
param = makeParam();

pos0_fly1=param.plane(1).pos0;
pos0_fly2=param.plane(2).pos0;
pos0_fly3=param.plane(3).pos0;

posFake=param.target.posFake;
pos0_missile=param.missiles(1).pos0;
v_missile=param.const.missileV;
dir_missile=posFake - pos0_missile;

% 用于存储每个 t 时刻的最优点的结构
best_points = struct('point', [], 'distance', []);

maxDur = -inf;
bestV = 0;
bestT1 = 0;
bestT2 = 0;

v_fly1=70;v_fly2=80;v_fly3=80;angle_fly1=180;angle_fly2=180;angle_fly3=135;
% 固定三架无人机的速度和航向角
%{
for v_fly1=70:5:140
    for v_fly2=70:5:140  
        for v_fly3=70:5:140
            for angle_fly1=175:1:180
                for angle_fly2=180:1:270
                    for angle_fly3=135:1:180
                    end
                end
            end
        end
    end
end
%}
v_fly      = [v_fly1; v_fly2; v_fly3];        % 3×1  速度
angle_fly  = [angle_fly1; angle_fly2; angle_fly3];  % 3×1  角度
pos0_fly   = [pos0_fly1; pos0_fly2; pos0_fly3];     % 3×1  初始位置

% 先计算一架飞机
for j=1:3
    for t = 1:13
        dir_fly = [cosd(angle_fly(j)), sind(angle_fly(j)), 0];
        [pos_fly] = F_planemove(v_fly(j), dir_fly, pos0_fly(j), t);  
        [pos_missile]=F_missilemove(v_missile,dir_missile,pos0_missile,t);
    
        min_dist = inf;
        best_point = [];
    
        % d2的计算
        odown = param.target.posTrue;      
        oin   = odown + [0 0  5];
        dist = @(P,A,B) norm(cross(P-A, B-A)) / norm(B-A);
    
        % 先拟定h高度最大是1800
        for i = 1:180
            burst_point = [pos_fly(1), pos_fly(2), pos_fly(3) - i * 10];
            dist_line = dist(burst_point, pos_missile, oin);
    
            if dist_line < min_dist
                min_dist = dist_line;
                best_point = burst_point;
            end
        end 
        best_points(t).point = best_point;
        best_points(t).distance = min_dist;

    end
        
    % 然后将 best_points(t).distance 进行从小到大排序，选取前三个
    % 提取所有距离
    all_distances = [best_points.distance];
    all_times = 1:13;
        
    % 排序并获取前三个的索引
    [sorted_dist, idx] = sort(all_distances);
    
    top3_idx = idx(1:3);
    top3_times = all_times(idx(1:3));
    
    points = cell(3, 1);
    posBurst = cell(3,1);
    posRelease = cell(3,1);
    dur = cell(3,1);
    tRelease = cell(3,1);
    for i = 1:3
        idx = top3_idx(i);
        points{i} = best_points(idx).point;
        [posBurst{i}, posRelease{i}, dur{i}, tRelease{i}] = F_q3getdur(points{i}, v_fly, angle_fly(j),pos0_fly,param);
    
    end
    dur_vals = [dur{:}];  
    
    % 构造结果
    result = cell(1,3);
    result{j} = [top3_times(:), top3_times(:) + dur_vals(:)];
    
end