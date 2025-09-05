clc;clear;
param = makeParam();
% 参量准备
tRelease = 1.5;                         % 投放时刻（s）
tBurst   = tRelease + 3.6;              % 起爆时刻（s）

vPlane     = 120;                        
vMissile   = param.const.missileV;      
rSmoke     = param.const.rSmoke;         
smokeValid = param.const.tValid;         

% 初始位置与方向
posPlane0     = param.plane(1).pos0;
posMissile0   = param.missiles(1).pos0;
posTargetFake = param.target.posFake;
posTargetTrue = param.target.posTrue;

dirPlane   = posTargetFake - posPlane0; dirPlane(3)=0;   % 等高度水平飞行
if norm(dirPlane)   < 1e-9, error('飞机方向向量为0'); end

dirMissile = posTargetFake - posMissile0;                 % 导弹直指假目标
if norm(dirMissile) < 1e-9, error('导弹方向向量为0'); end

% 时间设置
 tWindowStart = tBurst;                  % 烟幕开始
 tWindowEnd   = tBurst + smokeValid;     % 烟幕结束
 tMax = norm(posMissile0 - posTargetFake)/vMissile + tWindowEnd + 5;  % 上限
 dt   = 0.01;

% 预状态（t=0）
posSmoke_prev   = F_frogmove(vPlane, dirPlane, posPlane0, 0, tRelease, tBurst, param);
posMissile_prev = F_missilemove(vMissile, dirMissile, posMissile0, 0);
% 计算t=0的LOS最近距离
MT_prev = param.target.posTrue - posMissile_prev;
segLen2_prev = dot(MT_prev, MT_prev);
if segLen2_prev < 1e-12
    distLOS_prev = norm(posSmoke_prev - posMissile_prev);
else
    w_prev   = posSmoke_prev - posMissile_prev;
    s_prev   = max(0, min(1, dot(w_prev, MT_prev) / segLen2_prev));
    closest_prev = posMissile_prev + s_prev * MT_prev;
    distLOS_prev = norm(posSmoke_prev - closest_prev);
end
f_prev      = rSmoke - distLOS_prev;                 % f>0 表示被遮蔽
valid_prev  = (0 >= tWindowStart) && (0 <= tWindowEnd);

inShieldA          = valid_prev && (f_prev >= 0);
shieldingA_enter   = NaN; 
shieldingA_exit    = NaN;
if inShieldA
    % 若一开始就处于遮蔽，则进入时刻为窗口开始或0的较大者
    shieldingA_enter = max(0, tWindowStart);
end

printedA = false;

% 主循环
for t = dt:dt:tMax
    % 轨迹更新
    posSmoke   = F_frogmove(vPlane, dirPlane, posPlane0, t, tRelease, tBurst, param);
    posMissile = F_missilemove(vMissile, dirMissile, posMissile0, t);

    % 计算当前LOS最近距离
    MT_now = posTargetTrue - posMissile;
    segLen2_now = dot(MT_now, MT_now);
    if segLen2_now < 1e-12
        distLOS_now = norm(posSmoke - posMissile);
    else
        w_now = posSmoke - posMissile;
        s_now = max(0, min(1, dot(w_now, MT_now) / segLen2_now));
        closest_now = posMissile + s_now * MT_now;
        distLOS_now = norm(posSmoke - closest_now);
    end
    f_now     = rSmoke - distLOS_now;                 % f>0 表示被遮蔽
    valid_now = (t >= tWindowStart) && (t <= tWindowEnd);

    if ~inShieldA
        % 新进入遮蔽：需要同时满足在有效窗内且 f_now>=0
        if valid_now && (f_now >= 0)
            % 两种可能：1) 窗口刚开启；2) f 从负到正跨越阈值
            if ~valid_prev && valid_now
                t_enter = tWindowStart;  % 窗口边界精确值
            elseif valid_prev && (f_prev < 0) && (f_now > f_prev)
                % 在窗内，阈值交叉
                alpha = (0 - f_prev) / (f_now - f_prev);  % 0..1
                t_enter = (t - dt) + alpha * dt;
                t_enter = max(t_enter, tWindowStart);
            else
                % 其他边界情形，采用当前时刻近似
                t_enter = max(t - dt, tWindowStart);
            end
            shieldingA_enter = t_enter;
            inShieldA = true;
        end
    else
        % 退出遮蔽：任一条件不满足（窗外或 f_now<0）
        if (~valid_now) || (f_now < 0)
            if valid_prev && ~valid_now
                t_exit = tWindowEnd;   % 窗口结束边界
            elseif (f_prev >= 0) && (f_now < f_prev)
                alpha = (0 - f_prev) / (f_now - f_prev);  
                t_exit = (t - dt) + alpha * dt;
                t_exit = min(t_exit, tWindowEnd);
            else
                t_exit = min(t, tWindowEnd);
            end
            shieldingA_exit = t_exit;
            inShieldA = false;

            durA = shieldingA_exit - shieldingA_enter;
            fprintf('有效遮蔽时长: %.3f s\n', durA);
            printedA = true;
            break;
        end
    end

    % 更新前一时刻状态
    posSmoke_prev   = posSmoke;
    posMissile_prev = posMissile;
    distLOS_prev    = distLOS_now; 
    f_prev          = f_now;
    valid_prev      = valid_now;
end

% 若循环结束仍处于遮蔽，则将退出钳到窗口结束或 tMax
if ~printedA && inShieldA
    shieldingA_exit = min(tWindowEnd, tMax);
    durA = shieldingA_exit - shieldingA_enter;
    fprintf(' 有效遮蔽时长: %.3f s\n', durA);
end

% 若始终未发生遮蔽，输出0
if ~printedA && isnan(shieldingA_enter)
    fprintf('有效遮蔽时长: 0.000 s\n');
end
