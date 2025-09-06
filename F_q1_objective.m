function dur = F_q1_objective(vPlane, varargin)
% 1（固定航向）：
%   dur = F_q1_objective(vPlane, tRelease, tBurst)
% 2（将航向角也作为自变量）：
%   dur = F_q1_objective(vPlane, headingDeg, tRelease, tBurst)
%   其中 headingDeg 为全局坐标系下的水平航向角（度），以 +X 轴为 0°，逆时针为正。


    param = makeParam();
    v_fly = vPlane;
    v_missile = param.const.missileV;
    t3 = 20;                 
    fly1_pos = param.plane(1).pos0;
    missile1_pos = param.missiles(1).pos0;
    posFake = param.target.posFake;

    % 解析输入参数
    if numel(varargin) == 2
        % 1：固定航向，朝向假目标
        tRelease = varargin{1};
        tBurst   = varargin{2};
        angle = 180;
        action_fly = [cosd(angle), sind(angle), 0];
    elseif numel(varargin) == 3
        % 2：给定航向角（度）
        headingDeg = varargin{1};
        tRelease   = varargin{2};
        tBurst     = varargin{3};
        action_fly = [cosd(headingDeg), sind(headingDeg), 0];
    else
        error('传入参数数量错误');
    end

    action_missile = posFake - missile1_pos;

    % 仿真时间上界与步长
    T = norm(missile1_pos) / v_missile;
    dt = 0.01;

    % 提前初始化
    t1 = NaN; t2 = NaN;

    for t = 0:dt:T
        % 位置更新
        posSmoke   = F_frogmove(v_fly, action_fly, fly1_pos, t, tRelease, tBurst, param);
        posMissile = F_missilemove(v_missile, action_missile, missile1_pos, t);

        %t1 如果烟幕遮蔽到了，开始记录t1
        if t >= tBurst && t <= tBurst + t3
            if F_judge(posSmoke, posMissile, param)
                if isnan(t1)
                    t1 = t;
                end
            end
        end

        % 烟幕没有遮蔽到
        if ~isnan(t1)
            if ~F_judge(posSmoke, posMissile, param)
                if isnan(t2)
                    t2 = t;
                end
            end
        end
    end
    dur = t2 - t1;
end
