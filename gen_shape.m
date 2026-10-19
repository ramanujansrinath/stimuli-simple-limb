% GEN_SHAPE  Generate a 3D "limb" shape: a curved tube with a lumpy cross-section.
%
%   shape = gen_shape()                     - fully random shape
%   shape = gen_shape([], 'name',value,...) - random, with some params fixed
%   shape = gen_shape(params)               - rebuild/modify from a saved
%                                             shape.params struct
%
%   Construction
%     1. A curved medial axis (circular arc) of length maLen and curvature
%        maCurv is sampled at ma.pts (31) points  (getCurvedAxis).
%     2. A random irregular, possibly concave 2D outline (gen_shape_2d,
%        irregularity set by surfComp) is the cross-section.
%     3. At each axis point the cross-section is twisted (angle ramps from
%        0 to surfTwist along the axis), scaled in x and y by a radius
%        profile that tapers to zero at both ends (getRadProf), rotated to
%        be perpendicular to the axis, and placed on the axis (makeShape).
%     4. Consecutive rings are joined into a triangle mesh, the whole shape
%        is scaled, rotated and positioned, and the mesh is optionally
%        smoothed.
%
%   Optional name/value inputs (all default to a random draw)
%     Global
%       stimColor  - [r g b] surface colour (default: getColor, random)
%       stimGloss  - specular strength, 0-1
%       stimOri    - [rx ry rz] rotation (rad) applied to the finished shape
%       stimSize   - overall scale factor, 0-1
%       stimPos    - [x y z] position offset
%     Medial axis
%       maCurv     - axis curvature (1/radius); 0 gives a straight axis
%       maLen      - axis arc length
%       maJunc     - [x y z] point to translate the axis start to (for
%                    attaching limbs at a junction); [] = unused
%     Surface
%       surfComp   - cross-section complexity (0-1)
%       surfTwist  - total twist along the axis, 0-pi rad
%       surfThkns  - 1x3 interior values of the width profile (see
%                    getRadProfXY)
%       surfProf   - explicit N x 2 [x-radius y-radius] profile, overriding
%                    surfThkns (N must equal ma.pts)
%       surfSmooth - true (default) to smooth the mesh (smoothVert)
%
%   Output struct
%       shape.vert   - V x 3 mesh vertices
%       shape.face   - F x 3 triangle indices into vert
%       shape.axis   - M x 3 medial axis in the same final coordinates
%       shape.params - everything needed to regenerate the shape; pass it
%                      back in to gen_shape to reproduce it, or edit fields
%                      (e.g. params.ma.curve) first to change that property
%
%   See also gen_stim, disp_shape, gen_shape_2d.
function shape = gen_shape(params,varargin)
    if ~exist('params','var'); params = []; end
    % parse optional inputs; defaults are evaluated once per call, so each
    % random default is a fresh draw
    p =  inputParser;
    addOptional(p,'stimColor',getColor); % @(x) length(x)==3 && sum(x>1)==0
    addOptional(p,'stimGloss',0.001+0.7*rand,@(x) isnumeric(x) && isscalar(x) && (x > 0) && (x < 1));
    addOptional(p,'stimOri',[pi.*rand pi.*rand pi.*rand],@(x) length(x)==3);
    addOptional(p,'stimSize',0.8+0.2*rand,@(x) isnumeric(x) && isscalar(x) && (x > 0) && (x < 1));
    addOptional(p,'stimPos',[rand(1,2) 0],@(x) length(x)==3);
    
    addOptional(p,'maCurv',rand,@(x) isnumeric(x) && isscalar(x) && (x > 0) && (x < 2));
    addOptional(p,'maLen',3.5+1*rand,@(x) isnumeric(x) && isscalar(x) && (x > 1) && (x <= 4));
    addOptional(p,'maJunc',[]);
    
    addOptional(p,'surfComp',rand,@(x) isnumeric(x) && isscalar(x) && (x > 0) && (x < 1));
    addOptional(p,'surfTwist',rand*pi,@(x) isnumeric(x) && isscalar(x) && (x >= 0) && (x <= pi));
    addOptional(p,'surfThkns',0.1+0.6*rand(1,3)); % ,@(x) length(x)==3 && sum(x>0.7)==0 && sum(x<0.1)==0
    addOptional(p,'surfProf',[]);

    addOptional(p,'surfSmooth',true,@islogical);
    
    parse(p,varargin{:});
    
    stimColor = p.Results.stimColor;
    stimGloss = p.Results.stimGloss;
    stimOri = p.Results.stimOri;
    stimSize = p.Results.stimSize;
    stimPos = p.Results.stimPos;
    
    maCurv = p.Results.maCurv;
    maLen = p.Results.maLen;
    maJunc = p.Results.maJunc;
    
    surfTwist = p.Results.surfTwist;
    surfComp = p.Results.surfComp;
    surfThkns = p.Results.surfThkns;
    surfProf = p.Results.surfProf;
    surfSmooth = p.Results.surfSmooth;
    
    % new shape: build the parameter struct from the (random) options above
    if isempty(params)
        % medial axis
        params.ma.pts = 31;
        params.ma.curve = maCurv;
        params.ma.length = maLen;
        params.ma.junction = maJunc;
        params.ma.axis = getCurvedAxis(params.ma);

        % surface
        params.surface.cs.comp = surfComp;
        [cPts,dPts] = gen_shape_2d(surfComp,false);
        params.surface.cs.cPts = cPts;
        params.surface.cs.dPts = dPts;
        [radProf,radProfXY] = getRadProf(params.ma.pts,surfThkns,surfProf);
        params.surface.radProfXY = radProfXY;
        params.surface.radProf = radProf;
        params.surface.twistProf = linspace(0,surfTwist,params.ma.pts); 
        params.surface.doSmooth = surfSmooth;

        % global
        % light sits on a circle of radius 10 in the x-z plane, 5 above it,
        % at a random x position in front of the shape (z > 0)
        params.pos = stimPos;
        params.rot = stimOri; % [pi.*rand (pi/2-pi/8)+(pi/4*rand) pi.*rand];
        params.size = stimSize;
        params.color = stimColor;
        params.gloss = stimGloss;
        tt = -10 + 20*rand;
        params.light = [tt; 5; sqrt(100-(tt.^2))];
    else
        % existing shape: recompute axis and radius profile from the
        % (possibly edited) params
        params.ma.axis = getCurvedAxis(params.ma);
        % todo: what if radprofXY is changed but radprof exists? then
        % radprof doesn't change. Fix this;
        params.surface.radProf = getRadProf(params.ma.pts,params.surface.radProfXY,params.surface.radProf);
    end
    
    % final gen shape
    params.morphType = 0;
    [vert,face,ax] = makeShape(params);
    shape.vert = vert;
    shape.face = face;
    shape.axis = ax; % this is because the axis in shape.params.ma is not the right size or pos
    shape.params = params;
