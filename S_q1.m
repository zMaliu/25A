clc;clear;
param=makeParam();
%参量准备
t1=1.5;
t2=3.6+t1;
t3=20;
v_fly=120;
v_missile=300;

fly1_pos=param.plane(1).pos0;
fly1_h=fly1_pos(3);
missile1_pos=param.missiles(1).pos0;
missile1_h=missile1_pos(3);
posFake=param.target.posFake;
% 方向向量
action_fly=posFake - param.plane(1).pos0;
action_fly=[action_fly(1) action_fly(2) 0];

action_missile=posFake - missile1_pos;
% 时间阈值上界
T = norm(param.missiles(1).pos0)/v_missile;

isdetect=false;
isremain_missile=false;
ifremain_frog=false;
isfrog=false;               % 是否有烟幕

% 提前初始化
t11 = NaN; t22 = NaN; t33 = NaN; t44 = NaN;

for t=0:0.01:30 %T为时间阈值上界
    %三个物体的运动状态
    [p_fly]=F_planemove(v_fly,action_fly,fly1_pos,t);
    [p_frog]=F_frogmove(v_fly,action_fly,fly1_pos,t,t1,t2,param);
    [p_missile]=F_missilemove(v_missile,action_missile,missile1_pos,t);
    disp(norm(p_missile - p_frog));
    if t>=t2 && t<=t2+t3
        isfrog=true;
        isremain_frog=true;
    end
    if t<t2 || t>t2+t3
        isfrog=false;
        isremain_frog=false;
    end

    %计算t11 t22
    if F_isdetect(p_missile, param)
        if isnan(t11)          % 还没记录过
            t11=t;           % 只在这第一次赋值
            isdetect=true;
            isremain_missile=true;
        end
    end
    if ~F_isdetect(p_missile, param) && isremain_missile %前假后真
        if isnan(t22)
            t22=t;
            isdetect=false;
            isremain_missile=false;
        end
    end

    %计算t33 t44
    if isfrog
        if norm(p_missile - p_frog)<10
            if isnan(t33)
                t33=t;
            end
        end
    end
    % 在t33存在的情况下计算t44
    % 两种情况 1.烟幕消失 2.导弹出烟幕了
    if ~isnan(t33)
        if ~isfrog || norm(p_missile - p_frog)>10
            if isnan(t44)
                t44=t;
            end
        end       
    end

    if ~any(isnan([t11,t22,t33,t44]))
        t_end = F_judge(t11,t22,t33,t44);
        disp(t_end);
        break;
    end
end