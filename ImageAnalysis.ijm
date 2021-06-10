/*
 * made by Alan Gordillo, 2020
 * uses fiji to analyze 8bit images
 * 
 */

/*
 * Constant variables will be here, if you need to change any of the major variables, do so here and their value will be reflected throughout.
 */

 //BRIGHTFIELD slice area parameters
FINAL_ISBRIGHTFIELD_TOTALSLICEAREA_LOWERBOUND = 1;
FINAL_ISBRIGHTFIELD_TOTALSLICEAREA_UPPERBOUND = 85;

//nonbrightfield slice area parameters
FINAL_NOTBRIGHTFIELD_TOTALSLICEAREA_THRESHOLD_ALGO = "Li";


//Sets the measurements to make sure they are already there regardless of the user's initial preferences. Can be changed depending on what data you need.
run("Set Measurements...", "area min area_fraction limit display redirect=None decimal=3");

// ask user to select a folder			
dir = getDirectory("Select A folder"); 			
// get the list of files (& folders) in it			
fileList = getFileList(dir);			
			
			
			
//asking user what protocol they want to do, in this method, local is "yes" and global is "no" thus, if local, protocol = 1			
protocol = getBoolean("Are you doing local thresholding or global thresholding", "local", "global");			
protocolString = "";
			
//if protocol is true, that means user wants to do local thresholding so ask them what algorithm to use, if global is desired, then requesting the threshold value			
if(protocol){
	protocolString = "local thresholding";	
	//local threshold variables	
 	l_threshold = getString("Which local threshold parameter do you want: Bernsen, Contrast, Mean, Median, MidGrey, Niblack, Otsu, Phansalkar, Sauvola ", "default");
 	radius = getNumber("What radius would you like to use? default is 15.", 15);
}			
else {	
	protocolString = "global thresholding";			
	//global threshold variables
	autoT = getBoolean("are you doing auto threshold or single value threshold?", "auto", "single value");

	//this checks either what number value to threshold at or what algorithm to use depending on if the user wants to do autothresholding or not
	if(!autoT){
		if(isBrightField){
					upperThresh = getNumber("What is the upper bound of the threshold value", 100);	
		}
		threshold = getNumber("What threshold value to use?", 255);}
	else{
		gThreshAlgo = getString("what method? Default, Huang, Intermodes, Mean, IsoData...etc ", "Huang");		
	}
}			
			
//asking user if the images are brightfield			
isBrightField = getBoolean("Are these brightfield images?");			
			
//particle analysis variables
sizeMin =getNumber("partiticle size minimum: ", 0);
sizeMax = getNumber("particle size maximum", 1000);
circMin = getNumber("circularity lower bound min is 0.", 0);
circMax = getNumber("circularity upper bound: max is 1.0", 1);

			
//activate batch mode			
setBatchMode(true);	

macro "ImageAnalysis"{
			
	// LOOP to process the list of files			
	for (i = 0; i < lengthOf(fileList); i++) {			
		// define the "path" 		
		// by concatenation of dir and the i element of the array fileList		
		current_imagePath = dir+fileList[i];		
		// check that the currentFile is not a directory		
		if (!File.isDirectory(current_imagePath)){		
			// open the image and split	
			open(current_imagePath);	


			preThresholdingProcessing();
			
			//check if local or global thresholding is happening to call the appropriate function	
			if(protocol){	
				local_threshold();
			}	
			else {
				global_threshod();
			}	
				
			//calling particle area to analyze thresholded images and their particles and display summary of results	
			particleArea();	
				
			//closes current drawing of the image that has the particle outlines and then reverts the original image back to its original state	
			close();	
			run("Revert");	
				
				
			//calculates the area of the slices by running the default threshold method for non brightfield images or the triangle method for brightfield. change as needed	
			sliceArea();	
				
				
			// make sure to close every images befores opening the next one	
			run("Close All");	
		}		
	}
	printParameters();

}


function preThresholdingProcessing(){
	/*
	 * Prethreshold image processing for images should be done here
	 */	
	 
	//done so that any abnormalities can hopefully be cropped out	
	//run("Subtract Background...", "rolling=15 sliding");
	run("Auto Crop");	
				
}

