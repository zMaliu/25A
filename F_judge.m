function bool = F_judge(posSmoke, posMissile, param)
    % 真目标的上圆心和下圆心
    odown = param.target.posTrue;
    oup = odown + [0 0 10];

    dist = @(P,A,B) norm(cross(P-A, B-A)) / norm(B-A);
    
    bool = (dist(posSmoke, posMissile, oup) < 10) && ...
           (dist(posSmoke, posMissile, odown) < 10);
end
