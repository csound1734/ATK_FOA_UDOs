
/*
FOA ATK Transforms.
By Oscar Pablo Di Liscia. Research Program STSEAS, Escuela Universitaria de Musica, UNQ, Argentina. 
PICT 2015-2604 FONCyT Argentina

Csound UDOs for First Order B-Format Ambisonic Transforms.
Based on the Ambisonics Toolkit (ATK) for Super Collider (Joseph Anderson, John Mc Crea, Juan Pampin, Josh Parmenter, Daniel Peterson).
The original SC code can be obtained here: 
https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260
For an explanation of the transforms, as well as plots of almost all of these, see:
http://www.ambisonictoolkit.net/documentation/supercollider/

The current available UDOs Tranforms are:

A-Full soundfield transforms UDOs
(where the transform is applied to the complete soundfield)

A.1-FOArtt_a			rotates, tilts, tumbles, a-rate
A.2-FOAdirectO_a		apply directivity from unchanged soundfield to mono, a-rate
	todo:
	A.3-FOAmirrorO_a	mirrors the soundfield towards a specified direction, a-rate

B-"Aimed" transforms UDOs
(where the user specifies the direction (azimuth, elevation) towards which the transform will be performed)

B.1-FOAdirect_a			apply directivity towards a specified direction, a-rate
B.2-FOAdominate_a		dominates the soundfield towards a specified direction, a-rate
B.3-FOAzoom_a			zooms the soundfield towards a specified direction, a-rate
B.4-FOAfocus_a			focus the soundfield towards a specified direction, a-rate
B.5-FOApush_a			pushes the soundfield towards a specified direction, a-rate	
B.6-FOApress_a			presses the soundfield towards a specified direction, a-rate
	todo:
	B.7-FOAmirror_a		mirrors the soundfield towards a specified direction, a-rate

Check each transform comments in order to see the type, range and meaning of their arguments.

NB: The author is aware that the use of matrices holding the transforms coefficients
may result in a more neat and readable code. 
However, because of performance reasons in the Csound environment, the code was written using single 
variables for the transforms coefficients.   
*/

/* BEGIN AMENDMENT- a quick-and-dirty (breaks true ambisonic fidelity) mod
 * for the purposes of allowing stereo playback for initial testing only.
 * the ambisonic algorithms do not work as intended as a result. gi_chnls4
 * is set to a constant value of 4 and replaces nchnls in the code that follows. */
          gi_nchnls4 = 4
          ;END
;numerical constants  
gipi 		init 	4.*taninv(1.)	;the honorable PI and his family
gipi2		init	2.*gipi
gipio2		init	gipi/2.
					;some other constants
gisqrt2		init	sqrt(2.)
girec_sqrt2	init	1. / sqrt(2.)	
girec_sqrt8	init	1. / sqrt(8.)	


gSfilename 	= "Stravinsky.wav"	;input FOA B-Format file for testing 
;source http://ambisonia.com/Members/ajh/ambisonicfile.2006-09-06.2014008935/

;macros of constants
#define		ORD1	#4#

#define		ROT	#0#	;soundfield rotations axes
#define		TIL	#1#
#define		TUM	#2#

#define		ZOOM	#0#	;types of transforms
#define		FOCUS	#1#
#define		PUSH	#2#
#define		PRESS	#3#

;macros of processes
/*
The following two macros are to be used together and are hardcoded to specific variable names.
These are always used in the "aimed transform", because of the strategy of rotating/tumbling the soundfield so
as it aims to 0,0; performing the transform aiming this direction and restoring the original
soundfield by tumblig/rotating again. 
*/
#define	I_ROT_M
#
;rotate/tumble the soundfield, so as the direction of interest (azi, ele) becomes 0,0
;warning: this macro is hardcoded to variable names, don´t change them unless you really know what you are doing.
	;precompute to save operations
	;we don't need to compute neither cos(-theta) nor sin(-theta) since:
	;sin(-theta)= -sin(theta) and cos(-theta)=  cos(theta)
	aCosa=cos(aAzi)
	aSina=sin(aAzi)
	aCose=cos(aEle)
	aSine=sin(aEle)
	;BF signals processing	
	;-azimuth rotation
	aFOAo[1]=	aFOAi[1]*aCosa    - aFOAi[2]*(-aSina) 
	aFOAo[2]=	aFOAi[1]*(-aSina) + aFOAi[2]*aCosa
	;-elevation tumbling 
	aXaux=		aFOAo[1]
	aFOAo[1]=	aFOAo[1]*aCose - aFOAi[3]*(-aSine) 
	aFOAo[3]=	aXaux*(-aSine) + aFOAi[3]*aCose
