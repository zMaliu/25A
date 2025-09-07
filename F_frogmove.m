% 无人机运动的推广，输入速度 方向 无人机的初始位置 时间 ，输出质点坐标
% 得t大于某个阈值，我们才会释放烟幕
% 0-tRelease 干扰弹跟着无人机做匀速直线运动 tRelease-tBurst 干扰弹脱离无人机，做平抛运动
% tBurst-(tBurst+tValid) 干扰弹爆炸，形成烟幕，只有在这个时间段才有输出point
function [posSmoke, posRelease, posBurst] = F_frogmove(vPlane, dirPlane, posPlane0, t, tRelease, tBurst, param)
    dirPlane = dirPlane / norm(dirPlane);
    g = param.const.g;
    vDown = param.const.vSmokeDown;
    tValid = param.const.tValid;

    % 释放点（挂载结束）
    posRelease = posPlane0 + vPlane * dirPlane * tRelease;

    % 爆炸点（平抛结束）
    dt = tBurst ;  % 下落持续时间
    px = posRelease(1) + vPlane * dt * dirPlane(1);
    py = posRelease(2) + vPlane * dt * dirPlane(2);
    pz = posRelease(3) - 0.5 * g * dt^2;
    posBurst = [px, py, pz];

    % 判断当前阶段
    if t < tRelease
        % 挂载阶段
        posSmoke = posPlane0 + vPlane * dirPlane * t;
    elseif t < tBurst+tRelease
        % 平抛阶段
        dt = tBurst ;
        pxx = posRelease(1) + vPlane * dt * dirPlane(1);
        pyy = posRelease(2) + vPlane * dt * dirPlane(2);
        pzz = posRelease(3) - 0.5 * g * dt^2;
        posSmoke = [pxx, pyy, pzz];
    elseif t <= tBurst + tValid + tRelease
        % 烟幕下沉阶段
        move_t = t - tBurst - tRelease;
        pzz = posBurst(3) - move_t * vDown;
        posSmoke = [posBurst(1), posBurst(2), pzz];
    else
        % 烟幕失效
        posSmoke = [NaN, NaN, NaN];  % 或返回 posBurst，视需求而定
    end
end