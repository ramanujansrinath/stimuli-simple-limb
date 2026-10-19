function disp_stim(h,stim,dispProps)
    cla(h)
    if ~exist('dispProps','var')
        dispProps.shape = 1;
        dispProps.axis = 0;
        dispProps.env = 0;
        dispProps.snow = 0;
    end
    if ~isempty(stim.env) && dispProps.env
        disp_env(h,stim.env)
        
        if ~isempty(stim.shape)
            [~,xidx] = min(abs(stim.env.params.tt - stim.shape.params.pos(1)));
            [~,zidx] = min(abs(stim.env.params.tt - stim.shape.params.pos(3)));
            
            stim.shape.axis(:,1) = stim.shape.axis(:,1) - stim.env.params.tt(xidx);
            stim.shape.axis(:,3) = stim.shape.axis(:,3) - stim.env.params.tt(zidx);
            stim.shape.axis(:,2) = stim.shape.axis(:,2) - min(stim.shape.vert(:,2)) + stim.env.yy(xidx,zidx);
            
            stim.shape.vert(:,1) = stim.shape.vert(:,1) - stim.env.params.tt(xidx);
            stim.shape.vert(:,3) = stim.shape.vert(:,3) - stim.env.params.tt(zidx);
            stim.shape.vert(:,2) = stim.shape.vert(:,2) - min(stim.shape.vert(:,2)) + stim.env.yy(xidx,zidx);
        end
    end
    
    if ~isempty(stim.shape) && dispProps.shape
        disp_shape(h,stim.shape,dispProps.axis);
    end
    
    if ~isempty(stim.snow) && dispProps.snow
        col = repmat(0.7+0.2*rand(1,length(stim.snow.xx)),3,1)';
        scatter3(h,stim.snow.xx,stim.snow.yy,stim.snow.zz,stim.snow.ss,col,'filled')
    end
end