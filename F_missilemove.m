function [point]=F_missilemove(v,action,pos0,t)
    action = action / norm(action);
    point = pos0 + v * action  * t;
end