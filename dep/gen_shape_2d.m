% % testing
% figure('color','w','pos',[1,1,1176,954]);
% for ii=1:100
%     subplot(10,10,ii);
%     gen_shape_2d(ii/100,1);
% end

function [cPts,dPts] = gen_shape_2d(complexity,doPlot,nMApts)
    if ~exist('complexity','var'); complexity = rand; end
    if ~exist('doPlot','var'); doPlot = 1; end
    if ~exist('nMApts','var'); nMApts = 200; end
    [cPts,dPts] = genRandShape(complexity,nMApts);
    
    if doPlot
        cla; 
        plot(dPts(:,1),dPts(:,2),'r.'); hold on; 
        plot([cPts(:,1);cPts(1,1)],[cPts(:,2);cPts(1,2)],'b.-','MarkerSize',10); 
        title(round(complexity,2));
        axis equal; axis off;
    end
end

function [cPts,dPts] = genRandShape(complexity,nMApts)
    cPts = genRandCircShape(complexity);
    while ~checkPolygon(cPts)
        cPts = genRandCircShape(complexity);
    end
    dPts = getDensePoints(cPts,[],nMApts,1);
    cPts = cPts - repmat((min(dPts)+max(dPts))/2,size(cPts,1),1);
    dPts = dPts - repmat((min(dPts)+max(dPts))/2,size(dPts,1),1);
end

function cPts = genRandCircShape(complexity)
    maxPts = 20;
    minPts = 15;
    nPts = minPts + round(complexity.*(maxPts-minPts));
    r = 1 * ones(1,nPts);
    th = linspace(0,2*pi,nPts+1);  th=th(1:end-1);
    
    [r,th] = randomizeCircle(r,th,complexity);
    
    x = r .* cos(th);
    y = r .* sin(th);
    cPts = [x; y]';
end

function [r,th] = randomizeCircle(r,th,complexity)
    % group morphs
    % nPtsToMorph = 1+floor(0.5*complexity.*(size(r,2)-1));
    % a = randi(nPtsToMorph);
    % if nPtsToMorph>a; b = randi(nPtsToMorph-a); else; b=0; end
    % if nPtsToMorph>(a+b); c = nPtsToMorph-a-b; else; c=0; end
    % nPtsToMorph = [a b c]; nPtsToMorph(nPtsToMorph==0) = [];
    % for ii=1:length(nPtsToMorph)
    %     indicesToMorph = (0:(nPtsToMorph(ii)-1)) + randi(length(r));
    %     indicesToMorph(indicesToMorph>length(r)) = indicesToMorph(indicesToMorph>length(r))-length(r);
    %     r(indicesToMorph) = r(indicesToMorph) .* (0.1 + complexity*rand(1,nPtsToMorph(ii)));
    %     % th(indicesToMorph) = th(indicesToMorph) - pi/6 + 2*pi/6*complexity*rand(1,nPtsToMorph(ii));
    % end
    
    % all random morphs
    % complexity = complexity/2;
    nPtsToMorph = floor(complexity.*(size(r,2)-1));
    if nPtsToMorph > 0
        indicesToMorph = sort(randperm(size(r,2),nPtsToMorph));
        r(indicesToMorph) = r(indicesToMorph) + r(indicesToMorph).*(complexity*rand(1,nPtsToMorph));
        th(indicesToMorph) = th(indicesToMorph) + pi/6*complexity*rand(1,nPtsToMorph);
    end
end

function densePts = getDensePoints(cPts,idx,sampling,closeCurve)
    if ~exist('sampling','var'); sampling = 100; end
    if ~exist('closeCurve','var'); closeCurve = 1; end
    

    deg = 3; order = deg + 1;
    n = size(cPts,1); 
    if closeCurve
        overlapCPts = [cPts; cPts(1:deg,:)];
    else
        overlapCPts = cPts;
        n = n-deg;
    end
    knotVec = linspace(0,1,n+deg+order);
    sp = spmak(knotVec,overlapCPts');
    
    % if the index is specified, then only calculate the spline for that
    % index. But if it is not, or it is empty, then calculate it for the
    % whole shape
    if ~exist('idx','var')
        x = linspace(knotVec(order),knotVec(n+order),sampling);
    elseif isempty(idx)
        x = linspace(knotVec(order),knotVec(n+order),sampling);
    elseif idx == 1
        x = knotVec(n + deg);
    else
        x = knotVec(idx + deg - 1);
    end
    densePts = fnval(sp,x)';
end