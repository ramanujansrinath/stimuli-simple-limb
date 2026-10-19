function env = gen_env(params)
    if ~exist('params','var'); params = []; end
    if ~isfield(params,'flat'); params.flat = 0; end

    if ~isfield(params,'bumpy')
        params.room = gray;
        params.bumpy = (~params.flat)*(0.4+0.3*rand);
        params.bumpyH = (~params.flat)*(0.1+0.2*rand);
        params.lims = 15;
        params.nPts = 51;
        params.simplexSeed = randi(10000);
    end
    
    params.tt = linspace(-params.lims,params.lims,params.nPts);
    [xx,zz] = meshgrid(params.tt,params.tt);
    yy = zeros(size(xx));
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