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
for v_fly=70:5:140
    for angle=175:1:180
        for t = 1:1:13
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
                burst_point = [pos_fly(1), pos_fly(2), pos_fly(3) - i*10];
                dist_line = dist(burst_point, pos_missile, oin);
        
                if dist_line < min_dist
                    min_dist = dist_line;
                    best_point = burst_point;
                end
            end
        
            %step=round((t - 1) * 10) + 1;
            best_points(t).point = best_point;
            best_points(t).distance = min_dist;

        end
        % 然后将 best_points(t).distance 进行从小到大排序，选取前三个
        % 提取所有距离
        all_distances = [best_points.distance];
        all_times = 1:13;
        
        % 将距离d2进行排序，然后还有对应的释放时间，然后先找到第一个的释放时间
        % 然后选取距离第一个点释放时间大于1s的点，这样选取三个点
        points = cell(3, 1);
        posBurst = cell(3,1);
        posRelease = cell(3,1);
        dur = cell(3,1);
        tRelease = cell(3,1);
        tRelease_temp = cell(13,1);

        [sorted_dist, idx] = sort(all_distances);
        for i = 1:13
            sorted_idx = idx(i);
            points{i} = best_points(sorted_idx).point;
            [~, ~, ~, tRelease_temp{i}] = F_q3getdur(points{i}, v_fly, angle,pos0_fly,param);
        end
        tRelease_one = tRelease_temp{1};
        
        % 初始化输出
        selected_idx = zeros(1, 3);   % 保存选中的原始索引
        selected_points = cell(1, 3); % 保存选中的 points
        selected_tRelease = zeros(1, 3); % 保存选中的 tRelease 值
        
        % 第一个点
        selected_tRelease(1) = tRelease_one;
        [~, first_idx] = ismember(tRelease_one, [tRelease_temp{:}]);
        selected_idx(1)      = idx(first_idx);
        selected_points{1}   = points{first_idx};

        % 新增：已选掩码 
        already_picked = false(13,1);          % 13 是总长度
        already_picked(first_idx) = true;      % 把第一个点标记为已选
        
        % 第二个点 
        diff1 = abs([tRelease_temp{:}] - tRelease_one);
        diff1(already_picked) = NaN;            % 排除已选
        valid1 = find(diff1 >= 1, 1, 'first');
        selected_tRelease(2) = tRelease_temp{valid1};
        selected_idx(2)      = idx(valid1);
        selected_points{2}   = points{valid1};
        already_picked(valid1) = true;          % 标记
        
        % 第三个点 
        tRelease_two = selected_tRelease(2);
        diff2 = abs([tRelease_temp{:}] - tRelease_two);
        diff2(already_picked) = NaN;            % 排除已选
        valid2 = find(diff2 >= 1, 1, 'first');
        selected_tRelease(3) = tRelease_temp{valid2};
        selected_idx(3)      = idx(valid2);
        selected_points{3}   = points{valid2};

        for i = 1:3
            sorted_idx = selected_idx(i);
            points{i} = best_points(sorted_idx).point;
            [posBurst{i}, posRelease{i}, dur{i}, tRelease{i}] = F_q3getdur(points{i}, v_fly, angle,pos0_fly,param);
        end
        dur_vals = [dur{:}];  

        % 构造结果
        result = cell(1,3);

        for i = 1:3
            sorted_idx = selected_idx(i);
            result{i} = [all_times(sorted_idx), dur_vals(i) + all_times(sorted_idx)];
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