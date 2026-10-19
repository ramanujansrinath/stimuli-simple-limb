% GEN_STIM  Generate a complete stimulus: a 3D shape plus optional context cues.
%
%   stim = gen_stim(doEnv, doSnow, <gen_shape name/value options>)
%
%   Top-level entry point for stimulus generation. Bundles three components
%   into one struct so they can be saved, reloaded and rendered together
%   with disp_stim:
%       stim.shape - mesh + parameters of the limb shape   (see gen_shape)
%       stim.env   - ground-plane height map, or [] if off (see gen_env)
%       stim.snow  - cloud of floating points, or [] if off (see gen_snow)
%
%   Inputs
%       doEnv   - (logical, default false) generate a bumpy ground plane
%       doSnow  - (logical, default false) generate floating snow particles
%       varargin - any optional arguments accepted by gen_shape (e.g.
%                  'maCurv',0.5 or 'surfComp',0.2); anything not given is
%                  randomized.
%
%   Example
%       stim = gen_stim(1,1,'maCurv',0.8);
%
%   See also gen_shape, gen_env, gen_snow, disp_stim.
function stim = gen_stim(doEnv,doSnow,varargin)
    % the shape is always generated; params is passed as [] so that gen_shape
    % draws a fresh random parameter set (overridden by varargin)
    stim.shape = gen_shape([],varargin{:});

    if ~exist('doEnv','var'); doEnv = false; end
    if ~exist('doSnow','var'); doSnow = false; end

    % optional context cues; left empty so disp_stim can skip them
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

