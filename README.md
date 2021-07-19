# Beam hardening correction
Automated high accuracy, rapid beam hardening correction in X-Ray Computed Tomography of multi-mineral, heterogeneous core samples.
Authors: Carla Romano, James M. Minto, Zoe K. Shipton, Rebecca J. Lunn. For info please email cromano3@wisc.edu

If you intend to use this work and distribute derivate works please cite:
Romano, C., Minto, J. M., Shipton, Z. K., & Lunn, R. J. (2019). Automated high accuracy, rapid beam hardening correction in X-Ray Computed Tomography of multi-mineral, heterogeneous core samples. Computers & Geosciences, 131, 144-157. https://doi.org/10.1016/j.cageo.2019.06.009


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

# UPDATE March 2020
A new faster version of the code has been released. Please download "BeamHardening_Correction_plugin_CLIJ.ijm" file.
GPU-accelerated by Robert Haase. In order to run the adapted version, activate the CLIJ and CLIJ2 update sites in your Fiji (check here how to https://clij.github.io/).
Please cite also: Haase, R., Royer, L.A., Steinbach, P. et al. CLIJ: GPU-accelerated image processing for everyone. Nat Methods 17, 5–6 (2020). https://doi.org/10.1038/s41592-019-0650-1"
For running properly the code please update to the latest version of Clij and Clij2 and update Fiji ImageJ to the latest version as well (1.53k on 19/7/2021)


    
