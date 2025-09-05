% 无人机运动的推广，输入速度 方向 无人机的初始位置 时间 ，输出质点坐标
% 得t大于某个阈值，我们才会释放烟幕
% 0-tRelease 干扰弹跟着无人机做匀速直线运动 tRelease-tBurst 干扰弹脱离无人机，做平抛运动
% tBurst-(tBurst+tValid) 干扰弹爆炸，形成烟幕，只有在这个时间段才有输出point
function [smokePos]=F_frogmove(vPlane,dirPlane,posPlane0,t,tRelease,tBurst,param)
    % 0-tRelease 匀速直线运动（挂载阶段）
    dirPlane = dirPlane / norm(dirPlane);
    posRelease = posPlane0 + vPlane * dirPlane  * tRelease;

    % tRelease-tBurst 平抛运动（弹体脱离无人机）
    dt = tBurst - tRelease;
    px = posRelease(1) + vPlane * dt * dirPlane(1);
    py = posRelease(2) + vPlane * dt * dirPlane(2);     
    pz = posRelease(3) - 0.5 * param.const.g  * dt^2;
    posBurst = [px py pz]; 

    % 起爆后烟幕下沉
    tValid = param.const.tValid;
    vDown  = param.const.vSmokeDown;
    if t>=tBurst && t<=tBurst+tValid
        move_t = t - tBurst;
        pzz = posBurst(3) - move_t * vDown;
        smokePos = [px py pzz];
    else
        smokePos = [0 0 0]; 
    end
end
