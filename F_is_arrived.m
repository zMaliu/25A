% 判断坐标是否可达原始的无人机坐标
% plane_pos 原始无人机坐标 location_pos 要判断的坐标
function bool = F_is_arrived(plane_pos,location_pos,param)
    % 竖直方向的行进时间
    h=plane_pos(3)-location_pos(3);
    t=sqrt(2*h/param.const.g);
    % t时间走过的路程（最大）投放点和爆炸点之间的距离
    s=t*140;
    % 无人机原点和爆炸点之间的水平距离
    x=sqrt((plane_pos(1)-location_pos(1))^2 + (plane_pos(2)-location_pos(2))^2);

    bool = x >= s;
end