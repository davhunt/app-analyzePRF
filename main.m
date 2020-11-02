function [] = main()

if ~isdeployed
	disp('loading paths for IUHPC')
	addpath(genpath('/N/u/brlife/git/jsonlab'))
	addpath(genpath('/N/u/brlife/git/mrTools'))
	addpath(genpath('/N/u/brlife/git/NIfTI'))
	addpath(genpath('utilities'))
end

% load my own config.json
config = loadjson('config.json');
if isfield(config,'mask')
  mask = config.mask;
else
  mask = fullfile(pwd,'mask.nii.gz');
end

seedmodes = []; % deal with PRF seedmodes
if config.wantquick
  seedmodes = [-2];
else
  if config.seedmode0
    seedmodes = [seedmodes 0];
  end
  if config.seedmode1
    seedmodes = [seedmodes 1];
  end
  if config.seedmode2
    seedmodes = [seedmodes 2];
  end
end
if isempty(seedmodes)
  disp('No seeds specified, using [0 1 2] seedmode')
end

% compute pRF
getPRF(config.fmri, config.stim, mask, seedmodes, config.TR, config.pxtodeg, config.gsr);

end
