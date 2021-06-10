# ImageAnalysis
This script is meant to be used as a template to perform batch analysis using thresholding methods on a selected folder of 8bit Tiff images. 

# How to use:

First, manually go through some representative images so that you can understand what sort of parameters and protocols you wish to apply to your images
in order to threshold them and correctly identify postive staining from negative.
***************
Next, review the script to see if any preprocessing parameters you desire to run are already included in the code or if they need to be added.
If more need to be added or some need to be commented out, simply add or comment out the appropriate line in the "function preThresholdingProcessing" function
```bash
/*
 * Prethreshold image processing for images should be done here
 */	
function preThresholdingProcessing(){
...
}
```
To comment out a piece of code, add "//" to the beginning of the line.
If you need to add a command to the image preprossessing pipeline, use the recorder macro to figure out the specifics of the command you wish to add.
***************
Next review the constant variables, these should only be changed if you want to change the basic protocol for determining slice area.
***************
Run the script. A folder selection window will pop up and this will be where you choose the folder that contains your 8bit tiff images. There should not be any subfolders within this folder.
***************
Run through the prompts. Note: when typing in algorithms, they must be written exactly as the name is. If there is a capital letter in the middle, then it must be
written as such.
***************
Once all the parameters are set, the images will begin being thresholded and analyzed. There will be two output windows, 1 will be of the particle analysis summary and the other will be of the slice area. 
At the end, a summary of protocols and parameters used will be printed. 
