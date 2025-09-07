function [posBurst, posRelease, dur, tRelease] = F_q3getdur(burstPoint, vPlane, headingDeg,posPlane0)
    % 输入：目标起爆点(1x3)、飞行速度、航向角
    % 输出：起爆点、投放点、遮蔽时长、释放时间
    dirPlane = [cosd(headingDeg), sind(headingDeg), 0];
    % 由高度差反推下落时长（平抛）
    zRelease = posPlane0(3);
    zBurst   = burstPoint(3);
    if zBurst >= zRelease
        error('起爆点高度必须低于无人机高度。');
    end
    tBurst = sqrt(2 * (zRelease - zBurst) / g);

    % 由起爆点反推投放点（沿航向回推 v*tBurst），并设定释放时刻
    posRelease = [burstPoint(1) - vPlane * dirPlane(1) * tBurst, ...
                  burstPoint(2) - vPlane * dirPlane(2) * tBurst, ...
                  zRelease];

    tRelease  = norm(posRelease(1:2) - posPlane0(1:2)) / vPlane;

    % 遮蔽时长
    dur = F_q1_objective(vPlane, headingDeg, tRelease, tBurst);

    % 直接返回目标起爆点
    posBurst = burstPoint;
end
