function getPRF(fmri, stim, mask, seedmodes, TR, pxtodeg, gsr)

if length(fmri) ~= length(stim)
  error('must input one stimulus for each fmri run')
end

if ~isempty(TR) tr = TR;  % temporal sampling rate in seconds 
else
  disp('No repetition time (TR) specified for inputted fMRI, using TR from nifti header');
  tr = load_untouch_nii(char(fmri{1}).hdr.dime.pixdim(5));
end

if isempty(pxtodeg) error('conversion factor from pixels (of visual stimulus) to degrees not specified'); end    % conversion from pixels to degrees

data = {};
stimulus = {};

for p=1:length(fmri)
  a1 = load_untouch_nii(char(fmri{p}));
  data{p} = a1.img;
  a1 = load_untouch_nii(char(stim{p}));
  stimulus{p} = a1.img;
end

a1 = load_untouch_nii(mask);
maskBool = a1.img;
maskBool(maskBool >= 1) = 1.0;	% create binary mask
maskBool = logical(maskBool);

[r,c,v] = ind2sub(size(maskBool),find(maskBool));

maskedData = {};

for p = 1:length(data)
  maskedData{p} = zeros(size(r,1),size(data{p},4));
  for i = 1:size(r,1)
    maskedData{p}(i,:) = data{p}(r(i),c(i),v(i),:);
  end
  maskedData{p} = squeeze(maskedData{p});
end

maskedData = globalRegress(maskedData, gsr); % do global signal regression

results = analyzePRF(stimulus,maskedData,tr,struct('seedmode',seedmodes,'display','off'));

% one final modification to the outputs:
% whenever eccentricity is exactly 0, we set polar angle to NaN since it is ill-defined.
% remove eccentricity and rfsizes > 90 degrees since they don't make sense
results.ang(results.ecc(:)==0) = NaN;
results.ecc(results.ecc(:)>90) = NaN;
results.rfsize(results.rfsize(:)>90) = NaN;

[polarAngle, eccentricity, expt, rfWidth, r2, gain, meanvol] = deal(zeros(size(data,1), size(data,2), size(data,3)));

m = 1;
for k = 1:size(maskBool,3)
  for j = 1:size(maskBool,2)
    for i = 1:size(maskBool,1)
      if maskBool(i,j,k) >= 1.0
        polarAngle(i,j,k) = results.ang(m);
        eccentricity(i,j,k) = results.ecc(m)*pxtodeg;
        expt(i,j,k) = results.expt(m);
        rfWidth(i,j,k) = results.rfsize(m)*pxtodeg;
        r2(i,j,k) = results.R2(m)/100.0;
        gain(i,j,k) = results.gain(m);
        meanvol(i,j,k) = results.meanvol(m);
        m = m+1; % increment to total voxels in mask
      else
        [polarAngle(i,j,k), eccentricity(i,j,k), expt(i,j,k), rfWidth(i,j,k), r2(i,j,k), gain(i,j,k), meanvol(i,j,k)] = deal(NaN);
      end
    end
  end
end

nii = load_untouch_nii(char(fmri{1}));
%voxRes = a1.hdr.dime.pixdim(2:4) % voxel resolution of original fMRI
datatype = 64; % float64
origin = [0 0 0]; % voxels start at 0 0 0
%nii = make_nii(r2,voxRes,origin,datatype);

nii.hdr.dime.datatype = 64; nii.hdr.dime.bitpix = 64; % float64
nii.hdr.dime.dim(1) = 3; nii.hdr.dime.dim(5) = 1;
nii.hdr.dime.scl_slope = 0; nii.hdr.dime.scl_inter = 0;
nii.hdr.dime.glmax = 0; nii.hdr.dime.glmin = 0; % just set to 0


%nii.hdr.dime.pixdim(1) = a1.hdr.dime.pixdim(1); % should be 1 or -1?
%nii.hdr.dime.xyzt_units = a1.hdr.dime.xyzt_units; % millimeters x seconds

nii.img = polarAngle;
save_untouch_nii(nii,['prf/polarAngle.nii.gz']);

nii.img = eccentricity;
save_untouch_nii(nii,['prf/eccentricity.nii.gz']);

nii.img = expt;
save_untouch_nii(nii,['prf/exponent.nii.gz']);

nii.img = rfWidth;
save_untouch_nii(nii,['prf/rfWidth.nii.gz']);

nii.img = r2;
save_untouch_nii(nii,['prf/r2.nii.gz']);

nii.img = gain;
save_untouch_nii(nii,['prf/gain.nii.gz']);

nii.img = meanvol;
save_untouch_nii(nii,['prf/meanvol.nii.gz']);

end
