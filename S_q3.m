clc;clear;
param = makeParam();
pos0_fly=param.plane(1).pos0;
posFake=param.target.posFake;
pos0_missile=param.missiles(1).pos0;
v_missile=param.const.missileV;
dir_missile=posFake - pos0_missile;
% 用于存储每个 t 时刻的最优点的结构
best_points = struct('point', [], 'distance', []);
v_fly=70;angle=175;
%for v_fly=70:5:140
    %for angle=175:1:180
        for t = 1:13
            dir_fly = [cosd(angle), sind(angle), 0];
            [pos_fly] = F_planemove(v_fly, dir_fly, pos0_fly, t);
            [pos_missile]=F_missilemove(v_missile,dir_missile,pos0_missile,t);
        
            min_dist = inf;
            best_point = [];

            % d2的计算
            odown = param.target.posTrue;      
            oin   = odown + [0 0  5];
            dist = @(P,A,B) norm(cross(P-A, B-A)) / norm(B-A);
        
            for i = 1:96
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
        
        % 排序并获取前三个的索引
        [sorted_dist, idx] = sort(all_distances);
        top3_idx = idx(1:3);
        points = cell(3, 1);
        for i = 1:3
            idx = top3_idx(i);
            points{i} = best_points(idx).point;
        end
        t=F_q3(points,v_fly);
        
    %end
%end