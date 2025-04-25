## Analyzing Gut Motility: A Step-by-Step Guide

### 1. Image Acquisition and Preprocessing
* Acquire high-resolution time-lapse images of the hindgut.
* Crop raw time-lapses to zoom in on the hindgut region (using ImageJ).
* Remove transition frames (e.g., due to denervation or drug application).
* Downsample from 30 to 3 fps to match the long timescales of gut movement.
* Temporally smooth movies using Simoncelli filter (5-point weights).
* Avoid spatial smoothing to retain features critical for flow analysis.

### 2. Flow Field Computation
* **Hindgut Segmentation:** Use MATLAB's `strel` and `imerode` to segment gut outlines frame-by-frame.
* **Optical Flow Analysis:** Apply the Lucas-Kanade method using a Gaussian-weighted neighborhood (σ = 2 px).
  * Impose a reliability threshold (0.01) to remove unreliable vectors.
  * Set flow vectors below the threshold to zero.
* **Dorsal-Ventral Motility Map:** Average lateral flow components across the dorsal-ventral axis to generate motility maps.
* **Flow Smoothing for Visualization:** Apply Gaussian smoothing to visualize motion direction and reduce localized noise.

### 3. Frequency-Domain Analysis
* Apply FFT along the time axis to compute 2D power spectral density (PSD).
  * Extract dominant motion frequencies and harmonics.
  * Nyquist frequency is 1.5 Hz (sampling at 3 Hz).
* Calculate power as the sum of squared FFT amplitudes normalized by signal length.
* Also compute instantaneous power using FFT along the spatial axis.

### 4. Rhythmic Power Quantification
* Define **Relative Rhythmic Power** as the power in the peak frequency band (±0.04 Hz) divided by total power.
* Used to quantify signal coordination:
  * White noise → flat PSD → low rhythmic power.
  * Single-frequency signal → narrow PSD peak → high rhythmic power (~1).
* Metric is robust to small changes in frequency window width.

### 5. Lateral Wave Detection
* Apply speed threshold (top 30% globally) to highlight wave regions.
* Use MATLAB's `bwareaopen` and `bwlabeln` to find connected wave regions (area > 100 px).
* Extract waves that span >1/5 of gut length.
* Use `bwskel` to trace wave skeletons and compute speed via slope.
* Label wave direction:
  * AP (anterior → posterior): positive speed
  * PA (posterior → anterior): negative speed
  * Mixed: zero speed

### 6. Statistical Time-Window Selection
* For each phase:
  * Use last 15 minutes of Phases 1 & 2
  * Use first 15 minutes of Phase 3
* Rationale:
  * Capture short-term changes following 5-HT application.
  * Supported by statistical testing between 15-min windows (see Supplementary Fig. 1).

### 7. Data Analysis and Visualization
* **Statistical Analysis:**
  * Compare motility features across conditions (e.g., saline vs. N7 cut vs. serotonin).
  * Use non-parametric tests (e.g., Wilcoxon signed-rank).
* **Visualization:**
  * Motility kymographs, PSD plots, and boxplots.
  * Color-coded vector fields for flow direction and magnitude.

### Key Tools and Techniques
* **Image Processing:** Cropping, thresholding, morphological operations.
* **Flow Estimation:** Lucas-Kanade method with Gaussian weighting.
* **Signal Processing:** FFT-based PSD, rhythmic power analysis.
* **Wave Extraction:** Connected component analysis and wave skeleton tracing.
* **Statistical Analysis:** MATLAB functions (`signrank`, `boxplot`) for paired comparison.
* **Software:** MATLAB, ImageJ.
