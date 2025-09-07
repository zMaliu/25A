% 输入爆炸点的坐标，打印每个坐标对应的投放点，爆炸点，有效遮挡时间 输出总的有效遮挡时间
function t=F_q3(points,v_fly,pos_fly,angle)
    g = param.const.g;
    dir_fly = [cosd(angle), sind(angle), 0];
    v=v_fly*dir_fly;
    for i=1:1:3
        x0 = pos_fly(1);
        y0 = pos_fly(2);
        z0 = pos_fly(3);
        
        vx = v(1);
        vy = v(2);
        
        % 计算落地时间
        t_total(i) = sqrt(2 * (z0 - burst_1(3)) / g);
        
        x = points{i}(1) - vx * t_total(i);
        y = points{i}(2) - vy * t_total(i);
        z = points{i}(3) - 0.5 * g * t_total(i).^2;
    end
end