#
#define	O_ROT_M
#
;restore the soundfield, to the original direction of interest 
;warning1: this macro should not be used if the precedent macro is not called
;as it uses variables that are computed previously.
;warning2: this macro is hardcoded to variable names, don´t change them unless you really know what you are doing.
	;elevation tumbling
	aXaux=		aFOAo[1]
	aFOAo[1]=	aFOAo[1]*aCose - aFOAo[3]*aSine
	aFOAo[3]=	aXaux*aSine + aFOAo[3]*aCose

	;azimuth rotation
	aXaux=		aFOAo[1]	
	aFOAo[1]=	aFOAo[1]*aCosa - aFOAo[2]*aSina
	aFOAo[2]=	aXaux*aSina    + aFOAo[2]*aCosa
#
/**********************************************************/
/**********************************************************/
/*
Here starts the UDO's definitions for the transforms.
*/
/**********************************************************/
/*
FOArtt_a
Performs rotation, tilting or tumbling on a FOA soundfield.
input args: aFOAi[], axis, angle
	aFOAi[]		= FOA input audio signal array
	axis		= the i-rate axis for rotation
	The following macros may be used: ROT (Z axis rotation), TIL (X axis rotation), TUM (Y axis rotation)
	angle 		= the a-rate rotation angle, in radians, must lie between -PI and PI
output args: aFOAo[]
	aFOAo[]		= FOA output audio signal array
*/
/**********************************************************/
/*the a-rate version of the rotation UDO*/
opcode 	FOArtt_a, a[], a[]ia;  
	
	aFOAi[], iAx, aAng  xin ;read in arguments
	aFOAo[] init gi_nchnls4
	;precompute to save operations
	aCosa=cos(aAng)
	aSina=sin(aAng)
	;BF signals proccessing
	aFOAo[0]=aFOAi[0]
	if(iAx==$ROT) then
		aFOAo[1]= aFOAi[1]*aCosa - aFOAi[2]*aSina 
		aFOAo[2]= aFOAi[1]*aSina + aFOAi[2]*aCosa
		aFOAo[3]= aFOAi[3]
	elseif(iAx==$TIL) then
		aFOAo[1]=	aFOAi[1] 		      
		aFOAo[2]=	aFOAi[2]*aCosa - aFOAi[3]*aSina 
		aFOAo[3]=	aFOAi[2]*aSina + aFOAi[3]*aCosa 
	elseif(iAx==$TUM) then
		aFOAo[1]=	aFOAi[1]*aCosa - aFOAi[3]*aSina   
		aFOAo[2]=	aFOAi[2]		      
		aFOAo[3]=	aFOAi[1]*aSina + aFOAi[3]*aCosa 
		
	endif
	;BF signals output
	xout 	aFOAo
endop
/**********************************************************/
/* 	
FOAdirectO_a
Performs the directivity transform to all direccional signals (i.e., X, Y and Z) on a FOA soundfield.
input args: aWi, aXi, aYi, aZi, aTheta
	aWi, aXi, aYi, aZi	= the four audio-rate FOA signal array
	aTheta 			= the directivity strength, in radians, must lie between -PI/2 and PI/2
output args: aWo, aXo, aYo, aZo
	aWo, aXo, aYo, aZo 	= the four audio-rate FOA signal array 

Comments (adapted from  https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260 ) 
-Theta = 0 retains the current directivity of the soundfield.
-Increasing Theta towards pi/2 decreases the directivity of the soundfield 
*/

