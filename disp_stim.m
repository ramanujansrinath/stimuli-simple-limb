% DISP_STIM  Render a full stimulus (shape, environment, snow) on an axes.
%
%   disp_stim(h, stim, dispProps)
%
%   Clears axes h and draws the components of stim (from gen_stim) that are
%   both present and switched on in dispProps.
%
%   Inputs
%       h         - target axes handle
%       stim      - struct from gen_stim (.shape, .env, .snow)
%       dispProps - struct of 0/1 flags (default: shape only)
%           .shape - draw the limb shape
%           .axis  - overlay the medial axis (passed to disp_shape)
%           .env   - draw the ground plane
%           .snow  - draw the snow particles
%
%   When the environment is drawn, the shape is placed on the terrain: it
%   is shifted horizontally to the grid point nearest its params.pos (x,z)
%   and vertically so its lowest vertex rests on the terrain height there.
%   This shifts a local copy only; the stim struct is not modified.
%
%   Example
%       stim = gen_stim(1,1);
%       dp = struct('shape',1,'axis',0,'env',1,'snow',1);
%       disp_stim(gca, stim, dp)
%
%   See also gen_stim, disp_shape, disp_env.
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

        % rest the shape on the terrain: find the nearest grid indices to
        % the shape's (x,z) position, then translate vertices and axis
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
    
    % snow: random grey levels (0.7-0.9) per point, drawn as filled dots
    if ~isempty(stim.snow) && dispProps.snow
        col = repmat(0.7+0.2*rand(1,length(stim.snow.xx)),3,1)';
        scatter3(h,stim.snow.xx,stim.snow.yy,stim.snow.zz,stim.snow.ss,col,'filled')
    end
end