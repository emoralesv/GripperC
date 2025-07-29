# GripperC

*Gripper Characterizer for Robotic Compliant Systems*

## Overview

GripperC is a MATLAB App Designer application designed to characterize and analyze compliant robotic grippers. It captures real‑time video from a webcam, detects and tracks colored markers affixed to the gripper, and generates trajectory curves to evaluate its dynamic behavior.

## Key Features

- **Real‑time Capture & Preprocessing**
  - Select camera and resolution.
  - Optional contrast enhancement to improve marker visibility.
- **Deep Learning–Based Detection**
  - Load any `.mat` detector model (e.g. YOLO).
  - Set confidence threshold to filter weak detections.
- **Multi‑Marker Tracking**
  - Support for multiple colored markers (red, green, blue, cyan, magenta, yellow, black).
  - Smooth position estimates via moving‑average buffers.
  - Robust assignment of detections to tracks using `assignDetectionsToTracks`.
- **Interactive Visualization**
  - Overlay filled circles on each detected marker’s mean position.
  - Plot X and Y coordinates vs. time in real‑time.
- **Configurable Parameters**
  - Choose how many markers of each color to follow.
  - Adjust detection confidence on the fly.
- **Data Export**
  - Trajectories resampled to 30 Hz and saved as `.mat` (`Markers_YYYYMMDD_HHMMSS.mat`).
  - Output includes MATLAB timetables ready for further analysis.

## Requirements

- MATLAB R2021a or later.
- Image Processing Toolbox.
- Computer Vision Toolbox.
- (Optional) GPU support for deep learning inference.

## Installation
1. Clone or download this repository into your MATLAB project folder.
2. Ensure the `models/` folder contains your `.mat` detector files (variable name: `detector`).
3. Open `GripperC.mlapp` in MATLAB App Designer.

## Usage

1. Run the app by clicking **Run** in App Designer or executing:
   ```matlab
   GripperC
   ```
2. In the **Options** panel:
   - Select **Camera** and **Resolution**.
   - Choose a **Model** from the dropdown.
   - Adjust **Confidence** slider.
   - Specify marker counts for each color.
3. Press **Start** to begin tracking.
4. Watch live video with marker overlays and trajectory plots.
5. Press **Stop** to end the session and save data.

## Configuration

- **models/**: Place `.mat` detector files here. Each file must contain a trained detector named `detector`.
- **Markers**: Use the spinners to set how many markers of each color you want to track.
- **Confidence**: Adjust between 0 and 1 to include/exclude weak detections.

## Data Export

- On stopping, GripperC:
  1. Filters out markers without any data.
  2. Interpolates each marker’s trajectory to a uniform 30 Hz time vector.
  3. Saves `validMarkers` and `timestamp` in `Markers_YYYYMMDD_HHMMSS.mat`.

## Project Structure

```
├── Source code/
│   ├── helpers/
│   │   ├── acquisition.m
│   │   ├── marker.m
│   │   └── markersInterface.m
│   ├── models/
│   │   ├── medium_400.mat
│   │   ├── medium_720.mat
│   │   ├── medium_600.mat
│   │   ├── nano_480.mat
│   │   ├── nano_600.mat
│   │   ├── nano_720.mat
│   │   ├── small_480.mat
│   │   ├── small_600.mat
│   │   ├── small_720.mat
│   │   ├── tiny_480.mat
│   │   ├── tiny_600.mat
│   │   └── tiny_720.mat
│   ├── characterizationGUI.mlapp    % Main App Designer file
│   └── characterizationGUI.prj      % Project file
├── LICENSE
├── README.md
└── .gitignore
```

## Class Architecture

- **acquisition**: Captures frames, applies preprocessing, runs DL detection.
- **marker**: Tracks one colored marker, maintains history buffers, builds timetable.
- **markersInterface**: Manages multiple `marker` instances, assigns detections to tracks.

## Citation

If you use GripperC in your research, please cite: (Don´t forget to update)

E. Morales‑Vargas, R.Q. Fuentes‑Aguilar, G. Hernández‑Melgarejo and Enrique Cuan‑Urquizo; "Computer Vision Approach for Performance Tracking of Robotic Compliant Systems", submitted to *Engineering Reports*.


## Contributing

Contributions, bug reports, and feature requests are welcome. Please open an issue or submit a pull request.

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.

## Notes 
To update the repository do not forget to install lfs
```
git lfs install
```
