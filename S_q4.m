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
best_points1 = struct('point', [], 'distance', []);

maxDur = -inf;
bestV = 0;
bestT1 = 0;
bestT2 = 0;

v_fly1=70;v_fly2=80;v_fly3=80;angle_fly1=180;angle_fly2=175;angle_fly3=135;
% 固定三架无人机的速度和航向角

for v_fly1=70:10:140
    for v_fly2=70:10:140  
        for v_fly3=70:10:140
            for angle_fly1=175:1:180
                for angle_fly2=180:5:270
                    for angle_fly3=135:5:180
                        [result1,~,~,~]=F_q4_3points(angle_fly1,v_fly1,pos0_fly1,param);
                        [result2,~,~,~]=F_q4_3points(angle_fly2,v_fly2,pos0_fly2,param);
                        [result3,~,~,~]=F_q4_3points(angle_fly3,v_fly3,pos0_fly3,param);
                        result=cell(1,3);
                        result{1}=result1;
                        result{2}=result2;
                        result{3}=result3;
                        
                        [dur_end, ~, ~] = F_q4select(result);
                        if dur_end > maxDur
                            maxDur = dur_end;
                        end
                        fprintf('\n最优结果:\n');
                        fprintf('最大遮蔽时长: %.1f \n', maxDur);
                    end
                end
            end
        end
    end
end