end

% MAKESHAPE  Turn a params struct into mesh vertices, faces and axis.
%
%   [vert, face, ax] = makeShape(params)
%
%   Vertex layout: vertex 1 is the apex of the start cap, then one ring of
%   nCsPts vertices for each interior axis point (2..ma.pts-1), then the
%   apex of the end cap as the last vertex. The first and last cross-
%   sections are collapsed to single points (the radius profile is zero
%   there), so nVert = nCsPts*(ma.pts-2) + 2.
%
%   Face topology depends only on ma.pts and the number of cross-section
%   points, so it is computed once and cached in export/face_<ma.pts>.txt
%   (delete the file if either changes). Faces are triangle fans at the two
%   caps and two triangles per quad between adjacent rings.
%
%   After meshing, the shape is centred on its bounding box, scaled by
%   params.size, rotated by params.rot, translated to params.pos (or to
%   params.ma.junction if set) and optionally smoothed. ax is transformed
%   identically so it stays aligned with the mesh (smoothing excepted).
function [vert,face,ax] = makeShape(params)
    cs = params.surface.cs.dPts;
    nCsPts = size(cs,1);
    nVert = size(cs,1)*params.ma.pts - nCsPts+1 - nCsPts+1;

    vert = nan(nVert,3);

    % vert - assemble cs
    % for each axis point: twist -> scale by radius profile -> rotate to the
    % local axis direction -> move onto the axis
    for ii=1:params.ma.pts
        csspin = movePts(cs,0,0,1,rad2deg(params.surface.twistProf(ii)),[0 0]);
        cssc = [csspin(:,1).*params.surface.radProf(ii,1) csspin(:,2).*params.surface.radProf(ii,2) zeros(nCsPts,1)]; % scale
        csrot = rotvert(cssc,[params.ma.axis.ang(ii) 0 0]); % rotate for ma
        pos = params.ma.axis.pos(ii,:);
        
        sec =  csrot + repmat(pos,nCsPts,1); % shift

        % end rings have zero radius, so a single point stands in for them
        if ii==1
            vert(1,:) = sec(1,:);
        elseif ii==params.ma.pts
            vert(nVert,:) = sec(1,:);
        else
            vert(nCsPts*(ii-2)+2 : 1+nCsPts*(ii-1), :) = sec;
        end

        % plot3(vert(:,1),vert(:,2),vert(:,3),'r.'); 
        % axis equal; axis off; set(gca,'XLim',[-2 2]); view(-14,-14);
    end
    % centre mesh (and axis) on the bounding box of the mesh
    ax = params.ma.axis.pos;
    ax = ax - repmat((min(vert)+max(vert))/2,size(ax,1),1);
    vert = vert - repmat((min(vert)+max(vert))/2,nVert,1);
    vert = round(vert,4);

    % faces: load cached topology, or build and cache it on first use
    filepath = fileparts(mfilename('fullpath'));
    facepath = [filepath '/export/face_' num2str(params.ma.pts) '.txt'];
    if ~exist(facepath,'file')
        face = [];
        % face - end cap
        for ii=2:nCsPts+1
            face = [face ; 1 ii (ii+1)]; %#ok<AGROW>
        end
        face(end,3) = 2;

        % face - middle: stitch ring ii to ring ii+1 with two triangles per
        % quad, wrapping the last point of a ring back to its first
        for ii=2:params.ma.pts-2
            thisRow = 2+(ii-2)*nCsPts : 1+(ii-1)*nCsPts;
            nextRow = 2+(ii-1)*nCsPts : 1+ii*nCsPts;
            % plot3(vert(thisRow,1),vert(thisRow,2),vert(thisRow,3),'r.'); hold on
            % plot3(vert(nextRow,1),vert(nextRow,2),vert(nextRow,3),'b.')

            for jj=1:nCsPts
                if jj<nCsPts
                    face = [face; thisRow(jj) nextRow(jj) nextRow(jj+1)]; %#ok<AGROW>
                    % patch(vert(face(end,:),1),vert(face(end,:),2),vert(face(end,:),3),'c','facealpha',0.2,'edgecolor','none');
                    face = [face; thisRow(jj) nextRow(jj+1) thisRow(jj+1)]; %#ok<AGROW>
                    % patch(vert(face(end,:),1),vert(face(end,:),2),vert(face(end,:),3),'c','facealpha',0.2,'edgecolor','none');
                else
                    face = [face; thisRow(jj) nextRow(jj) nextRow(1)]; %#ok<AGROW>
                    % patch(vert(face(end,:),1),vert(face(end,:),2),vert(face(end,:),3),'k','facealpha',0.8);
                    face = [face; thisRow(jj) nextRow(1) thisRow(1)]; %#ok<AGROW>
                    % patch(vert(face(end,:),1),vert(face(end,:),2),vert(face(end,:),3),'k','facealpha',0.8);
                end
            end
        end

        % face - end cap
        for ii=1:nCsPts-1
            face = [face; nextRow(ii) nVert nextRow(ii+1)]; %#ok<AGROW>
        end
        face(end+1,:) = [nextRow(end) nVert nextRow(1)];
        writematrix(face,facepath);
    else
        face = readmatrix(facepath);
    end
    
    % global transform: scale -> rotate -> translate
    ax =  ax .* params.size;
    ax = rotvert(ax,params.rot);
    ax =  ax + repmat(params.pos,size(ax,1),1);
    
    vert =  vert .* params.size;
    vert = rotvert(vert,params.rot);
    vert =  vert + repmat(params.pos,size(vert,1),1);
    
    % translate to junction point: move the shape so the axis start sits on
    % the requested junction (used to attach this limb to another)
    if ~isempty(params.ma.junction)
        pos = params.ma.junction - ax(1,:);
        ax =  ax + repmat(pos,size(ax,1),1);
        vert =  vert + repmat(pos,size(vert,1),1);
    end
    
    if params.surface.doSmooth
        vert = smoothVert(vert,face);
    end
