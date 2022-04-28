// BEAM HARDENING CORRECTION PLUG-IN FOR CORE SAMPLES AND NEAR CYLINDRICAL SHAPES
//For any request please contact cromano3@wisc.edu
//If you intend to use this work and distribute derivate works please cite: Romano, C., Minto, J. M., Shipton, Z. K., & Lunn, R. J. (2019). Automated high accuracy, rapid beam hardening correction in X-Ray Computed Tomography of multi-mineral, heterogeneous core samples. Computers & Geosciences, 131, 144-157.https://doi.org/10.1016/j.cageo.2019.06.009

// GPU-accelerated by Robert Haase (rhaase@mpi-cbg.de)
// In order to run the adapted version, activate the CLIJ and CLIJ2 update sites in your Fiji (check here how to https://clij.github.io/)
//Please cite: Haase, R., Royer, L.A., Steinbach, P. et al. CLIJ: GPU-accelerated image processing for everyone. Nat Methods 17, 5–6 (2020). https://doi.org/10.1038/s41592-019-0650-1"

//Input=stack of the images to correct (File-Import-Image Sequence(no virtual stack))

run("8-bit");
title1=getTitle();
w=getWidth();
h=getHeight();
s=nSlices;
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, 
msec); 
print(hour, minute, second); 

Dialog.create("BH Correction Parameters");
  Dialog.addNumber("Slice number of bottom:", 1);
  Dialog.addNumber("Slice number of top:", s);
  Dialog.addNumber("Width of Outer ring(pixel):", 0);// or the sum (pixel) of more rings
  Dialog.addCheckbox("Internal scan", false);

 
  Dialog.show();
  P1z = Dialog.getNumber();
  P2z = Dialog.getNumber();
  widOut=Dialog.getNumber();
  internal = Dialog.getCheckbox();

