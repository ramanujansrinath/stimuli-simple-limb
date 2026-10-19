% DISP_SHAPE  Render one or more limb shapes on an axes.
%
%   disp_shape(h, shape, showAxis, centerOnShape)
%
%   Inputs
%       h             - target axes handle (e.g. gca)
%       shape         - struct (or struct array) from gen_shape
%       showAxis      - if true, make the surface semi-transparent and draw
%                       the medial axis as a red line
%       centerOnShape - (default true) point the camera at the mean vertex
%                       position of the shape(s). Pass 0 to keep the camera
%                       target unchanged (e.g. when drawing over an env).
%
%   Example
%       disp_shape(gca, gen_shape, 0, 0);
%
%   See also gen_shape, disp_stim.
function disp_shape(h,shape,showAxis,centerOnShape)
    if ~exist('centerOnShape','var'); centerOnShape = true; end
    camTar = zeros(length(shape),3);
    % draw each shape and record its centroid for camera targeting
    for ii=1:length(shape)
        disp_shape_single(h,shape(ii),showAxis)
        camTar(ii,:) = mean(shape(ii).vert);
    end
    if centerOnShape
        set(h,'CameraTarget',mean(camTar,1));
    end
end

% DISP_SHAPE_SINGLE  Draw one shape mesh with lighting, colour and camera.
%
%   Renders shape.vert/shape.face as a smooth-shaded patch coloured with
%   shape.params.color; shape.params.gloss sets specular strength. Adds a
%   point light at shape.params.light unless the axes already has one, then
%   applies the shared perspective camera (view angle 40, camera at [0 1 5],
%   y up).
function disp_shape_single(h,shape,showAxis)
    if ~exist('showAxis','var'); showAxis = 0; end

    vert = shape.vert;
    face = shape.face;
    
    hp = patch('vertices',vert,'faces',face,'parent',h); hold(h,'on');
    hp.EdgeColor = 'none'; 
    hp.FaceColor = shape.params.color;
    hp.FaceAlpha = 1;
    hp.FaceLighting = 'gouraud';
    material(hp,[0.2 0.7 shape.params.gloss 20 0.5]);
    
    if showAxis
        ax = shape.axis;
        hp.FaceAlpha = 0.7;
        plot3(ax(:,1),ax(:,2),ax(:,3),'-','LineWidth',3,'color','r'); % 1-shape.params.color
    end

    % only add a light once, so multiple shapes (or a shape over an env)
    % share a single light source
    ch = get(h,'children');
    lightExists = sum(arrayfun(@(x) contains(class(ch(x)),'Light'),1:length(ch)));
    if ~lightExists
        light('parent',h,'Position',shape.params.light); 
    end
    % shape.params.light(3) = -shape.params.light(3);
    % light('parent',h,'Position',shape.params.light);
    % hl.Style = 'infinite';
    
    axis(h,'off'); axis(h,'equal');
    set(h,'Projection','perspective')
    set(h,'CameraUpVector',[0 1 0])
    set(h,'CameraViewAngle',40)
    set(h,'CameraPosition',[0,1,5]);
end