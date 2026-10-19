% GEN_SNOW  Generate a sparse cloud of random 3D points ("snow").
%
%   snow = gen_snow()
%
%   The snow is a depth/occlusion cue: small bright dots scattered in front
%   of and behind the shape give extra 3D context. Points are drawn
%   uniformly at random from a 101^3 lattice spanning [-5,5] in x, y and z,
%   keeping 0.1% of lattice nodes. Points at or below y = 0 (i.e. below the
%   ground plane) are discarded.
%
%   Output (all column vectors of equal length)
%       snow.xx, snow.yy, snow.zz - point coordinates
%       snow.ss                   - marker size per point (scatter3 units),
%                                   random in [50,100]
%
%   See also gen_stim, disp_stim.
function snow = gen_snow()
    % full lattice of candidate positions
    tt = linspace(-5,5,101);
    sparseness = 0.001;   % fraction of lattice nodes that become snow
    [xx,yy,zz] = ndgrid(tt,tt,tt);
    xx = xx(:); yy = yy(:); zz = zz(:);
    % pick a random subset of nodes
    idx = randperm(length(xx),round(sparseness*length(xx)));

    snow.xx = xx(idx);
    snow.yy = yy(idx);
    snow.zz = zz(idx);
    
    % drop points below the ground plane
    idx = snow.yy<=0 ;
    snow.xx(idx) = [];
    snow.zz(idx) = [];
    snow.yy(idx) = [];
    
    % snow.ss = getSigmoid([50 100 2 1],snow.zz);
    snow.ss = 50+50*rand(1,length(snow.zz));
end