setBatchMode(true);
selectWindow(title1);
run("Set Scale...", "distance=0");//in case no scale in pixel is set
//Find the radius and the centre
  if (internal==true) {
  for(z=1;z<=1;z++){					
			selectWindow(title1);
			run("Duplicate...", " ");//duplicate the first slice
			title2=getTitle();
			setAutoThreshold("Li dark");// Make it binary with autotreshold
			setOption("BlackBackground", false);
			run("Convert to Mask", "method=Li background=Minimum calculate");
			run("Fill Holes");
			doWand((w/2), (h/2));//auto selection
			run("Interpolate", "interval=10"); 
	        getSelectionCoordinates(x, y); //Coordinates of the selection
			an180=round((x.length/2)-1);
			an90=round((an180/2))-1;
			xcarray=newArray(an180);
			ycarray=newArray(an180);
			rarray=newArray(an180);
			//Applying the therome "There is one and only one circle passing trough three given points"
		      for (j=0;j<=an180-1;j++){
			    b1 = x[0+j]* x[0+j] + y[0+j]*y[0+j]; 
			    b2 = x[an90+j]* x[an90+j] + y[an90+j]*y[an90+j]; 
			    b3 = x[an180+j]* x[an180+j] + y[an180+j]*y[an180+j]; 			
			    detA = 4*( x[0+j]*(y[an90+j]-y[an180+j]) - y[0+j]*(x[an90+j]-x[an180+j]) + (x[an90+j]*y[an180+j]- x[an180+j]*y[an90+j])); 				
			    xcarray[j] = round(2*( b1*(y[an90+j]-y[an180+j]) - y[0+j]*(b2-b3) + (b2*y[an180+j]-b3*y[an90+j]) )/detA); 
			    ycarray[j] = round(2*( x[0+j]*(b2-b3) - b1*(x[an90+j]-x[an180+j]) + (x[an90+j]*b3-x[an180+j]*b2) )/detA); 
			    K = 4*( x[0+j]*(y[an90+j]*b3-y[an180+j]*b2) - y[0+j]*(x[an90+j]*b3-x[an180+j]*b2) + b1*(x[an90+j]*y[an180+j]-x[an180+j]*y[an90+j]))/detA; 
			    rarray[j] =round( sqrt(abs(K +  xcarray[j]* xcarray[j] + ycarray[j]*ycarray[j]))); 
				}		

				//mode for radius
			 t = 0;
			    for( i=0; i<rarray.length; i++){
			        for( j=1; j<rarray.length-i; j++){
			            if(rarray[j-1] > rarray[j]){
			                t = rarray[j-1];
			                rarray[j-1] = rarray[j];
			                rarray[j] = t;
			            }
			        }
			    }
			    radius = rarray[0];
			    temp = 1;
			    temp2 = 1;
			    for( i=1;i<rarray.length;i++){
			        if(rarray[i-1] == rarray[i]){
			            temp++;
			        }
			        else {
			            temp = 1;
			        }
			        if(temp >= temp2){
			            radius = rarray[i];
			            temp2 = temp;
			        }
			    }

			    //mode for xcentre
			 t = 0;
			    for( i=0; i<xcarray.length; i++){
			        for( j=1; j<xcarray.length-i; j++){
			            if(xcarray[j-1] > xcarray[j]){
			                t = xcarray[j-1];
			                xcarray[j-1] = xcarray[j];
			                xcarray[j] = t;
			            }
			        }
			    }
			    xcentre = xcarray[0];
			    temp = 1;
			    temp2 = 1;
			    for( i=1;i<xcarray.length;i++){
			        if(xcarray[i-1] == xcarray[i]){
			            temp++;
			        }
			        else {
			            temp = 1;
			        }
			        if(temp >= temp2){
			            xcentre = xcarray[i];
			            temp2 = temp;
			        }
			    }
			    //mode for yc
			 t = 0;
			    for( i=0; i<ycarray.length; i++){
			        for( j=1; j<ycarray.length-i; j++){
			            if(ycarray[j-1] > ycarray[j]){
			                t = ycarray[j-1];
			                ycarray[j-1] = ycarray[j];
			                ycarray[j] = t;
			            }
			        }
			    }
			   	ycentre = ycarray[0];
			    temp = 1;
			    temp2 = 1;
			    for( i=1;i<ycarray.length;i++){
			        if(ycarray[i-1] == ycarray[i]){
			            temp++;
			        }
			        else {
			            temp = 1;
			        }
			        if(temp >= temp2){
			            ycentre = ycarray[i];
			            temp2 = temp;
			        }
		        r1=radius-widOut;//Radius
			    }}}

