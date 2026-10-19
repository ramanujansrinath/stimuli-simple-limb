% DISP_ENV  Render the ground-plane environment from gen_env.
%
%   hp = disp_env(h, env)
%
%   Draws the height map env as a grid-textured surface on axes h and sets
%   up the perspective camera (view angle 40, camera at [0 1 5] looking at
%   [0 1 0], y up) used for the whole scene. Texture is dep/grid.png,
%   which supplies a texture-gradient depth cue; the path is relative, so
%   run from the repo root.
%
%   Inputs
%       h   - target axes handle
%       env - struct from gen_env
%   Output
%       hp  - handle to the surface object
%
%   See also gen_env, disp_stim.
function hp = disp_env(h,env)
    hold(h,'on');

    % either warp (grid texture) or surf (flat colour); warp is active
    im = imread('dep/grid.png');
    hp = warp(env.xx,env.yy,env.zz,im); hold(h,'on');

    % hp = surf(env.xx,env.yy,env.zz,'parent',h);
    % hp.FaceColor = [0.4 0.8 0.8];

    hp.FaceAlpha = 1;
    hp.EdgeColor = 'none';
    hp.FaceLighting = 'gouraud';
    material(hp,[0.4 0.6 0.2 5 0.1]);
    
    colormap(env.params.room);
    
    % scene camera
    axis(h,'off'); axis(h,'equal');
    set(h,'Projection','perspective')
    set(h,'CameraUpVector',[0 1 0])
    set(h,'CameraViewAngle',40)
    set(h,'CameraTarget',[0 1 0])
    set(h,'CameraPosition',[0 1 5]) 
end