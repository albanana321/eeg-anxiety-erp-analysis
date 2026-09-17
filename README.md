# EEG Go/NoGo ERP Study: Trait Anxiety and Response Inhibition

An electroencephalography (EEG) study investigating the relationship between **trait anxiety** and **cognitive inhibition** using the Go/NoGo paradigm with event-related potential (ERP) analysis.

*Developed as part of a Teaching Assistant position at King's College London, where I led practical sessions teaching second-year Neuroscience and Psychology students EEG data collection and analysis techniques.*

---

## Overview

Response inhibition, the ability to suppress inappropriate or unwanted actions, is a core executive function that has been linked to anxiety disorders. This study examined whether individuals with high trait anxiety (HTA) show impaired inhibitory control compared to those with low trait anxiety (LTA), using both behavioural measures and neural correlates.

The Go/NoGo task requires participants to respond to frequent "Go" stimuli while withholding responses to rare "NoGo" stimuli. This paradigm reliably elicits two key ERP components:
- **N2** (200–400 ms): Associated with conflict monitoring and early inhibitory processes
- **P3** (450–600 ms): Reflects later cognitive evaluation and response inhibition

By comparing these neural signatures between anxiety groups, we can identify the specific stage at which inhibitory control may be compromised in anxious individuals.

---

## Study Design

### Participants
- **Cohort:** 64 second-year undergraduates; 30 were assigned to the Go/NoGo experiment
- **Retained:** 20 after 9 exclusions for incomplete STAI-T questionnaires
- **Entering the group comparison:** ~10, since LTA/HTA are the lower and upper
  quartiles of the retained sample. All reported ANOVAs are therefore F(1,8).
- **Demographics:** 64% female, ages 19–25, diverse ethnic backgrounds
- **Anxiety assessment:** State-Trait Anxiety Inventory (STAI-T)
- **Groups:** High Trait Anxiety (HTA) vs. Low Trait Anxiety (LTA) based on quartile split (lower and upper 25%) 

### Task
| Parameter | Value |
|-----------|-------|
| **Paradigm** | Go/NoGo task |
| **Go stimulus** | Number "2" (respond) |
| **NoGo stimulus** | Letter "Z" (inhibit) |
| **Trial ratio** | 85% Go / 15% NoGo |
| **Total trials** | 500 (5 blocks × 100 trials) |
| **Go trials** | 425 |
| **NoGo trials** | 75 |

### EEG Acquisition
| Parameter | Value |
|-----------|-------|
| **System** | BioSemi ActiveTwo |
| **Electrodes** | 64 channels |
| **Sampling rate** | 1000 Hz (downsampled to 256 Hz) |
| **Reference** | Average reference |
| **Software** | ActiView (recording), MATLAB (analysis) |

---

## Methods

### EEG Preprocessing Pipeline

The analysis script implements a comprehensive preprocessing workflow:

1. **Data Import**
   - Load raw BioSemi BDF files
   - Convert to EEGLAB .set format

2. **Preprocessing**
   - Downsample from 1000 Hz to 256 Hz
   - Set channel locations (10-5 system)
   - Create bipolar EOG channels (HEOG, VEOG)
   - High-pass filter at 0.1 Hz (Butterworth, 2nd order)
   - Low-pass filter at 30 Hz
   - Average re-referencing (excluding EOG)

3. **Epoching**
   - Extract epochs: −200 ms to +800 ms relative to stimulus onset
   - Baseline correction using pre-stimulus period

4. **Artefact Rejection**
   - Moving window peak-to-peak threshold: ±400 μV
   - Window size: 200 ms, step: 50 ms

5. **Independent Component Analysis (ICA)**
   - Extended Infomax ICA for artefact identification
   - ICLabel for automatic component classification
   - Removal of eye-blink components (>90% probability)

6. **ERP Extraction**
   - Average waveforms for Go and NoGo conditions
   - Difference waves (NoGo minus Go)
   - Peak amplitude and latency measurements for N2 and P3

### ERP Components of Interest

| Component | Time Window | Electrodes | Function |
|-----------|-------------|------------|----------|
| **N2** | 200–400 ms | Fz, FCz, Cz (frontocentral) | Conflict monitoring, early inhibition |
| **P3** | 450–600 ms | Pz, CPz, POz (centroparietal) | Cognitive evaluation, response inhibition |

### Statistical Analysis
- Two-way mixed ANOVAs (Group × Condition)
- Bonferroni-corrected post-hoc comparisons
- Conducted in R-Studio (v4.1)

---

## Key Findings

### Behavioural Results

| Measure | HTA Group | LTA Group | Significance |
|---------|-----------|-----------|--------------|
| **NoGo accuracy** | 70% | 88% | p < .01 |
| **Go accuracy** | 96% | 97% | n.s. |

High trait anxiety was associated with **significantly impaired response inhibition** on NoGo trials, while Go trial performance remained intact. This suggests anxiety specifically affects inhibitory control rather than general task performance.

