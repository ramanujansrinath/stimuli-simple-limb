% GEN_ENV  Generate a ground-plane "environment" as a height map.
%
%   env = gen_env()          - new random terrain
%   env = gen_env(params)    - rebuild terrain from a saved params struct
%
%   The ground is an nPts x nPts grid over [-lims,lims] in x and z, with
%   height y given by 2D OpenSimplex noise (dep/OpenSimplex.jar, called
%   through the Java interface). It provides texture-gradient and
%   support-surface cues when rendered by disp_env / disp_stim.
%
%   params fields (random defaults are filled in if params.bumpy is absent)
%       flat        - if true, terrain is flat (bumpy = bumpyH = 0)
%       room        - colormap used for rendering (default gray)
%       bumpy       - noise spatial frequency (0.4-0.7); 0 = flat
%       bumpyH      - noise amplitude, i.e. hill height (0.1-0.3)
%       lims, nPts  - half-extent of the grid (15) and samples per side (51)
%       simplexSeed - noise seed (random int); reuse to reproduce terrain
%       tt          - axis vector of the grid (computed here)
%
%   Output
%       env.params       - the (completed) params struct
%       env.xx,yy,zz     - nPts x nPts coordinate matrices (meshgrid layout)
%
%   Requires the working directory to be the repo root (relative path to
%   dep/OpenSimplex.jar).
%
%   See also disp_env, gen_stim, disp_stim.
function env = gen_env(params)
    if ~exist('params','var'); params = []; end
    if ~isfield(params,'flat'); params.flat = 0; end

    % randomize terrain parameters unless a full params struct was supplied
    if ~isfield(params,'bumpy')
        params.room = gray;
        params.bumpy = (~params.flat)*(0.4+0.3*rand);
        params.bumpyH = (~params.flat)*(0.1+0.2*rand);
        params.lims = 15;
        params.nPts = 51;
        params.simplexSeed = randi(10000);
    end

    % x/z grid; y starts flat
    params.tt = linspace(-params.lims,params.lims,params.nPts);
    [xx,zz] = meshgrid(params.tt,params.tt);
    yy = zeros(size(xx));
    % displace y with simplex noise (scaled by frequency and amplitude)
    if params.bumpy > 0
        javaaddpath('dep/OpenSimplex.jar')
        o = OpenSimplex.OpenSimplexNoise(params.simplexSeed);
        for ii=1:size(xx,1)
            for jj=1:size(xx,1)
                yy(ii,jj) = o.eval(xx(ii,jj)*params.bumpy,zz(ii,jj)*params.bumpy)*params.bumpyH;
            end
        end
    end
    
    env.params = params;
    env.xx = xx;
    env.yy = yy;
    env.zz = zz;
    
    % hf = figure('color',[0.5 0.5 0.5],'pos',[200 200 800 800]); % ,'Visible',false);
    % disp_env(gca,env);
    % screen2png('export/tempImg.png')
    % env.img = imread('export/tempImg.png');
    % close(hf);
end