% CHECKPOLYGON  Test whether a closed polygon is simple (non-self-intersecting).
%
%   isValid = checkPolygon(cPts)
%
%   Input
%       cPts - N x 2 array of polygon vertices (implicitly closed)
%   Output
%       isValid - 1 if the polygon has no self-intersections (or only
%                 intersections that coincide with shared vertices), 0 if
%                 it contains NaNs or genuinely crosses itself.
%
%   Used by gen_shape_2d to reject random cross-sections whose outline
%   crosses itself. Relies on polygonSelfIntersections from the geom2d
%   toolbox (https://www.mathworks.com/matlabcentral/fileexchange/7844-geom2d),
%   which is not part of this repo and must be on the MATLAB path.
function isValid = checkPolygon(cPts)
    if sum(isnan(cPts(:))) > 0
        isValid = 0;
        return;
    end

    % round to 4 dp to avoid spurious floating-point intersections
    cPts = round((cPts.*10000))/10000;
    inters = polygonSelfIntersections(cPts);
    isValid = isempty(inters);

    % contingency for sharpness morphs: an "intersection" that lands exactly
    % on a polygon vertex (a sharp corner touching itself) is tolerated;
    % only crossings away from the vertices invalidate the polygon
    if ~isValid
        found = 0;
        inters = round((inters.*10000))/10000;
        for i=1:size(inters,1)
            [x,~]=find(cPts == inters(i,1));
            [y,~]=find(cPts == inters(i,2));
            
            if length(x) < 2 || isempty(x) || isempty(y) || ~isequal(x,y)
                found = 1;
                break;
            end
        end
        isValid = ~found;
    end
    
end