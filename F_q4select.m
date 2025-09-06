function [bestUnion, bestPick, unionInt] = F_q4select(time_sets)
% F_q4select
% 任务：从三个集合中各选取一个区间 [start,end]，使三者的并集长度最大。
% 输入格式（与 test.m 一致）：
%   time_sets 为 1x3 cell：
%     - 每个元素可以是 Kx2 的数值矩阵（每一行是一个可选区间），或 []。
%     - 也兼容 cell 形式：其中每个元素为 1x2 数值向量或 Kx2 矩阵（按行拆成候选）。
% 输出：
%   bestUnion : 最大并集长度（double）
%   bestPick  : 1x3 cell，存放选中的三个区间，每个为 1x2 行向量 [s e]
%   unionInt  : R x 2 矩阵，为这三个区间的并集后的不相交区间集合
%
% 说明：
% - 自动过滤非法或零长度区间（e<=s）。
% - 并集计算将相接/重叠区间视为可合并（s <= 当前末端）。

    if ~iscell(time_sets) || numel(time_sets) ~= 3
        error('time_sets 必须是长度为 3 的元胞数组。');
    end

    % 将每组转为候选区间列表（Nx2 矩阵，每行一个候选）
    C = cell(1,3);
    for g = 1:3
        C{g} = normalizeGroup(time_sets{g}); % Nx2 或 0x2
    end

    % 若任一组无候选，返回空结果
    if any(cellfun(@(x) isempty(x) || size(x,1)==0, C))
        bestUnion = 0; bestPick = {[],[],[]}; unionInt = zeros(0,2);
        return;
    end

    A = C{1}; B = C{2}; D = C{3};
    bestUnion = -inf; bestPick = {[],[],[]}; unionInt = zeros(0,2);

    for i = 1:size(A,1)
        a = A(i,:);
        for j = 1:size(B,1)
            b = B(j,:);
            for k = 1:size(D,1)
                c = D(k,:);
                [uLen, uIv] = unionLength3(a,b,c);
                if uLen > bestUnion
                    bestUnion = uLen;
                    bestPick = {a, b, c};
                    unionInt = uIv;
                end
            end
        end
    end

    % 若均为空导致 bestUnion 仍为 -inf，做兜底
    if ~isfinite(bestUnion)
        bestUnion = 0; bestPick = {[],[],[]}; unionInt = zeros(0,2);
    end
end

% --- 将一组输入标准化为 Nx2 候选列表（每行一个区间） ---
function M = normalizeGroup(g)
    if isempty(g)
        M = zeros(0,2); return;
    end
    if isnumeric(g)
        if isvector(g) && numel(g)==2
            g = g(:).';
        elseif size(g,2) ~= 2
            error('数值输入必须为 Kx2 矩阵或 1x2 向量。');
        end
        M = sanitizeRows(g);
        return;
    end
    if iscell(g)
        allRows = zeros(0,2);
        for t = 1:numel(g)
            x = g{t};
            if isempty(x)
                continue;
            elseif isnumeric(x)
                if isvector(x) && numel(x)==2
                    allRows(end+1,:) = x(:).'; 
                elseif size(x,2)==2
                    allRows = [allRows; x]; 
                else
                    error('cell 内的数值元素需为 1x2 或 Kx2。');
                end
            else
                error('cell 内元素必须为数值数组或空。');
            end
        end
        M = sanitizeRows(allRows);
        return;
    end
    error('不支持的输入类型。');
end

% --- 过滤非法/零长度区间，并确保每行 [s e] 且 s<=e ---
function M = sanitizeRows(X)
    if isempty(X)
        M = zeros(0,2); return;
    end
    if size(X,2) ~= 2
        error('内部错误：sanitizeRows 期望 Kx2 矩阵');
    end
    s = X(:,1); e = X(:,2);
    swap = s>e; if any(swap), tmp=s(swap); s(swap)=e(swap); e(swap)=tmp; end
    valid = isfinite(s) & isfinite(e) & (e>s);
    M = [s(valid), e(valid)];
end

% --- 三个区间的并集长度与并集区间 ---
function [len, merged] = unionLength3(a,b,c)
    iv = zeros(0,2);
    if ~isempty(a), iv(end+1,:) = a; end 
    if ~isempty(b), iv(end+1,:) = b; end 
    if ~isempty(c), iv(end+1,:) = c; end 
    if isempty(iv)
        len = 0; merged = zeros(0,2); return;
    end
    iv = sortrows(iv,1);
    merged = iv(1,:);
    for r = 2:size(iv,1)
        if iv(r,1) <= merged(end,2)
            merged(end,2) = max(merged(end,2), iv(r,2));
        else
            merged(end+1,:) = iv(r,:); 
        end
    end
    len = sum(merged(:,2)-merged(:,1));
end