end

% SMOOTHVERT  Laplacian-style mesh smoothing.
%   Runs 20 passes; in each pass every vertex is replaced by the mean of
%   its mesh neighbours (vertices sharing a face; the vertex itself is not
%   included). This rounds off sharp ridges from the cross-section and
%   removes the faceting between rings. Neighbour lists are computed once
%   and cached across passes. Smoothing also shrinks the mesh slightly.
function vert = smoothVert(vert,face)
    neigh = cell(size(vert,1),1);
    for smoothTimes=1:20
        smVert = zeros(size(vert));
        for ii=1:length(vert)
            if isempty(neigh{ii})
                a = face(sum(face==ii,2)>0,:);
                a = a(:); 
                a(a==ii) = [];
                neigh{ii} = a;
            end
                
            smVert(ii,:) = mean(vert(neigh{ii},:));
        end
        vert = smVert;
    end
end

% ROTVERT  Rotate N x 3 row-vector points by Euler angles (radians).
%   rot = [rx ry rz]; rotations are applied in the order x, then y, then z
%   using row-vector (post-multiply) convention.
function vert = rotvert(vert,rot)
    rx = [1 0 0; 0 cos(rot(1)) -sin(rot(1)); 0 sin(rot(1)) cos(rot(1))];
    ry = [cos(rot(2)) 0 sin(rot(2)); 0 1 0; -sin(rot(2)) 0 cos(rot(2))];
    rz = [cos(rot(3)) -sin(rot(3)) 0; sin(rot(3)) cos(rot(3)) 0; 0 0 1];

    vert = vert * rx;
    vert = vert * ry;
    vert = vert * rz;
