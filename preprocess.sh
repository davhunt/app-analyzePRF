#!/bin/bash

# check for "preprocessed" tag on input, otherwise preprocess if requested
inputs=$(jq -r ._inputs[].id config.json)
i=0
for input in ${inputs}; do
  if [ $input = "fmri" ]; then
    idx=${i}
  fi
  i=$(( $i + 1 ))
done
if [ ! -z $idx ] && [[ $(jq -r ._inputs[$idx].datatype_tags config.json) == *"preprocessed"* ]]; then
  :
elif $preprocess; then
  fmri=$(jq -r '.fmri[]' config.json)
  time singularity exec -e docker://brainlife/dipy:1.1.1 python3 combine_fmri.py ${fmri}

  if [ ! -z $(jq -r ._inputs[$idx].meta.EffectiveEchoSpacing config.json) ]; then
    ES=$(jq -r ._inputs[$idx].meta.EffectiveEchoSpacing config.json)
  else
    ES=0.0005
  fi
  if [ ! -z $idx ] && $(jq '._inputs['$idx'].meta | .SliceTiming != null' config.json); then
    ST=$(jq ._inputs[$idx].meta.SliceTiming[] config.json)
    for t in ${ST}; do echo $t >> slicetiming.txt; done
    do_stc=true
  else
    do_stc=false
  fi
  if [[ $TR == "" ]]; then TR=null; fi

  time singularity exec -e docker://brainlife/fsl:6.0.1 ./preprocess_fmri.sh bold_cat.nii.gz $ES $TR $do_stc

  time singularity exec -e docker://brainlife/dipy:1.1.1 python3 split_fmri.py preprocessed_bold_cat.nii.gz ${fmri}

  # now replace with preprocessed runs in config.json

  num_runs=$(jq -r '.fmri | length' config.json)

  for i in $(seq 1 $num_runs); do
    #new_fmri="${new_fmri}, \"$(jq -r ".fmri[$i]" config.json)\""; done
    new_fmri="${new_fmri}, \"preproc_bold_${i}.nii.gz\""; done
  jq ".fmri = [ ${new_fmri:2} ]" config.json > temp.json && mv temp.json config.json
fi
