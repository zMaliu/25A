function bool = F_judge(posSmoke, posMissile, param)
    % 真目标的上、中、下圆心
    odown = param.target.posTrue;      % 下
    oin   = odown + [0 0  5];          % 中
    oup   = odown + [0 0 10];          % 上

    % 点到线段距离函数
    dist = @(P,A,B) norm(cross(P-A, B-A)) / norm(B-A);

    % 三条线各自的判据
    d1 = dist(posSmoke, posMissile, oup)   < 10;   % 上线
    d2 = dist(posSmoke, posMissile, oin)   < 10;   % 中线
    d3 = dist(posSmoke, posMissile, odown) < 10;   % 下线

    % 任意两条满足即为 true
    bool = (d1 + d2 + d3) >= 2;
end