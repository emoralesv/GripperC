# CharacterizationGUI

**CharacterizationGUI** is a MATLAB App Designer project for real-time colored-marker detection and trajectory plotting at up to 60 fps.

## Features
- Select and configure any webcam
- Detect colored markers in live video frames
- Record marker positions over time (stored in `timetable` objects)
- Visualize 2D trajectories in a built-in UIAxes
- Save non-empty marker datasets to timestamped `.mat` files

## Requirements
- MATLAB R2022a or later (with Image Processing Toolbox)
- App Designer (built into MATLAB)
- A supported webcam

## Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/CharacterizationGUI.git
   cd CharacterizationGUI
   ```
2. Install the MATLAB App:
   - In MATLAB **Home** tab, click **Add-Ons > Install App…**, then select `characterizationGUI.mlappinstall`.
   - Or run:
     ```matlab
     matlab.addons.install('characterizationGUI.mlappinstall');
     ```
3. (Optional) Open the project file:
   ```matlab
   open('characterizationGUI.prj');
   ```
4. Ensure the `models/` folder contains your `.mat` detection models.
5. Launch the app:
   - In MATLAB **APPS** tab, click **CharacterizationGUI** icon.
   - Or run:
     ```matlab
     CharacterizationGUI;
     ```

## Usage
1. Upon launch, the app lists available webcams and populates resolution and model menus.
2. Set **Color Spinners** to define how many markers per color to track.
3. Click **Start** to begin acquisition:
   - Button toggles to **Stop**.
   - Live video feed displays detected markers.
   - Trajectories update at ~60 fps in the UIAxes.
4. Click **Stop** to end acquisition:
   - Marker data is saved to `Markers_YYYYMMDD_HHMMSS.mat` in the working directory.

## Repository Structure
```
CharacterizationGUI/
├─ helpers/
│   ├─ acquisition.m
│   ├─ marker.m
│   └─ markersInterface.m
├─ models/               # Pre-trained marker detection models (.mat)
│   ├─ nano_480.mat
│   ├─ small_600.mat
│   └─ ...
├─ Characterization GUI App/
│   ├─ characterizationGUI.mlapp
│   └─ characterizationGUI.mlappinstall
├─ characterizationGUI.prj
├─ .gitignore
├─ LICENSE
└─ README.md
```