if (internal==false) {
Xc=newArray(nSlices);// Create array to populate with xcoordinates of the centre of the slices
Yc=newArray(nSlices);// Create array to populate with ycoordinates of the centre of the slices		    
	for(z=1;z<=s;z++){					
			selectWindow(title1);
			run("Duplicate...","title=duplicate.tif duplicate range=z-z");//duplicate each slice
			title2=getTitle();
			setAutoThreshold("Li dark");// Make it binary with autotreshold
			setOption("BlackBackground", false);
			run("Convert to Mask", "method=Li background=Minimum calculate");
			run("Fill Holes");
			doWand((w/2), (h/2));//auto selection
			run("Interpolate", "interval=10"); 
	        getSelectionCoordinates(x, y); //Coordinates of the selection
			an180=round((x.length/2)-1);
			an90=round((an180/2))-1;
			xcarray=newArray(an180);
			ycarray=newArray(an180);
			rarray=newArray(an180);
			//Applying the therome "There is one and only one circle passing trough three given points"
		      for (j=0;j<=an180-1;j++){
			    b1 = x[0+j]* x[0+j] + y[0+j]*y[0+j]; 
			    b2 = x[an90+j]* x[an90+j] + y[an90+j]*y[an90+j]; 
			    b3 = x[an180+j]* x[an180+j] + y[an180+j]*y[an180+j]; 			
			    detA = 4*( x[0+j]*(y[an90+j]-y[an180+j]) - y[0+j]*(x[an90+j]-x[an180+j]) + (x[an90+j]*y[an180+j]- x[an180+j]*y[an90+j])); 				
			    xcarray[j] = round(2*( b1*(y[an90+j]-y[an180+j]) - y[0+j]*(b2-b3) + (b2*y[an180+j]-b3*y[an90+j]) )/detA); 
			    ycarray[j] = round(2*( x[0+j]*(b2-b3) - b1*(x[an90+j]-x[an180+j]) + (x[an90+j]*b3-x[an180+j]*b2) )/detA); 
			    K = 4*( x[0+j]*(y[an90+j]*b3-y[an180+j]*b2) - y[0+j]*(x[an90+j]*b3-x[an180+j]*b2) + b1*(x[an90+j]*y[an180+j]-x[an180+j]*y[an90+j]))/detA; 
			    rarray[j] =round( sqrt(abs(K +  xcarray[j]* xcarray[j] + ycarray[j]*ycarray[j]))); 
				}		

				//mode for radius
			 t = 0;
			    for( i=0; i<rarray.length; i++){
			        for( j=1; j<rarray.length-i; j++){
			            if(rarray[j-1] > rarray[j]){
			                t = rarray[j-1];
			                rarray[j-1] = rarray[j];
			                rarray[j] = t;
			            }
			        }
			    }
			    radius = rarray[0];
			    temp = 1;
			    temp2 = 1;
			    for( i=1;i<rarray.length;i++){
			        if(rarray[i-1] == rarray[i]){
			            temp++;
			        }
			        else {
			            temp = 1;
			        }
			        if(temp >= temp2){
			            radius = rarray[i];
			            temp2 = temp;
			        }
			    }

			    //mode for xcentre
			 t = 0;
			    for( i=0; i<xcarray.length; i++){
			        for( j=1; j<xcarray.length-i; j++){
			            if(xcarray[j-1] > xcarray[j]){
			                t = xcarray[j-1];
			                xcarray[j-1] = xcarray[j];
			                xcarray[j] = t;
			            }
			        }
			    }
			    xc = xcarray[0];
			    temp = 1;
			    temp2 = 1;
			    for( i=1;i<xcarray.length;i++){
			        if(xcarray[i-1] == xcarray[i]){
			            temp++;
			        }
			        else {
			            temp = 1;
			        }
			        if(temp >= temp2){
			            xcentre = xcarray[i];
			            temp2 = temp;
			        }
			    }
			    //mode for yc
			 t = 0;
			    for( i=0; i<ycarray.length; i++){
			        for( j=1; j<ycarray.length-i; j++){
			            if(ycarray[j-1] > ycarray[j]){
			                t = ycarray[j-1];
			                ycarray[j-1] = ycarray[j];
			                ycarray[j] = t;
			            }
			        }
			    }
			   yc = ycarray[0];
			    temp = 1;
			    temp2 = 1;
			    for( i=1;i<ycarray.length;i++){
			        if(ycarray[i-1] == ycarray[i]){
			            temp++;
			        }
			        else {
			            temp = 1;
			        }
			        if(temp >= temp2){
			            ycentre = ycarray[i];
			            temp2 = temp;
			        }
		        r1=radius-widOut;//Radius
		        Xc[z-1]=xcentre;// x centre of the sample for each slice
		        Yc[z-1]=ycentre;// y centre of the sample for each slice
		        
}
}}
selectWindow(title2);
close();
selectWindow(title1);
run("Select None");
// Download Radial profile angle Ext. https://imagej.nih.gov/ij/plugins/radial-profile-ext.html
if (internal==true) {
	run("Radial Profile Angle", "x_center="+xcentre+" y_center="+ycentre+" radius=r1 starting_angle=0 integration_angle=180 ");// Radial profile on first slice to get the step 
}
if (internal==false) {
run("Radial Profile Angle", "x_center="+Xc[0]+" y_center="+Yc[0]+" radius=r1 starting_angle=0 integration_angle=180 ");// Radial profile on first slice to get the step 
}
		for(i = 0; i != Ext.getBinSize; i++){
			setResult("X", 0 * Ext.getBinSize + i, Ext.getXValue(i));
			setResult("Y", 0 * Ext.getBinSize + i, Ext.getYValue(0, i));
		}
