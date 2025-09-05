clc;clear;
param=makeParam();
%参量准备
tRelease=1.5;
tBurst=3.6+tRelease;
t3=20;
v_fly=120;
v_missile=param.const.missileV;

fly1_pos=param.plane(1).pos0;
fly1_h=fly1_pos(3);
missile1_pos=param.missiles(1).pos0;
missile1_h=missile1_pos(3);
posFake=param.target.posFake;
% 方向向量
action_fly=posFake - param.plane(1).pos0;
action_fly(3)=0;

action_missile=posFake - missile1_pos;
% 时间阈值上界
T = norm(param.missiles(1).pos0)/v_missile;

isdetect=false;
isremain_missile=false;
ifremain_frog=false;
isfrog=false;               % 是否有烟幕

% 提前初始化
t1 = NaN; t2 = NaN;

for t=0:0.01:T %T为时间阈值上界
    %三个物体的运动状态
    [p_fly]=F_planemove(v_fly,action_fly,fly1_pos,t);
    [posSmoke]=F_frogmove(v_fly,action_fly,fly1_pos,t,tRelease,tBurst,param);
    [posMissile]=F_missilemove(v_missile,action_missile,missile1_pos,t);

    %t1 如果烟幕遮蔽到了，开始记录t1
    if t>=tBurst && t<=tBurst+t3
        if F_judge(posSmoke, posMissile, param)
            if isnan(t1)
                t1=t;
            end
        end
    end

    % 三种情况 1.烟幕消失 2.导弹出烟幕了 3.烟幕没有遮蔽到
    if ~isnan(t1)
        if ~F_judge(posSmoke, posMissile, param)
            if isnan(t2)
                t2=t;
            end
        end       
    end

end