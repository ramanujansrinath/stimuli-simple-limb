function stim = gen_stim(doEnv,doSnow,varargin)
    stim.shape = gen_shape([],varargin{:});
    
    if ~exist('doEnv','var'); doEnv = false; end
    if ~exist('doSnow','var'); doSnow = false; end
    
    if doEnv
        stim.env = gen_env;
    else
        stim.env = [];
    end
    
    if doSnow
        stim.snow = gen_snow;
    else
        stim.snow = [];
    end
end

