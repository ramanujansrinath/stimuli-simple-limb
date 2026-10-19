% MOVEPTS  Rotate, scale and translate a set of 2D points.
%
%   movedPts = movePts(pts, x, y, s, o, rotateAboutXY)
%
%   Inputs
%       pts           - N x 2 array of [x y] points
%       x, y          - translation applied last
%       s             - uniform scale factor
%       o             - rotation in DEGREES (counter-clockwise)
%       rotateAboutXY - [x y] pivot for the rotation, also the origin that
%                       scaling is relative to
%   Output
%       movedPts      - N x 2 transformed points
%
%   Order of operations: rotate about pivot -> scale -> add pivot back ->
%   translate by [x y]. In gen_shape it is used with s=1 to spin each
%   cross-section about the origin (twist).
function movedPts = movePts(pts,x,y,s,o,rotateAboutXY)    
    [th,r] = cart2pol(pts(:,1) - rotateAboutXY(1),pts(:,2) - rotateAboutXY(2));
    th = th+deg2rad(o);
    [x1,y1] = pol2cart(th,r);
    
    movedPts = [x1 y1] * s;
        
    movedPts = movedPts + repmat(rotateAboutXY,size(pts,1),1);
    
    movedPts(:,1) = movedPts(:,1) + x;
    movedPts(:,2) = movedPts(:,2) + y;
end