end

% GETRADPROFXY  Control points [position width] for the radius profile.
%   Positions along the axis (0-1) are five values: 0, three jittered
%   interior positions, and 1. Widths are 0 at both ends and the three
%   surfThkns values in between, so the limb tapers to a point at each end.
%   If surfThkns is already a 5-row array it is returned unchanged.
function radProfXY = getRadProfXY(surfThkns)
    if size(surfThkns,1) == 5
        radProfXY = surfThkns;
    else
        x = [0 0.1+0.2*rand 0.4+0.2*rand 0.7+0.2*rand 1];
        y = [0 surfThkns 0];
        radProfXY = [x' y'];
    end
end

% GETRADPROF  Per-axis-point cross-section scale factors.
%
%   [rProf, cPts] = getRadProf(nPts, surfThkns, surfProf)
%
%   Spline-interpolates the control points from getRadProfXY to nPts
%   samples along the axis, retrying (up to 100 times) if the spline dips
%   below zero. Column 1 of rProf scales the cross-section in x; column 2
%   scales it in y by a random factor of 0.5-2, giving an elliptical
%   aspect ratio that is the same at every point along the limb.
%   If surfProf is supplied it is returned directly (cPts empty).
%       rProf - nPts x 2 scale factors
%       cPts  - the control points used (stored so the profile can be edited)
function [rProf,cPts] = getRadProf(nPts,surfThkns,surfProf)
    if ~isempty(surfProf)
        rProf = surfProf;
        cPts = [];
        return
    end

    tryTimes = 0;
    maxTryTimes = 100;
    
    while tryTimes < maxTryTimes
        cPts = getRadProfXY(surfThkns);
        xx = linspace(0,1,nPts);
        yy = interp1(cPts(:,1),cPts(:,2),xx,'spline');
        if sum(yy<0)
            tryTimes = tryTimes + 1;
        else
            break;
        end
    end
    
    if tryTimes == maxTryTimes
        error('Couldn''t find a good rad profile');
    end
    
    rProf(:,1) = yy;
    rProf(:,2) = rProf(:,1)*(0.5+1.5*rand);
    rProf = round(rProf,4);
end
    
% GETCURVEDAXIS  Sample the circular-arc medial axis.
%
%   ax = getCurvedAxis(ma)   with ma.length, ma.curve, ma.pts
%
%   The arc has radius 1/curve and arc length ma.length (a curve of 0 uses a
%   huge radius, giving a near-straight axis). It lies in the y-z plane
%   (x = 0), is symmetric about its midpoint and is shifted so its highest
%   point is at y = 0. A point is added past the end to get the tangent at
%   the last sample.
%       ax.pos - pts x 3 axis positions
%       ax.tan - pts x 3 unit tangent vectors
%       ax.ang - pts x 1 rotation about x (rad) that turns the cross-section
%                plane to be perpendicular to the axis at each point
function ax = getCurvedAxis(ma)
    len = ma.length;
    curve = ma.curve;
    nPts = ma.pts;
    
    if ma.curve == 0
        rad = 1/0.000001;
    else
        rad = 1/curve; 
    end
    
    % uneven sampling
    % len = len/pi; % specified len is arc length, not rad
    % x = linspace(-len/2,len/2,nPts);
    % y = sqrt(rad^2-x.^2);
    % y = y-max(y);
    
    th = (pi+len/rad)/2 - linspace(0,len/rad,nPts);
    th(end+1) = th(end)-(th(end-1)-th(end)); % for tangents
    x = rad*cos(th);
    y = rad*sin(th);
    y = y-max(y);

    ma = [zeros(1,nPts+1); y; x]';
    tang = circshift(ma,-1) - ma;
    ma(end,:) = [];
    tang(end,:) = [];
    tang = tang./repmat(sqrt(sum(tang.^2,2)),1,3); % unit vec
    
    ax.pos = ma;
    ax.tan = tang;
    ax.ang = atan2(tang(:,2),tang(:,3));
    
    % plot3(ma(:,1),ma(:,2),ma(:,3),'b.'); axis equal; grid on; view(0,90); hold on;
    % for ii=1:nPts
    %     p1 = ma(ii,:);
    %     p2 = p1 + 0.2*tang(ii,:);
    %     hl = line([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'color','r','linewidth',2);
    %     pause
    %     delete(hl)
    % end
end
