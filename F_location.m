% 计算投放点和爆炸点
function [posRelease,posBurst]=F_location(vPlane,dirPlane,posPlane0,tRelease,tBurst,param)
    % 0-tRelease 匀速直线运动（挂载阶段）
    dirPlane = dirPlane / norm(dirPlane);
    posRelease = posPlane0 + vPlane * dirPlane  * tRelease;

    % tRelease-tBurst 平抛运动（弹体脱离无人机）
    dt = tBurst;
    px = posRelease(1) + vPlane * dt * dirPlane(1);
    py = posRelease(2) + vPlane * dt * dirPlane(2);     
    pz = posRelease(3) - 0.5 * param.const.g  * dt^2;
    posBurst = [px py pz]; 

end
