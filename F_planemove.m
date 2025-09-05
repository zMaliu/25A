function [pos]=F_planemove(vPlane,dirPlane,pos0,t)
% vPlane: 速度
% dirPlane: 水平飞行方向
% pos0: 初始位置
% t: 时间
    dirPlane = dirPlane / norm(dirPlane);
    pos = pos0 + vPlane * dirPlane  * t;
end