opcode 	FOAdirectO_a, a[], a[]a
   
	aFOAi[], aTheta  xin ;read in arguments
	aFOAo[] init gi_nchnls4
	;do directivity transform along all the soundfield
	aG0=sqrt(1 + sin(aTheta))
	aG1=sqrt(1 - sin(aTheta))
	aFOAo[0]= aFOAi[0]*aG0
	aFOAo[1]= aFOAi[1]*aG1 
	aFOAo[2]= aFOAi[2]*aG1
	aFOAo[3]= aFOAi[3]*aG1
	;BF signals output
	xout 	aFOAo

endop
/**********************************************************/
/* 	
FOAdirect_a
Performs the directivity transform on a FOA soundfield.
input args: aFOAi[], aAzi, aEle, aTheta
	aFOAi[]		= FOA input audio signal array
	aAzi, aEle	= azimuth and elevation angles of the interest direction 
			(in radians, following the Ambisonics angles uses, i.e., 0=front center, counterclockwise)
	aTheta 		= the directivity strength, in radians, must lie between -PI/2 and PI/2
output args: aFOAo[]
	aFOAo[]		= FOA output audio signal array

Comments (adapted from https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260 ) 
-Theta = 0 retains the current directivity of the soundfield.
-Increasing Theta towards pi/2 decreases the directivity on
the selected axis (x, y or z), reducing the gains on this axis to zero, and is
equivalent to a 'spatial lo-pass filter'. The resulting image
becomes 'directionless' on the  selected axis.
-Decreasing Theta towards -pi/2 decreases the gain on the three signals that
correspond to the axes different than the one selected, (i.e. w, y and z if x is selected)
and can be regarded as a kind of 'spatial sharpening' filter on the  selected axis.
-Standard use of direct is with Theta >=0, Theta < PI/2
*/
opcode 	FOAdirect_a, a[], a[]aaa
   
	aFOAo[] init gi_nchnls4
	aFOAi[], aAzi, aEle, aTheta  xin ;read in arguments
	;rotate/tumble the soundfield, so as the direction of interest (azi, ele) becomes 0,0
	$I_ROT_M
	;do directivity transform along the X axis
	aG0=sqrt(1 + sin(aTheta))
	aG1=sqrt(1 - sin(aTheta))
	aFOAo[0]=	aFOAi[0]*aG0
	aFOAo[1]=	aFOAo[1]*aG1 
	aFOAo[2]=	aFOAo[2]*aG0
	aFOAo[3]=	aFOAo[3]*aG0
	;restore the original soundfield by rotating and tumbling again
	$O_ROT_M
	;BF signals output
	xout 	aFOAo

endop
/**********************************************************/
/*
FOAdominate_a
Performs the dominance transform on a FOA soundfield.
input args: aFOAi, aAzi, aEle, aGain
	aFOAi[]		= FOA input audio signal array
	aAzi, aEle	= azimuth and elevation angles of the interest direction 
			(in radians, following the Ambisonics angles uses, i.e., 0=front center, counterclockwise)
	aGain 		= the dominance strength, in dBfs
output args: aFOAo[]
	aFOAo[]		= FOA output audio signal array

Comments (adapted from https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260 )
Gain: the dominance gain, in dB, applied the axis defined by
(azimuth, elevation). Positive values increase the gain at
(azimuth, elevation) to +gain, while decreasing the gain at
(-azimuth, -elevation) to -gain, simultaneously distorting
the image towards (azimuth, elevation). Negative values of
gain invert this distortion, distorting the image towards
(-azimuth, -elevation). The default, 0, results in no change.
*/
/**********************************************************/
/*the a-rate version of the dominance UDO*/
opcode 	FOAdominate_a, a[], a[]aaa
   
	aFOAi[], aAzi, aEle, aGain  xin ;read in arguments
	aFOAo[] init gi_nchnls4
	;rotate/tumble the soundfield, so as the direction of interest (azi, ele) becomes 0,0
	$I_ROT_M
	;do dominance transform along the x axis
	;compute factors
	kGain	downsamp aGain		;pow doesn't accept an a-rate exponent (!)
	aGain	= pow(10., kGain/20.)	;convert from dBfs to linear amplitude 
	arec_g 	= 1./aGain
	ak0 	= .5 * (aGain + arec_g)
	ak1 = girec_sqrt2 * (aGain - arec_g)
	;B-Format signal processing
	aFOAo[0]=	aFOAi[0]*ak0 + aFOAi[1]*0.5*ak1
	aFOAo[1]=	aFOAi[0]*ak1 + aFOAi[1]*ak0 
	;restore the original sound field by rotating and tumbling again
	$O_ROT_M
	;BF signals output
	xout 	aFOAo

