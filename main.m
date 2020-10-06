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

% compute pRF
getPRF(config.fmri, config.stim, mask, config.TR, config.pxtodeg);

end
