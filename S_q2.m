clc; clear;

maxDur = -inf;
bestV = 0;
bestT1 = 0;
bestT2 = 0;

% 粗略搜索先跑一遍
for Ang = 176:1:180
    for vPlane = 70:5:140
        for tRelease = 1:0.1:3
            for tBurst = 1:0.1:5
                dur = F_q1_objective(vPlane, Ang,tRelease, tBurst);
    
                % 遇到 NaN 直接跳过 
                if isnan(dur)
                    continue;      
                end
                % ------------------------------------------
    
                fprintf('v=%.1f,Ang=%.1f, t1=%.1f, t2=%.1f => dur=%.3f\n',...
                        vPlane, Ang,tRelease, tBurst, dur);
    
                if dur > maxDur
                    maxDur = dur;
                    bestV  = vPlane;
                    bestAng = Ang;
                    bestT1 = tRelease;
                    bestT2 = tBurst;
                end
            end
        end
    end
end

fprintf('\n最优结果:\n');
fprintf('速度: %.1f m/s\n', bestV);
fprintf('航向角: %.1f \n', bestAng);
fprintf('释放时间: %.1f s\n', bestT1);
fprintf('爆炸时间: %.1f s\n', bestT2);
fprintf('最大遮蔽时长: %.2f s\n', maxDur);