endop
/**********************************************************/
/*
FOAzoom_a
Performs the zoom transform on a FOA soundfield.
input args: aFOAi[], aAzi, aEle, aTheta
	aFOAi[]		= FOA input audio signal array
	aAzi, aEle	= azimuth and elevation angles of the interest direction 
			(in radians, following the Ambisonics angles uses, i.e., 0=front center, counterclockwise)
	aTheta 		= the zoom strength, in radians, must lie between -PI/2 and PI/2
output args: aFOAo[]
	aFOAo[]		= FOA output audio signal array
	
Comments (adapted from https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260 )
Theta is the angle of distortion in radians. Positive values zoom 
on the direction of interest of the image, and at pi/2 collapse the soundfield 
to mono, reducing the gain at the opposite of the direction of interest to -inf dB.
Negative values zoom on at the opposite of the direction of interest. The default, 0, 
results in no change.
*/
/**********************************************************/
/*the a-rate version of the zoom UDO*/
opcode 	FOAzoom_a, a[], a[]aaa
   
	aFOAi[], aAzi, aEle, aTheta  xin ;read in arguments
	aFOAo[] init gi_nchnls4	
	;rotate/tumble the soundfield, so as the direction of interest (azi, ele) becomes 0,0
	$I_ROT_M
	;do zoom transform along the x axis
	;compute factors
	ak0 = sin(aTheta);
	ak1 = cos(aTheta);
	;B-Format signal processing
	aFOAo[0]= aFOAi[0]  + aFOAo[1]*ak0*girec_sqrt2
	aFOAo[1]= aFOAi[0]*ak0*gisqrt2 + aFOAo[1]
	aFOAo[2]= aFOAo[2]*ak1
	aFOAo[3]= aFOAo[3]*ak1
	;restore the original soundfield by rotating and tumbling again
	$O_ROT_M
	;BF signals output
	xout 	aFOAo

endop
/**********************************************************/
/*
FOAfocus_a
input args: aFOAi[], aAzi, aEle, aTheta
	aFOAi[]		= FOA input audio signal array
	aWi, aXi, aYi, aZi	= the four audio-rate FOA signals
	aAzi, aEle		= azimuth and elevation angles of the interest direction 
				(in radians, following the Ambisonics angles uses, i.e., 0=front center, counterclockwise)
	aTheta 			= the focus strength, in radians, must lie between -PI/2 and PI/2
output args: aFOAo[]
	aFOAo[]		= FOA output audio signal array

Comments (adapted from https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260 )
Theta: the angle of distortion in radians. Positive values focus
on (azimuth, elevation) of the image, and at pi/2 collapse the soundfield
to mono, reducing the gain at (-azimuth, -elevation) to -inf dB.
Negative values focus on (-azimuth, -elevation). The default, 0,
results in no change.
*/
/**********************************************************/
/*the a-rate version of the focus UDO*/
opcode 	FOAfocus_a, a[], a[]aaa
   
	aFOAi[], aAzi, aEle, aTheta  xin ;read in arguments
	aFOAo[] init gi_nchnls4	
	;rotate/tumble the soundfield, so as the direction of interest (azi, ele) becomes 0,0
	$I_ROT_M
	;do focus transform along the x axis
	;compute factors
	asinth=sin(aTheta)
	ak0 = 1 / (1 + abs(asinth));
	ak1 = gisqrt2 * asinth * ak0
	ak2 = cos(aTheta) * ak0
	;B-Format signal processing
	aFOAo[0]=	aFOAi[0]*ak0 + aFOAo[1]*(ak1/2.)
	aFOAo[1]=	aFOAi[0]*ak1 + aFOAo[1]*ak0
	aFOAo[2]=	aFOAo[2]*ak2
	aFOAo[3]=	aFOAo[3]*ak2
	;restore the original soundfield by rotating and tumbling again
	$O_ROT_M
	;BF signals output
	xout 	aFOAo

