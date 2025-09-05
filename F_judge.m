function t_end=F_judge(t1,t2,t3,t4)

    if t3<t1
        if t4<=t2
            t_end=t4-t1;
        end
        if t4>t2
            t_end=t2-t1;
        end
    end
end