clc;clear;
param = makeParam();
pos0_fly=param.plane(1).pos0;
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

%v_fly=70;angle=180;
for v_fly=70:1:140
    for angle=175:1:180
        for t = 1:0.1:13
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
        
            step=round((t - 1) * 10) + 1;
            best_points(step).point = best_point;
            best_points(step).distance = min_dist;

        end
        % 然后将 best_points(t).distance 进行从小到大排序，选取前三个
        % 提取所有距离
        all_distances = [best_points.distance];
        all_times = 1:0.1:13;
        
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
            [posBurst{i}, posRelease{i}, dur{i}, tRelease{i}] = F_q3getdur(points{i}, v_fly, angle,pos0_fly,param);

        end
        dur_vals = [dur{:}];  
        tRelease_vals = [tRelease{:}];  

        % 构造结果
        result = cell(1,3);
        for i = 1:3
            result{i} = [top3_times(i), dur_vals(i) + top3_times(i)];
        end

        [dur_end, bestPick, unionInt] = F_q4select(result);
        if dur_end > maxDur
            maxDur = dur_end;
            best_dur = dur;
            bestV  = v_fly;
            bestAng = angle;
            best_posRelease = posRelease;
            best_posBurst = posBurst;
        end
        
    end
end

fprintf('\n最优结果:\n');
fprintf('最大遮蔽时长: %.1f \n', maxDur);
fprintf('航向角: %.1f \n', bestAng);
fprintf('速度: %.1f m/s\n', bestV);
for i = 1:length(dur)
    fprintf('第%d个点\n', i);
    fprintf('  释放坐标: %.2f\n', best_posRelease{i});
    fprintf('  爆炸坐标: %.2f\n', best_posBurst{i});
    fprintf('  最大遮蔽时长: %.2f s\n', best_dur{i});
end