/* This function runs the user selected thresholding method using global thesholding parameters
 *  
 *  it first checks if the method is autothresholding or one single value
 *  if not using an autothresholding method, then it'll check if it is brightfield or not and run the appropriate option for the background so that thresholding can work.
 *  
 *  
 *  any of the methods can be changed to run a specfic algorithm by replacing what is inbetween the quotation marks in the method=[] call
 */
function global_threshod(){	
	
	if(!autoT){		
		if(isBrightField){	
			setOption("BlackBackground", false);	
		}				
			setThreshold(threshold, upperThresh);		
	}
	else{
		if(isBrightField)
		{
			run("Auto Threshold", "method=["+gThreshAlgo+"]");
		}
		else {
			run("Auto Threshold", "method=["+gThreshAlgo+"] white");
		}
	}
}		

/* This function runs the user selected thresholding method using local thesholding parameters
 *  
 *  it first checks if the images are brightfield or not so that it can run wither the black background or white background option for local thresholding
 *  the thresholding method and the radius are all gathered from the user in the earlier lines
 */

 
function local_threshold(){			
	if(isBrightField){		
		run("Auto Local Threshold", "method=["+l_threshold+"] radius=["+radius+"] parameter_1=0 parameter_2=0 black");	
		}	
		else{	
			run("Auto Local Threshold", "method=["+l_threshold+"] radius=["+radius+"] parameter_1=0 parameter_2=0 white");
		}	
}	


/* This function runs particle analysis on a thresholded 8bit image
 *  
 * the parameters for the size and circularity are chosen by the user
 * this can be changed and have embedded values by changng what is in the brackets and quotations yourself
 */
 
function particleArea() {			
	run("Analyze Particles...", "size=["+sizeMin+"]-["+sizeMax+"] circularity=["+circMin+"]-["+circMax+"] show=Outlines exclude summarize");		
}

/*
 * outputs slice area of image by trying to threshold as much of the section as possible. Works best if images are autocropped. 
 * Algorithm for thresholding may vary depending on quality of images and section. To change, simply change what is written after 'method=' to accomodate what you need if it is not a brightfield image
 * if it is a brightfield image, substitute whatever values you come up with that seems to work best and it will use those values for each image.
 */
 
function sliceArea(){			
	if(isBrightField){		
		setThreshold(FINAL_ISBRIGHTFIELD_TOTALSLICEAREA_LOWERBOUND, FINAL_ISBRIGHTFIELD_TOTALSLICEAREA_UPPERBOUND);	
	}		
	else{		
		run("Auto Threshold", "method=["+FINAL_NOTBRIGHTFIELD_TOTALSLICEAREA_THRESHOLD_ALGO+"] white");	
	}		
	run("Measure");		
}			

/*
 * this function prints the parameteres of most variables. if you wish to add something to output, start a new line that is within the brackets relevant to its information and write 'print("")' with
 * whatever information you desire to print inbetween the quotation marks
 */

function printParameters(){
	print(protocolString)
	if(protocol){		
	 	print("Local threshold method: "+l_threshold);
	 	print("Radius: " + toString(radius));
		}
	else {			
		if(!autoT){
			print("Threshold: " + toString(threshold));
			}
		else{
			print("Threshold method: "+gThreshAlgo);
			}
		}			
	print("Particle size =["+sizeMin+"]-["+sizeMax+"] circularity=["+circMin+"]-["+circMax+"]");
	if(isBrightField){		
		print("Brightfield slides, slice threshold method: setThreshold(["+FINAL_ISBRIGHTFIELD_TOTALSLICEAREA_LOWERBOUND+"], ["+FINAL_ISBRIGHTFIELD_TOTALSLICEAREA_UPPERBOUND+"])");	
		}		
	else{		
		print("Non brightfield slides, slice threshold method: Auto Threshold, method=["+FINAL_NOTBRIGHTFIELD_TOTALSLICEAREA_THRESHOLD_ALGO+"] white");	
		}		
}			

			
setBatchMode(false);			
