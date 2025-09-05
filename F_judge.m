function bool=F_isdetect(missilePos,param)
% 判定导弹是否检测到真目标
    posTrue = param.target.posTrue; 
    posFake = param.target.posFake;
    vecToTrue = posTrue - missilePos;      
    vecToFake = posFake - missilePos;      

    angFovDeg = param.detect.angDeg;
    rMin      = param.detect.rMin;
    rMax      = param.detect.rMax;

    distTrue = norm(vecToTrue);
    if distTrue < rMin || distTrue > rMax
        bool = false; return;
    end

    % 夹角判定（数值保护）
    if norm(vecToTrue) < 1e-9 || norm(vecToFake) < 1e-9
        bool = false; return;
    end
    uTrue = vecToTrue / norm(vecToTrue);
    uFake = vecToFake / norm(vecToFake);

    c = dot(uTrue, uFake);
    c = max(-1.0, min(1.0, c));
    angToAxisDeg = acosd(c);

    bool = (angToAxisDeg <= angFovDeg);
end
