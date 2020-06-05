#!/bin/bash

fslroi ${1} fMRI_slice.nii.gz 0 1 # extract first (t=0) volume from fMRI

flirt -in T1.nii.gz -ref fMRI_slice.nii.gz -out fs2func.nii.gz -omat fs2func.mat # register T1 to fMRI

fslmaths rh.ribbon.nii.gz -add lh.ribbon.nii.gz rh+lh.ribbon.nii.gz # combine rh+lh ribbons

flirt -in rh+lh.ribbon.nii.gz -ref fs2func.nii.gz -out prob_mask.nii.gz -init fs2func.mat #-applyxfm # create probabilistic mask

fslmaths prob_mask.nii.gz -thr 0.3 -bin mask.nii.gz # threshold to create mask
