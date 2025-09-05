clc;clear;
param=makeParam();
%参量准备
fly1_pos=param.plane(1).pos0;
fly1_h=fly1_pos(3);
missile1_pos=param.missiles(1).pos0;
missile1_h=missile1_pos(3);

isdetect=false;
isremain_missile=false;
ifremain_frog=false;
isforg=frog;
for t=0:0.1:T%T为时间阈值上界
    %三个物体的运动状态
    F_planemove();
    F_frogmove();
    F_missilemove();
    if t    
        isforg=ture;
        isremain_frog=ture;
    end
    if t
        isfrog=false;
        isremain_frog=false;
    end

    %计算t1 t2
    if F_isdetect()
        isdetect=ture;
        isremain_missile=true;
        t1
    end
    if ~F_isdetect() && isremain_missile%前假后真
        isdetect=false;
        isremain_missile=false;
        t2
    end

    %计算t3 t4
    if isforg
        t3
    end
    if ~isfrog && isremain_frog
        t4
    end

    F_judge()
end