setOption("ShowRowNumbers", false);
updateResults();	
close();
step = getResult("X", 0);// Useful in case the step at wich the Radial Profile is calulcated is different from 1
np = r1/step;
		if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
		}
cumul=newArray(round(np));
rr=newArray(s);
//Radial profile for each slice and then one final Average Radial Profile
			for(z=1;z<=s;z++){	
			setSlice(z);{			
			selectWindow(title1);
			run("Select None");
			if (internal==true) {
			run("Radial Profile Angle", "x_center="+xcentre+" y_center="+ycentre+" radius=r1 starting_angle=0 integration_angle=180 ");
			}
			if (internal==false) {
			run("Radial Profile Angle", "x_center="+Xc[z-1]+" y_center="+Yc[z-1]+" radius=r1 starting_angle=0 integration_angle=180 ");
			}
			run("Clear Results");
				for(i = 0; i != Ext.getBinSize; i++){			
					setResult("X", 0 * Ext.getBinSize + i, Ext.getXValue(i));
					setResult("Y", 0 * Ext.getBinSize + i, Ext.getYValue(0, i));
				}
			setOption("ShowRowNumbers", false);
			updateResults();
			close();
			n = nResults(); 
			Array1x = newArray(n);	
				for(i=0; i<Array1x.length; i++){ //Populate array with results of the Radial Profile Angle plug-in
						Array1x[i] = getResult("X", i);
					}
			Array1y = newArray(n);
				for(i=0; i<Array1y.length; i++){
						Array1y[i] = getResult("Y", i);
				}
		    cut=round((cumul.length/100)*70);// Get the last part of the Radial Profile
            Array1y2=Array.slice(Array1y,cut-1,Array1y.length);	
            maxLocs= Array.findMaxima(Array1y2,0);	// Cut the Radial Profile at the maximum value	
            r=round(((maxLocs[0]))+cut);                    
	        rr[z-1]=r; // Array of position of maximum value of Radial Profile for each slice
	        Array1y=Array.slice(Array1y,0,rr[z-1]);
		    }	 
				for (j=0;j<=Array1y.length-1;j++) cumul[j]=cumul[j]+Array1y[j];// Sum the Radial Profiles of all slices in one array (cumul) 	
	      }	
	         rr2=Array.sort(rr)	;
         if (nSlices>1)	{	     
            end=rr2.length-1;
			for (i=0;i<end;i++){
				st=(end-i-1);
				end2=end-i;
				st2=rr2[st];
				end3=rr2[end2];
		     for (j=st2;j<end3;j++) {
		 	cumul[j]=cumul[j]/(s-(end2));
		 	 }	 	
			}
		 	for (j=0;j<st2;j++) {
		 	cumul[j]=cumul[j]/s;
		}
        cumul=Array.slice(cumul,0,rr2[rr2.length-1]);
        }	
        if (nSlices==1)	{	 
        cumul=Array.slice(cumul,0,Array1y.length);// Average Radial Profile
        }
if(isOpen("Results"))
	{
	selectWindow("Results");
		run("Close");
	}   
//Cut off point(COP)
t=(10*cumul.length)/100;
tt=Array.slice(cumul,0,t-1);//Consider the beginning of the Average Radial Profile
Array.getStatistics(tt, min, max, mean, std);//Calculate the mean of the first values in case of noise
max2=cumul[cumul.length-1];// Max of the Average Radial Profile
range2=(max2-mean);
perc=range2*25/100;// 25% of the range
myNumber = perc+mean;// COP
distance =abs(cumul[0] - myNumber);
idx = 0;
for( c = 1; c < cumul.length; c++){
    cdistance = abs(cumul[c] - myNumber);
    if(cdistance < distance){
        idx = c;
        distance = cdistance;
    }
}
theNumber = cumul[idx];
n=theNumber;
found=0;
for(i=0;i<cumul.length && found==0;i++){// index of COP 
if(n==cumul[i]){
found=1;
}}
perc2=round((i*100)/cumul.length);

