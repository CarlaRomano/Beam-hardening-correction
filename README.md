# Beam hardening correction
Automated high accuracy, rapid beam hardening correction in X-Ray Computed Tomography of multi-mineral, heterogeneous core samples.
Authors: Carla Romano, James M. Minto, Zoe K. Shipton, Rebecca J. Lunn.

This dataset contains beam hardening correction macros, running on ImageJ software.
Requirements: 
- ImageJ/FIJI. Download available at https://imagej.net/Fiji/Downloads
- Radial Profile Extended plug-in (Carl P., 2006). Download available at https://imagej.nih.gov/ij/plugins/radial-profile-ext.html

For running the code 
- Launch Fiji and load the image stack (File-Import-Image sequence)
- Load the code in the software (Plugin-Macro-Edit) and click Run.
- A dialogue box is shown as soon the code is running, requesting:
    - Top and bottom number slices on which the correction should be applied.
    - Width of outer ring (pixel). This is to crop out any material outside the sample, such as container or other external layers. If no       outer ring is present put 0 as value. If the image is in a specific unit and not in pixel, please remove the scale(Analyze-Set             scale- Click to Remove Scale) before running the code.
    - Tick the box if it's an internal or zoomed in scan.
    - Press ok.
    
All the following steps in the correction are completely automatic.


    