endop
/**********************************************************/
/*
FOApush_a
Performs the push transform on a FOA soundfield.
input args: aFOAi[], aAzi, aEle, aTheta
	aFOAi[]		= FOA input audio signal array
	aAzi, aEle	= azimuth and elevation angles of the interest direction 
				(in radians, following the Ambisonics angles uses, i.e., 0=front center, counterclockwise)
	aTheta 		= the push strength, in radians, must lie between -PI/2 and PI/2
output args: aFOAo[]
	aFOAo[]		= FOA output audio signal array

Comments (adapted from https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260 )
Theta: the angle of distortion in radians, from -pi/2 to pi/2.
    Positive values push to (azimuth, elevation) of the image, and at
    pi/2 collapse the soundfield to mono. Negative values push to
    (-azimuth, -elevation). The default, 0, results in no change.
*/
/**********************************************************/
/*the a-rate version of the push UDO*/
opcode 	FOApush_a, a[], a[]aaa
   
	aFOAi[], aAzi, aEle, aTheta  xin ;read in arguments
	aFOAo[] init gi_nchnls4	
	;rotate/tumble the soundfield, so as the direction of interest (azi, ele) becomes 0,0
	$I_ROT_M
	;do push transform along the x axis
	;compute factors
	asinth=sin(aTheta)
	acosth=cos(aTheta)
	ak0 = gisqrt2 * asinth * abs(asinth);
	ak1 = acosth * acosth
	;B-Format signal processing
	aFOAo[0]=	aFOAi[0]
	aFOAo[1]=	aFOAi[0]*ak0 + aFOAo[1]*ak1
	aFOAo[2]=	aFOAo[2]*ak1
	aFOAo[3]=	aFOAo[3]*ak1
	;restore the original soundfield by rotating and tumbling again
	$O_ROT_M
	;BF signals output
	xout 	aFOAo

endop
/**********************************************************/
/*
FOApress_a
Performs the press transform on a FOA soundfield.
input args: aFOAi[], aAzi, aEle, aTheta
	aFOAi[]		= FOA input audio signal array
	aAzi, aEle	= azimuth and elevation angles of the interest direction 
			(in radians, following the Ambisonics angles uses, i.e., 0=front center, counterclockwise)
	aTheta 		= the press strength, in radians, must lie between -PI/2 and PI/2
output args: aFOAo[]
	aFOAo[]		= FOA output audio signal array

Comments (adapted from https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260 )
Theta: the angle of distortion in radians, from -pi/2 to pi/2.
    Positive values press to (azimuth, elevation) of the image, and at
    pi/2 collapse the soundfield to mono. Negative values press to
    (-azimuth, -elevation). The default, 0, results in no change.
*/
/**********************************************************/
/*the a-rate version of the press UDO*/
opcode 	FOApress_a, a[], a[]aaa
   
	aFOAi[], aAzi, aEle, aTheta  xin ;read in arguments
	aFOAo[] init gi_nchnls4	
	;rotate/tumble the soundfield, so as the direction of interest (azi, ele) becomes 0,0
	$I_ROT_M
	;do press transform along the x axis
	;compute factors
	asinth=sin(aTheta)
	acosth=cos(aTheta)
	ak0 = gisqrt2 * asinth * abs(asinth);
	ak1 = acosth * acosth
	ak2 = acosth
	;B-Format signal processing
	aFOAo[0]=	aFOAi[0]
	aFOAo[1]=	aFOAi[0]*ak0 + aFOAo[1]*ak1
	aFOAo[2]=	aFOAo[2]*ak2
	aFOAo[3]=	aFOAo[3]*ak2
	;restore the original soundfield by rotating and tumbling again
	$O_ROT_M
	;BF signals output
	xout	aFOAo

endop

/**********************************************************/
/**********************************************************/