//Split the curve in two 
startpoint=round((cumul.length/100)*perc2);
cumul2=Array.slice(cumul,startpoint-1,cumul.length-1);//Last part of the Average Radial Profile for fitting with Inverse rodbard
Array3x=Array.slice(Array1x,startpoint-1,cumul.length-1);
Array.getStatistics(cumul2, min, max, mean, std);
range=max-min;

//Equation for calculation of inital guesses b and c
bg=30;
cg2=40;

//Fitting
InverseRodbard = "y = c*pow(((x-a)/(d-x)),(1/b))";// Inverse rodbard of the last part
initialGuesses = newArray(0, bg, cg2, r1);
Fit.doFit(InverseRodbard,Array3x,cumul2,initialGuesses);
print("Fit = Inverse Rodbard, a="+d2s(Fit.p(0),6)+", b="+d2s(Fit.p(1),6)+", c="+d2s(Fit.p(2),6)+", d="+d2s(Fit.p(3),6)+" R^2="+d2s(Fit.rSquared,3)) ; //N.B. 6 denotes number of decimal places
	ar = Fit.p(0);
	br = Fit.p(1);
	cr = Fit.p(2);
	dr= Fit.p(3);
	
if (dr<r1)	{
	dr=r1+5;
}
//Overlapping window to normalize the results after the two curve fitting
n=round(r1/100*1);	//Size of the overlapping window
if (n<5){// at least 5 points in the overlapping window
n=5;
}
overlap=(startpoint-1)+n;
overlapt = newArray(n);
		for(i=0; i<overlapt.length; i++){ 		
				overlapt[i] = Fit.f(Array3x[i]);
		}
cumul3=Array.slice(cumul,0,overlap);
Array4x=Array.slice(Array1x,0,overlap);

//Exponential of first part of the curve + overlap
Fit.doFit("Exponential with offset",Array4x,cumul3);
print("Fit = Exponential with offset, a="+d2s(Fit.p(0),6)+", b="+d2s(Fit.p(1),6)+", c="+d2s(Fit.p(2),6)+", R^2="+d2s(Fit.rSquared,3)) ; //N.B. 6 denotes number of decimal places
  ae = Fit.p(0);
  be = Fit.p(1);
  ce = Fit.p(2);
 
overlapt2 = newArray(n);
start=(startpoint-1);
Array5x=Array.slice(Array4x,startpoint-1,Array4x.length);
for(i=0; i<overlapt2.length; i++){ 
	overlapt2[i] = Fit.f(Array5x[i]);
}
// Difference in mean between the two curves derived by the two fitting in the overlapping window
Array.getStatistics(overlapt, min, max, mean, stdDev);
mean1=mean;
Array.getStatistics(overlapt2, min, max, mean, stdDev);
mean2=mean;
diff=mean1-mean2; 
selectWindow(title1);
w=getWidth();
h=getHeight();

// init GPU
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();

