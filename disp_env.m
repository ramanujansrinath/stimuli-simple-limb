function hp = disp_env(h,env)
    hold(h,'on');

    % either warp or surf

    im = imread('dep/grid.png');
    hp = warp(env.xx,env.yy,env.zz,im); hold(h,'on');

    % hp = surf(env.xx,env.yy,env.zz,'parent',h);
    % hp.FaceColor = [0.4 0.8 0.8];

    hp.FaceAlpha = 1;
    hp.EdgeColor = 'none';
    hp.FaceLighting = 'gouraud';
    material(hp,[0.4 0.6 0.2 5 0.1]);
    
    colormap(env.params.room);
    
    axis(h,'off'); axis(h,'equal');
    set(h,'Projection','perspective')
    set(h,'CameraUpVector',[0 1 0])
    set(h,'CameraViewAngle',40)
    set(h,'CameraTarget',[0 1 0])
    set(h,'CameraPosition',[0 1 5]) 
end