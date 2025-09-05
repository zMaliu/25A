% 无人机运动的推广，输入速度 方向 无人机的初始位置 时间 ，输出质点坐标
% 得t大于某个阈值，我们才会释放烟幕
% 0-t1 干扰弹跟着无人机做匀速直线运动 t1-t2 干扰弹脱离无人机，做平抛运动
% t2-t3 干扰弹爆炸，形成烟幕，只有在这个时间段才有输出point
function [point]=F_frogmove(v,action,pos0,t,t1,t2,param)
    % 0-t1 匀速直线运动
    action = action / norm(action);
    p1 = pos0 + v * action  * t1;

    % t1-t2 平抛运动
    dt = t2-t1;
    px = p1(1) + v * dt * action(1);
    py = p1(2) + v * dt * action(2);     
    pz = p1(3) - 0.5 * param.const.g  * dt^2;
    p2 = [px py pz]; 

    % t2-t3 干扰弹爆炸
    t3 = 20;
    if t>=t2 && t<=t2+t3
        move_t = t-t2;
        pxx = p2(1) + v * move_t * action(1);
        pyy = p2(2) + v * move_t * action(2); 
        pzz = p2(3) - move_t*0.3;
        point = [pxx pyy pzz];
    else
        point = [0 0 0]; 
    end
    
end