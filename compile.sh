#!/bin/bash

module unload matlab && module load matlab/2017a

log=compiled/commit_ids.txt
true > $log
echo "/N/u/brlife/git/jsonlab" >> $log
(cd /N/u/brlife/git/jsonlab && git log -1) >> $log
echo "/N/u/brlife/git/mrTools" >> $log
(cd /N/u/brlife/git/mrTools && git log -1) >> $log
echo "/N/u/davhunt/Carbonate/analyzePRF/utilities" >> $log
(cd /N/u/davhunt/Carbonate/analyzePRF/utilities && git log -1) >> $log
echo "/N/u/davhunt/Carbonate/Downloads/NIfTI_matlab_tools" >> $log
(cd /N/u/davhunt/Carbonate/NIfTI_cifti_matlab_tools && git log -1) >> $log

mkdir -p compiled

cat > build.m <<END
addpath(genpath('/N/u/brlife/git/jsonlab'))
addpath(genpath('/N/soft/mason/SPM/spm8'))
addpath(genpath('/N/u/davhunt/Carbonate/analyzePRF/utilities'))
addpath(genpath('/N/u/davhunt/Carbonate/Downloads/NIfTI_matlab_tools'))
mcc -m -R -nodisplay -a /N/u/brlife/git/vistasoft/mrDiffusion/templates -d compiled main
exit
END
matlab -nodisplay -nosplash -r build