### ERP Results

| Component | Finding |
|-----------|---------|
| **N2** | No significant differences between HTA and LTA groups |
| **P3** | Significantly **larger amplitude** in HTA vs. LTA for both Go and NoGo trials |

The enhanced P3 amplitude in anxious individuals may reflect compensatory neural effort during response inhibition, or heightened attentional allocation to task-relevant stimuli. The absence of N2 differences suggests that early conflict detection processes are intact, with anxiety affecting later cognitive evaluation stages.

---

## Skills & Tools

### Neuroimaging & Signal Processing

| Technique | Description |
|-----------|-------------|
| EEG data acquisition | 64-channel BioSemi ActiveTwo system setup and recording |
| Preprocessing pipeline | Filtering, epoching, artefact rejection, re-referencing |
| Independent Component Analysis | Blind source separation for artefact removal |
| ICLabel | Automated component classification using machine learning |
| ERP analysis | Peak detection, latency measurement, difference waves |
| Topographic mapping | Scalp voltage distribution visualisation |

### Software & Programming

| Tool | Purpose |
|------|---------|
| **MATLAB** (v9.11) | Primary analysis environment |
| **EEGLAB** (v2022.2) | EEG preprocessing and visualisation |
| **ERPLAB** | ERP-specific analysis and measurement |
| **ICLabel** | Automated ICA component classification |
| **R-Studio** (v4.1) | Statistical analysis (ANOVAs, post-hoc tests) |
| **ActiView** | BioSemi EEG recording software |

### Experimental Methods

| Skill | Application |
|-------|-------------|
| Go/NoGo paradigm design | Response inhibition assessment |
| STAI-T administration | Trait anxiety measurement |
| EEG cap setup | Electrode placement and impedance checking |
| Participant instruction | Standardised task briefing |

---

## Repository Structure

```
.
├── README.md                 # This file
├── LICENSE                   # MIT License
├── eeg_analysis_script.m     # Complete MATLAB preprocessing and analysis pipeline
└── lab_report.pdf            # Full study report with methods and results
```

---

## Usage

### Prerequisites
- MATLAB (R2021a or later recommended)
- EEGLAB toolbox (v2022.2 or later)
- ERPLAB plugin
- ICLabel plugin

### Running the Analysis

1. **Install EEGLAB and plugins:**
   ```matlab
   % Add EEGLAB to path
   addpath('/path/to/eeglab/')
   eeglab  % This will prompt to install plugins
   ```

2. **Configure data paths:**
   ```matlab
   % Edit these variables in the script
   datafolder = './data/raw/';      % Raw BDF files
   datafolder2 = './data/processed/'; % Output directory
   subject = 'S01';                   % Subject identifier
   ```

3. **Run preprocessing (Part A):**
   - Imports raw data
   - Applies filters and epoching
   - Performs artefact rejection

4. **Run ICA (Part B):**
   - Computes ICA decomposition
   - Identifies and removes artefact components

5. **Extract ERPs (Part C):**
   - Averages epochs by condition
   - Measures N2 and P3 components
   - Exports peak amplitude and latency values

---

## Teaching Context

This project was developed as part of my role as a **Teaching Assistant** for the Electrophysiology practical module at King's College London. Responsibilities included:

- Leading practical sessions with groups of second-year students
- Teaching EEG cap setup and electrode application
- Demonstrating data collection procedures with BioSemi system
- Guiding students through EEGLAB preprocessing workflows
- Explaining ERP component interpretation and analysis

The analysis pipeline presented here served as both a teaching tool and a research template for student projects.

---

## References

1. Xia, L., Mo, L., Wang, J., Zhang, W., & Zhang, D. (2020). Trait anxiety attenuates response inhibition: Evidence from an ERP study using the Go/NoGo task. *Frontiers in Behavioral Neuroscience*, 14, 28.

2. Sehlmeyer, C., Konrad, C., Zwitserlood, P., Arolt, V., Falkenstein, M., & Beste, C. (2010). ERP indices for response inhibition are related to anxiety-related personality traits. *Neuropsychologia*, 48(9), 2488–2495.

3. Delorme, A., & Makeig, S. (2004). EEGLAB: an open source toolbox for analysis of single-trial EEG dynamics including independent component analysis. *Journal of Neuroscience Methods*, 134(1), 9–21.

4. Lopez-Calderon, J., & Luck, S. J. (2014). ERPLAB: an open-source toolbox for the analysis of event-related potentials. *Frontiers in Human Neuroscience*, 8, 213.

5. Pion-Tonachini, L., Kreutz-Delgado, K., & Makeig, S. (2019). ICLabel: An automated electroencephalographic independent component classifier, dataset, and website. *NeuroImage*, 198, 181–197.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Author

**Alban Malaj**

*Teaching Assistant, Electrophysiology Practical, King's College London*
