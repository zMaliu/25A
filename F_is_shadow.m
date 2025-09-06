function bool = F_is_shadow(missile_pos,location_pos,param)
    % 真目标的上、中、下圆心
    odown = param.target.posTrue;      % 下
    oin   = odown + [0 0  5];          % 中
    oup   = odown + [0 0 10];          % 上

    % 点到线段距离函数
    dist = @(P,A,B) norm(cross(P-A, B-A)) / norm(B-A);

    d1 = dist(location_pos, missile_pos, oup);   
    d2 = dist(location_pos, missile_pos, oin);   
    d3 = dist(location_pos, missile_pos, odown); 
    
    % 找出中间值
    d_all = [d1, d2, d3];
    d_sorted = sort(d_all);
    d_median = d_sorted(2);  % 中间值

    % 判断是否小于10
    bool = d_median < 10;
end