%视场角10度，导弹理论发现目标
function bool=F_isdetect(p_missile,param)
    posTrue = param.target.posTrue; 
    posFake = param.target.posFake;
    vTrue = posTrue - p_missile;
    vFake = posFake - p_missile;

    ang = param.ang;
    line = param.line;
    %计算夹角
    angTrue = rad2deg( acos( dot(vTrue,vFake) / (norm(vTrue)*norm(vFake)) ) );
    lineTrue = norm(p_missile);
    bool = angTrue<ang && lineTrue<line;      
end