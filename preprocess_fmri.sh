#!/bin/bash

fmri=${1}
ES=${2}
do_stc=${3}
fmri_base=$(basename $fmri)

if ${do_stc}; then
  echo "Doing slice timing correction"
  TR=$(fslval ${fmri} pixdim4)
  slicetimer -i ${fmri} -o slicetime_corrected_${fmri_base} --tcustom=slicetiming.txt --repeat=$TR --verbose
  fmri=slicetime_corrected_${fmri_base}
fi

echo "Doing head motion correction"
mcflirt -in ${fmri} -meanvol -mats -plots -o preprocessed_${fmri_base} >> preprocessed_${fmri_base}.ecclog

#epi_reg --epi=mcflirt/not_slicetimer_mcflirt_output --t1=T1.nii.gz --t1brain=brain.nii.gz --out=mcflirt/not_epi_reg_post --echospacing=$ES
