clc; clear; close all;
param = makeParam();

vList   = 70:10:140;               % m/s
angList = 176:1:180;               % deg
trListI = 1.0:0.3:3.0;             % s
btListI = 1.0:0.3:5.0;             % s
trListF = 0.8:0.1:3.2;
btListF = 0.8:0.1:5.2;

cm = parula(256).^0.9;
mkEdge = [0.15 0.15 0.15];


DurMap = nan(numel(angList),numel(vList));
BestTR = nan(size(DurMap));
BestTB = nan(size(DurMap));

bestDur = -inf; bestV=NaN; bestAng=NaN; bestTR=NaN; bestTB=NaN;
for ia = 1:numel(angList)
    ang = angList(ia);
    for iv = 1:numel(vList)
        v = vList(iv);
        maxd = -inf; btr = NaN; btb = NaN;
        for tr = trListI
            for bt = btListI
                d = F_q1_objective(v,ang,tr,bt);
                if ~isnan(d) && d>maxd
                    maxd = d; btr = tr; btb = bt;
                end
            end
        end
        DurMap(ia,iv) = maxd; BestTR(ia,iv)=btr; BestTB(ia,iv)=btb;
        if maxd>bestDur
            bestDur=maxd; bestV=v; bestAng=ang; bestTR=btr; bestTB=btb;
        end
    end
end

fixedV = 90.0; fixedAng = 179; fixedTR = 1.0; fixedTB = 3.2; fixedDur = 4.63;

Z = nan(numel(btListF),numel(trListF));
for i = 1:numel(trListF)
    for j = 1:numel(btListF)
        Z(j,i) = F_q1_objective(fixedV,fixedAng,trListF(i),btListF(j));
    end
end


function setAllFont24(ax,cbarH,legendH)
    % 坐标轴
    set(ax, 'FontSize',24);
    % 色标
    if ~isempty(cbarH)
        cbarH.Label.FontSize = 24;
        cbarH.FontSize       = 24;
    end
    % 图例
    if ~isempty(legendH)
        legendH.FontSize = 24;
    end
end

fig1 = figure('Name','S_q2 | 速度-航向 热力图','Color','w');
ax1  = axes(fig1); hold(ax1,'on'); box(ax1,'on'); grid(ax1,'on');
imagesc(ax1,vList,angList,DurMap); set(ax1,'YDir','normal'); colormap(ax1,cm);
c1   = colorbar(ax1); c1.Label.String = '遮蔽时长 / s';
xlabel(ax1,'无人机速度 v / m·s^{-1}'); ylabel(ax1,'航向角 / deg');

label1 = sprintf('最优点 (v=%.0f m/s, ang=%.0f°), 最大遮蔽=%.2f s',fixedV,fixedAng,fixedDur);
scatter(ax1,fixedV,fixedAng,110,'o','MarkerEdgeColor',[0.05 0.05 0.05], ...
        'MarkerFaceColor','none','LineWidth',2.0,'DisplayName',label1);
scatter(ax1,fixedV,fixedAng,30,'o','MarkerEdgeColor','w', ...
        'MarkerFaceColor','w','LineWidth',1.0,'HandleVisibility','off');
lg1 = legend(ax1,'show','Location','southeast');
set(ax1,'GridColor',[0.9 0.9 0.9]);

setAllFont24(ax1,c1,lg1);

try
    out1 = fullfile(pwd,'S_q2_both_v_ang.svg');
    exportgraphics(fig1,out1,'ContentType','vector');
    fprintf('已保存 SVG: %s\n',out1);
catch ME
    warning('导出SVG失败: %s',ME.message);
end

fig2 = figure('Name','S_q2 | t_{rel}-t_{burst} 热力图','Color','w');
ax2  = axes(fig2); hold(ax2,'on'); box(ax2,'on'); grid(ax2,'on');
imagesc(ax2,trListF,btListF,Z); set(ax2,'YDir','normal'); colormap(ax2,cm);
c2   = colorbar(ax2); c2.Label.String = '遮蔽时长 / s';
xlabel(ax2,'释放时刻 t_{rel} / s'); ylabel(ax2,'起爆延时 t_{burst} / s');

label2 = sprintf('最优时序 (t_r=%.1f s, t_b=%.1f s), 最大遮蔽=%.2f s',fixedTR,fixedTB,fixedDur);
scatter(ax2,fixedTR,fixedTB,110,'o','MarkerEdgeColor',[0.05 0.05 0.05], ...
        'MarkerFaceColor','none','LineWidth',2.0,'DisplayName',label2);
scatter(ax2,fixedTR,fixedTB,30,'o','MarkerEdgeColor','w', ...
        'MarkerFaceColor','w','LineWidth',1.0,'HandleVisibility','off');
lg2 = legend(ax2,'show','Location','southeast');
set(ax2,'GridColor',[0.9 0.9 0.9]);

setAllFont24(ax2,c2,lg2);

try
    out2 = fullfile(pwd,'S_q2_both_tr_tb.svg');
    exportgraphics(fig2,out2,'ContentType','vector');
    fprintf('已保存 SVG: %s\n',out2);
catch ME
    warning('导出SVG失败: %s',ME.message);
end