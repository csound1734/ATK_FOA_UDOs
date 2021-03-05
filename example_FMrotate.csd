/*
     Experimenting with ambisonics. March 5th 2021
     This code heavily borrows from O. P. Di Liscia's work:
     https://github.com/odiliscia/ATK_FOA_UDOs
*/
<CsoundSynthesizer>
<CsOptions>
-odac -d -m195
</CsOptions>

<CsInstruments> 

sr          =           48000
ksmps       =           128
nchnls      =           2
nchnls_i    =           1

zakinit 25, 25

;numerical constants  
gipi 		init 	4.*taninv(1.)	;the honorable PI and his family
gipi2		init	2.*gipi
gipio2		init	gipi/2.
					;some other constants
gisqrt2		init	sqrt(2.)
girec_sqrt2	init	1. / sqrt(2.)	
girec_sqrt8	init	1. / sqrt(8.)	

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
	aFOAo[] init 4
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
	aFOAo[] init nchnls
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

 opcode FM_pad, aa, iaaaaaa
idur, aamp, apch, apch2, amodi, amodr, ashift xin
a1          =           amodi*(amodr-1/amodr)/2
a1ndx       =           abs(a1*2/20)            ;a1*2 is normalized from 0-1.
a2          =           amodi*(amodr+1/amodr)/2
a3          tablei      a1ndx, 3, 1             ;lookup tbl in f3, normal index
ao1         poscil      a1, apch, 2             ;cosine
a4          =           exp(-0.5*a3+ao1)
ao2         poscil      a2*apch2, apch2, 2        ;cosine
aoutl       poscil      aamp*a4, ao2+apch*(ashift), 1 ;fnl outleft
aoutr       poscil      aamp*a4, ao2+apch/(ashift), 1 ;fnl outright
xout aoutl, aoutr
 endop

 opcode placeY, a[], ai
ain, iYdist xin ;regular mono input
arro[] init 4 ;ambisonic B format output
aW, aX, aY, aZ spat3di ain, iYdist, 0, 0, 0.3, -1, 3 ;B-format 4-chan out
arro[0] = aW
arro[1] = aX
arro[2] = aY
arro[3] = aZ
xout arro
 endop

 instr       33        ;FM synth sound. Code copied from "Xanadu" (Kung)
ishift      =           .00666667               ;shift it 8/1200.
ipch        =           cpspch(p5)              ;convert parameter 5 to cps.
ioct        =           octpch(p5)              ;convert parameter 5 to oct.
aadsr       linsegr     0, p3/3, 1.0, p3/3, 1.0, p3/3, 0 ;ADSR envelope
amodi       linseg      0, p3/3, 5, p3/3, 3, p3/3, 0 ;ADSR envelope for I
amodr       linseg      p6, p3, p7              ;r moves from p6->p7 in p3 sec.
a1          =           amodi*(amodr-1/amodr)/2
a1ndx       =           abs(a1*2/20)            ;a1*2 is normalized from 0-1.
a2          =           amodi*(amodr+1/amodr)/2
a3          tablei      a1ndx, 3, 1             ;lookup tbl in f3, normal index
ao1         poscil      a1, ipch, 2             ;cosine
a4          =           exp(-0.5*a3+ao1)
ao2         poscil      a2*ipch, ipch, 2        ;cosine
aoutl       poscil      10000*aadsr*a4, ao2+cpsoct(ioct), 1 ;fnl outleft
aoutr       poscil      10000*aadsr*a4, ao2+cpsoct(ioct), 1 ;fnl outright
            zawm        aoutl, 0
            endin

 instr 65
ares    zar 0
        zacl 0, 0
idistY  = 20
iseg1	=p3-0.05
iseg2	=0.05
iang1	=p4*gipi;	
iang2	=p5*gipi
ang     linseg iang1, p3/4, iang2, p3/4, iang1, p3/4, iang2, p3/4, iang1
        printk 0.25, k(ang)
arr1[]  placeY ares, idistY
arr2[]  FOArtt_a arr1, $TIL, ang
aL, aR  bformdec1 1, arr2[0], arr2[1], arr2[2], arr2[3]
        outs aL, aR
 endin




</CsInstruments>

<CsScore>

#define		ROT	#0#	;rotate, tilt, tumble
#define		TIL	#1#
#define		TUM	#2#
#define		ZOOM	#0#	;types of transforms
#define		FOCUS	#1#
#define		PUSH	#2#
#define		PRESS	#3#

;   The Function Tables
/*    These tables are required for the FM_pad opcode. Do not change #s      */
f1 0 65537  10 1      ;sine wave
f2 0 65537  11 1      ;cosine wave
f3 0 65537 -12 20.0  ;unscaled ln(I(x)) from 0 to 20.0

;   -------------------
;b 5

i33 0 36 0 7.06 2.0 0.2  ;F#
i33 . . . 8.01 . .   ;C# above
i33 . . . 8.06 . .   ;F# octave above 1st one
i33 . . . 8.10 . .   ;Bb next one up
i33 . . . 8.11 . .   ;B
i33 . . . 9.04 . .   ;E

i65 0 48 0 2
</CsScore>
</CsoundSynthesizer>    