//Correction 
for(z=1;z<=s;z++){		
	selectWindow(title1);
	setSlice(z);{
	run("Select None");	
	if (internal==true) {
		run("Specify...", "width="+(startpoint*2)*step+" height="+(startpoint*2)*step+" x="+xcentre+" y="+ycentre+" oval centered");
	}
	if (internal==false) {
	run("Specify...", "width="+(startpoint*2)*step+" height="+(startpoint*2)*step+" x="+Xc[z-1]+" y="+Yc[z-1]+" oval centered");
	}
	run("Duplicate...", "duplicate range=z-z");
	title3=getTitle();
	run("Clear Outside");
	w2=getWidth();
	h2=getHeight();

	
	// push image to GPU
	Ext.CLIJ2_push(title3);
	close();
	
	// create output image
	result = "result";
	Ext.CLIJ2_create2D(result, w2, h2, bitDepth());
	
	opencl_code = "" +
	  "const int x = get_global_id(0);\n" +
	  "const int y = get_global_id(1);\n" +
	  "const int2 pos = (int2)(x, y);\n" +
	  "float v = READ_IMAGE(image1, sampler, pos).x;\n" +
	  "float Distance=sqrt(pow((float)(x-(" + startpoint + " * " + step + ")),(float)2)+pow((float)(y-(" + startpoint + " * " + step + ")),(float)2));\n" + // Correct the central part of the slice with exponential with offset coefficients
	  "float CT2=v-(" + ae + " * exp(" + (-be) + " * Distance));\n" + 
	  "WRITE_IMAGE(image2, pos, CONVERT_image2_PIXEL_TYPE(CT2));";

    // Execute operation
	Ext.CLIJx_customBinaryOperation(title3, result, opencl_code);
	
	// copy back to input image and show it
	Ext.CLIJ2_copy(result, title3);
	Ext.CLIJ2_pull(title3);


	selectWindow(title1);
	run("Select None");		
	w2_=getWidth();
	h2_=getHeight();

	// push image to GPU
	Ext.CLIJ2_pushCurrentSlice(title1);

		// create output image
	result2 = "result2";
	Ext.CLIJ2_create2D(result2, w2_, h2_, bitDepth());
	
	opencl_code = "" +
	  "const int x = get_global_id(0);\n" +
	  "const int y = get_global_id(1);\n" +
	  "const int2 pos = (int2)(x, y);\n" +
	  "float v = READ_IMAGE(image1, sampler, pos).x;\n";

      if (internal==true) {
      	opencl_code = opencl_code + 
		"Distance=sqrt(pow((x-" + xcentre + "),2)+pow((y-" + ycentre + "),2));\n"; // Correct with Inverse Rodbard coefficients and formula
	  }
	  if (internal==false) {
      	opencl_code = opencl_code + 
		"float Distance=sqrt(pow((float)(x-(" + Xc[z-1] + ")),(float)2)+pow((float)(y-(" + Yc[z-1] + ")),(float)2));\n"; 
	  }

      opencl_code = opencl_code + 
	  "float div=(Distance+" + (-ar) +")/(fabs(" + dr + "-Distance));\n" +
	  "float b2 = 1 / " + br + ";\n" +
	  "float p=pow(div,b2);\n" +
	  "float CT = (v-(" + cr + " * p))+ " + ce + " + " + diff + ";\n" +
	  "WRITE_IMAGE(image2, pos, CONVERT_image2_PIXEL_TYPE(CT));";

    // Execute operation
	Ext.CLIJx_customBinaryOperation(title1, result2, opencl_code);
	
	// show result
	Ext.CLIJ2_pull(result2);

	// copy back to title1
	run("Select All");
	run("Copy");
	close();
	selectWindow(title1);
	run("Select All");
	run("Paste");

				
	//All the pixels of the image are corrected with the Inverse Rodbard coefficient
	//Then each image is duplicated and the central part is corrected with Exponential with offset coefficients			
	selectWindow(title3);
	run("Specify...", "width="+w2+" height="+h2+" x="+(startpoint*step)+" y="+(startpoint*step)+" oval centered");
	run("Copy");
	close();
	//Paste the central part on the image with Inverse Rodbard correction
	selectWindow(title1);
	setSlice(z);
	if (internal==true) {
	run("Specify...", "width="+(startpoint*2)*step+" height="+(startpoint*2)*step+" x="+xcentre+" y="+ycentre+" oval centered");
	run("Paste");
	}
	if (internal==false) {
	run("Specify...", "width="+(startpoint*2)*step+" height="+(startpoint*2)*step+" x="+(Xc[z-1])+" y="+(Yc[z-1])+" oval centered");
	run("Paste");
	}
	}}
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, 
msec); 
print(hour, minute, second); 
selectWindow(title1);
rename(replace(title1,".tif","_BH_corrected"));
setBatchMode(false);
Ext.CLIJ2_clear();
