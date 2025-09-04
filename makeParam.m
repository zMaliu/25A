function param = makeParam()
%% 1. 预分配结构体数组（避免动态扩容）
param.plane(5)  = struct('id','','pos0',[0 0 0]);
param.missiles(3) = struct('id','','pos0',[0 0 0]);

%% 2. 物理常数
param.const.g            = 9.81;     % m/s^2
param.const.vSmokeDown   = 3.0;      % m/s  烟幕云团匀速下沉速度
param.const.rSmoke       = 10.0;     % m    有效遮蔽半径
param.const.tValid       = 20.0;     % s    起爆后有效遮蔽时长
param.const.missileV     = 300.0;    % m/s  导弹飞行速度

%% 3. 目标参数（真目标/假目标）
param.target.r        = 7.0;         % m   圆柱半径
param.target.h        = 10.0;        % m   圆柱高度
param.target.posTrue  = [0  200  0]; % m   真目标下底面圆心
param.target.posFake  = [0    0  0]; % m   假目标——原点

%% 4. 导弹初始位置
param.missiles(1).id   = 'M1';
param.missiles(1).pos0 = [20000    0  2000];

param.missiles(2).id   = 'M2';
param.missiles(2).pos0 = [19000  600  2100];

param.missiles(3).id   = 'M3';
param.missiles(3).pos0 = [18000 -600  1900];

%% 5. 无人机初始位置
param.plane(1).id   = 'FY1';
param.plane(1).pos0 = [17800    0  1800];

param.plane(2).id   = 'FY2';
param.plane(2).pos0 = [12000 1400  1400];

param.plane(3).id   = 'FY3';
param.plane(3).pos0 = [ 6000 -3000  700];

param.plane(4).id   = 'FY4';
param.plane(4).pos0 = [11000 2000  1800];

param.plane(5).id   = 'FY5';
param.plane(5).pos0 = [13000 -2000 1300];

%% 6. 无人机飞行约束（结构体数组统一赋值）
[param.plane.vMin]   = deal(70.0);   % m/s  最小平飞速度
[param.plane.vMax]   = deal(140.0);  % m/s  最大平飞速度
[param.plane.sepMin] = deal(1.0);    % s    两枚弹最小投放间隔
end