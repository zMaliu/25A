%1、找到每时刻t对应的最优点 组成点集
points=[];%存储最优点
for t=0:0.1:13

    %进行t时刻可能的解进行遍历 
    for 
        %1.1、判断是否可达
        F_canarrived();
        %1.2、判断是否遮挡
        F_isshadow();
        %1.3、得到t时刻的点集合 进行最优点筛选
        best_point=F_select();
    end
    points=[points,best_points];%加入最优解
end

%2、
