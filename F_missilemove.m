function [pos]=F_missilemove(vMissile,dirMissile,pos0,t)
% vMissile: 速度
% dirMissile: 飞行方向
% pos0: 初始位置
% t: 时间
    dirMissile = dirMissile / norm(dirMissile);
    pos = pos0 + vMissile * dirMissile  * t;
end
