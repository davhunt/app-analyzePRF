[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.177-blue.svg)](https://doi.org/10.25663/brainlife.app.177)

# app-analyzePRF documentation

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Estimates voxel-wise population receptive fields (polar angle, eccentricity, size, R2) from retinotopy fMRI and its stimulus with Kendrick Kay's analyzePRF toolbox.**

Fits the analyzePRF compressive spatial summation model to each voxel of the fMRI time series given the stimulus aperture. Voxels are restricted to the provided mask or, if none, to the FreeSurfer cortical ribbon in the selected lobes (occipital by default). fMRI can optionally be slice-time and motion corrected and globally regressed. Designed for HCP 7T retinotopy data; the stimulus must match the fMRI timing.

| | |
|---|---|
| 📥 **Inputs** | `neuro/func/task` · `neuro/stimulus` · `neuro/freesurfer` · `neuro/mask` (optional) |
| 📤 **Outputs** | `neuro/prf` |
| 🐳 **Container** | `brainlife/freesurfer:6.0.0` |
| ⚙️ **Resources** | 12 CPUs · 120 GB memory · 96 h walltime |
| 🔑 **Requires** | `FREESURFER_LICENSE` |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.177](https://doi.org/10.25663/brainlife.app.177) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `fmri` | `neuro/func/task` | yes | Retinotopy task fMRI time series (bold). |
| `stim` | `neuro/stimulus` | yes | Stimulus aperture as a pixelsX x pixelsY x time NIfTI with values in [0,1]. Must match the temporal dimension (TR) of the fMRI. |
| `freesurfer` | `neuro/freesurfer` | yes | Used to generate .vtk surfaces |
| `mask` | `neuro/mask` | no | Optional mask in fMRI space restricting the voxels analysed (for example V1). |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `prf` | `neuro/prf` | pRF maps (polar angle, eccentricity, receptive field size, R2, exponent, gain, mean volume) as NIfTI, plus surface VTKs. |

<details>
<summary><b>⚙️ Parameters</b> (12)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `frontal` | boolean | `false` | Include frontal cortex in analysis |
| `parietal` | boolean | `false` | Include parietal cortex in analysis |
| `temporal` | boolean | `false` | Include temporal cortex in analysis |
| `occipital` | boolean | `true` | Include occipital cortex in analysis |
| `preprocess` | boolean | `true` | Perform slice-timing and head motion correction on fMRI if not already preprocessed |
| `TR` | number |  | Repetition time of fMRI (read from the nii header if unspecified) |
| `pxtodeg` | number | `0.08` | Conversion factor from pixels to degrees subtended for visual stimulus (16 deg / 200 px for HCP data) |
| `gsr` | enum | `none` | Specifies whether global signal regression (GSR) on input fMRI should be done, conversion to % change from baseline Options: `none`, `pvn`, `gms`. |
| `wantquick` | boolean | `false` | Use seedmode -2 and perform very quick PRF analysis % - When <seedmode> is -2, optimization is not performed and instead the best seed based on the super-grid is returned as the final estimate. |
| `seedmode0` | boolean | `true` | seedmode 0: % - The first seed is a generic large pRF that is centered with respect to the stimulus, has a pRF size equal to 1/4th of the stimulus extent (thus, +/- 2 pRF sizes matches the stimulus extent), and has an exponent of 0.5. |
| `seedmode1` | boolean | `true` | seedmode 1: % - The second seed is a generic small pRF that is just like the first seed except has a pRF size that is 10 times smaller. |
| `seedmode2` | boolean | `true` | seedmode 2: % - The third seed is a "supergrid" seed that is identified by performing a quick grid search prior to optimization (similar in spirit to methods described in Dumoulin and Wandell, 2008). In this procedure, a list of potential seeds is constructed by % exploring a range of eccentricities, angles, and exponents. For each potential % seed, the model prediction is computed, and the seed that produces the closest % match to the data is identified. |

</details>

📚 **References used by this App:**
- Kay KN, Winawer J, Mezer A, Wandell BA. Compressive spatial summation in human visual cortex. J Neurophysiol 110(2):481-494 (2013). [doi:10.1152/jn.00105.2013](https://doi.org/10.1152/jn.00105.2013)
- Zhou J, Benson NC, Kay KN, Winawer J. Compressive temporal summation in human visual cortex. J Neurosci 38(3):691-709 (2018). [doi:10.1523/JNEUROSCI.1724-17.2017](https://doi.org/10.1523/JNEUROSCI.1724-17.2017)
- Benson NC, et al. The Human Connectome Project 7 Tesla retinotopy dataset: Description and population receptive field analysis. J Vis 18(13):23 (2018).

<!-- brainlife-app:end -->

This app takes the time-series fMRI data of an individual subject performing a retinotopy task (bold.nii.gz), and derives voxel-wise pRF (population receptive field) measurements from their visual response to a stimulus (stim.nii.gz) using the [analyzePRF toolbox](https://github.com/kendrickkay/analyzePRF). In this model a static, compressive nonlinearity is applied to the modeled BOLD response before PRFs are fit, in line with findings that spatial summation in human visual cortex is compressive.

Visually responsive voxels (or grayordinates) are analyzed and properties of each grayordinate is extracted from the fMRI data.  PRF measurements include the grayordinate's r^2 (variance explained), receptive field polar angle (in deg), eccentricity (in deg), and size (std of the Gaussian in deg), as well as the (typically compressive) exponent of the Gaussian used to model the receptive field's visual response contrast, the gain describing the pRF model, and the mean signal intensity.

[![pRF parameters](https://raw.githubusercontent.com/davhunt/pictures/master/Screenshot%20from%202019-04-17%2014-41-11.png)

A mask (mask.nii.gz) in the same dimensions as the fMRI bold image can be passed in (V1, for example) to specify which voxels to analyze. Otherwise the cortical ribbon between white and pial surfaces from the Freesurfer, in the lobes specified (default: occipital) will be used by default.

The stimulus stim.nii.gz must match the temporal dimension (TR) of the fMRI, and consists of a pixelsX x pixelsY x time-points NIfTI image with range [0,1] expressing the contrast of the stimulus image at each pixel over time.

The fMRI data can optionally be preprocessed with slice-timing correction and head motion correction.

Global signal regression of FMRI supported, converting signal to % change from baseline, either computing baseline for each voxel seperately (per-voxel normalization, 'pvn') or computing a global baseline (grand-mean scaling, 'gms').

### Authors
- Kendrick Kay (kendrick@post.harvard.edu)
- David Hunt (davhunt@indiana.edu)

### Project director
- Franco Pestilli (franpest@indiana.edu)

### Funding Acknowledgement
brainlife.io is publicly funded and for the sustainability of the project it is helpful to Acknowledge the use of the platform. We kindly ask that you acknowledge the funding below in your publications and code reusing this code.

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations
We kindly ask that you cite the following articles when publishing papers and code using this code. 

1. Kay, K. N., Winawer, J., Mezer, A., & Wandell, B. A. (2013). Compressive spatial summation in human visual cortex. Journal of neurophysiology, 110(2), 481-494. [https://doi.org/10.1152/jn.00105.2013](https://doi.org/10.1152/jn.00105.2013)

2. Zhou, J., Benson, N. C., Kay, K. N., & Winawer, J. (2018). Compressive temporal summation in human visual cortex. Journal of Neuroscience, 38(3), 691-709. [https://doi.org/10.1523/JNEUROSCI.1724-17.2017](https://doi.org/10.1523/JNEUROSCI.1724-17.2017)

3. Benson, N. C., Jamison, K. W., Arcaro, M. J., Vu, A. T., Glasser, M. F., Coalson, T. S., ... & Kay, K. (2018). The Human Connectome Project 7 Tesla retinotopy dataset: Description and population receptive field analysis. Journal of vision, 18(13), 23-23. [https://doi.org/10.1167/18.13.23](https://doi.org/10.1167/18.13.23)

4. Avesani, P., McPherson, B., Hayashi, S. et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). [https://doi.org/10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University


## Running the App 

analyzePRF is a MATLAB toolbox for fitting population receptive field (pRF) models
to fMRI data.  It is developed by Kendrick Kay (kendrick@post.harvard.edu).

### For HCP subjects

HCP subject voxel-wise fMRI data can be downloaded from db.humanconnectome.org.

In a 7T subject's "7T_RET_fixextended" folder, preprocessed retinotopy BOLD data can be found at: MNINonLinear/Results/tfMRI_7T_RETCCW_AP_RETCW_PA_RETEXP_AP_RETCON_PA_RETBAR1_AP_RETBAR2_PA/tfMRI_7T_RETCCW_AP_RETCW_PA_RETEXP_AP_RETCON_PA_RETBAR1_AP_RETBAR2_PA_hp2000_clean.nii.gz

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/brainlife.app.177](https://doi.org/10.25663/brainlife.app.177) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
    "frontal": false,
    "temporal": false,
    "parietal": false,
    "occipital": true,
    "preprocess": false,
    "TR": "",
    "pxtodeg": 0.08,
    "gsr": "pvn",
    "wantquick": false,
    "seedmode0": true,
    "seedmode1": true,
    "seedmode2": true,
    "fmri": [
      "testdata/run1/fmri/bold.nii.gz",
      "testdata/run2/fmri/bold.nii.gz",
      "testdata/run3/fmri/bold.nii.gz",
      "testdata/run4/fmri/bold.nii.gz"
    ],
    "events": [
      "testdata/run1/fmri/events.tsv",
      "testdata/run2/fmri/events.tsv",
      "testdata/run3/fmri/events.tsv",
      "testdata/run4/fmri/events.tsv"
    ],
    "stim": [
      "testdata/run1/stim/stim.nii.gz",
      "testdata/run2/stim/stim.nii.gz",
      "testdata/run3/stim/stim.nii.gz",
      "testdata/run4/stim/stim.nii.gz"
    ],
    "output": "/testdata/output"
}
```

3. Launch the App by executing `main`

```bash
./main
```

## Output

All output files will be generated under the current working directory (pwd). The main output of this App is the "prf" directory which contains NIFTI files polarAngle, eccentricity, receptive field size (rfWidth), R2, exponent, gain, and mean volume of each voxel.

### Dependencies

This App only requires [singularity](https://www.sylabs.io/singularity/) to run.


### License

Terms of use: This content is licensed under a Creative Commons Attribution 3.0 
Unported License (http://creativecommons.org/licenses/by/3.0/us/). You are free 
to share and adapt the content as you please, under the condition that you cite 
the appropriate manuscript (see below).

If you use analyzePRF in your research, please cite the following paper:
  Kay KN, Winawer J, Mezer A and Wandell BA (2013) 
    Compressive spatial summation in human visual cortex.
    J. Neurophys. doi: 10.1152/jn.00105.2013

History of major code changes:
- 2014/06/17 - Version 1.1.

## CONTENTS

Contents:
- analyzeHCP.m - Matlab script calling analyzePRF.m for HCP data
- analyzePRF.m - Top-level function that you want to call
- analyzePRFcomputeGLMdenoiseregressors.m - Helper function
- analyzePRFcomputesupergridseeds.m - Helper function
- example*.m - Example scripts
- exampledataset.mat - Example dataset
- README - The file you are reading
- setup.m - A simple script that downloads the example dataset
            and adds analyzePRF to the MATLAB path
- utilities - A directory containing various utility functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Copyright (c) 2014, Kendrick Kay
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

The names of its contributors may not be used to endorse or promote products 
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
