function snow = gen_snow()
    tt = linspace(-5,5,101);
    sparseness = 0.001;
    [xx,yy,zz] = ndgrid(tt,tt,tt);
    xx = xx(:); yy = yy(:); zz = zz(:);
    idx = randperm(length(xx),round(sparseness*length(xx)));
    
    snow.xx = xx(idx);
    snow.yy = yy(idx);
    snow.zz = zz(idx);
    
    idx = snow.yy<=0 ;
    snow.xx(idx) = [];
    snow.zz(idx) = [];
    snow.yy(idx) = [];
    
    snow.ss = getSigmoid([50 100 2 1],snow.zz);
    snow.ss = 50+50*rand(1,length(snow.zz));
end