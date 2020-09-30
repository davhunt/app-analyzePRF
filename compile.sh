#!/bin/bash

module unload matlab && module load matlab/2017a

log=compiled/commit_ids.txt
true > $log
echo "/N/u/brlife/git/jsonlab" >> $log
(cd /N/u/brlife/git/jsonlab && git log -1) >> $log
echo "/N/u/brlife/git/mrTools" >> $log
(cd /N/u/brlife/git/mrTools && git log -1) >> $log
echo "/N/u/brlife/git/NIfTI" >> $log
(cd /N/u/brlife/git/NIfTI && git log -1) >> $log
echo "utilities" >> $log
(cd utilities && git log -1) >> $log

mkdir -p compiled

cat > build.m <<END
addpath(genpath('/N/u/brlife/git/jsonlab'))
addpath(genpath('/N/u/brlife/git/mrTools'))
addpath(genpath('/N/u/brlife/git/NIfTI'))
addpath(genpath('utilities'))
mcc -m -R -nodisplay -a /N/u/brlife/git/vistasoft/mrDiffusion/templates -d compiled main
exit
END
matlab -nodisplay -nosplash -r build
