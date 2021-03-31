<CsoundSynthesizer>
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

<CsOptions>

</CsOptions>

<CsInstruments>

sr 	= 44100
ksmps 	= 32
nchnls 	= 4		;FOA signals are four, don't change this
0dbfs	= 1

gSfilename 	= "Stravinsky.wav"	;input FOA B-Format file for testing 
;source http://ambisonia.com/Members/ajh/ambisonicfile.2006-09-06.2014008935/

#include "FOA_ATK_Transforms.udo" ; a file that contains much of the FOA_ATK code

;Testing instruments
/**********************************************************/
;;;;;;;;;;;;;;;;;;;;;;;;;
instr rtt_a	/*test the a-rate version of the BF1rtt*/

iamp	=p4		;amplitude scaling
iax	=p5		;axis for the rotation (0=rotate, 1=tilt, 2 tumble)
iang1	=p6*gipi;	
iang2	=p7*gipi
iseg1	=p3-0.05
iseg2	=0.05
arra[]	init nchnls	;input/output FOA audio signals array
	;please see comments in file FOA_ATK_Transforms.udo of the temporary (not-idel) use of gi_chnls4. It's value is 4.
aamp		linseg iamp, iseg1,iamp, iseg2,0 
arra		diskin2	gSfilename, 1, 0,0,0,8,0
/*angle of rotation changes at a-rate*/
ang		line		iang1, p3, iang2
arra		FOArtt_a 	arra, iax, ang

	outq	arra[0]*aamp, arra[1]*aamp, arra[2]*aamp, arra[3]*aamp 
endin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr directO_a	/*test the a-rate version of the FOAdirectO_a UDO*/ 

iamp	=p4		;amplitude scaling
itheta1	=p5*gipi;	;directivity strength 1 (must lie between 0 and PI/2)
itheta2	=p6*gipi	;directivity strength 2 (ditto...)
id1	=p3*.2
id2	=p3*.6
iseg1	=p3-0.05
iseg2	=0.05
arra[]	init nchnls	;input/output FOA audio signals array
	;please see comments in file FOA_ATK_Transforms.udo of the temporary (not-idel) use of gi_chnls4. It's value is 4.
aamp	linseg iamp, iseg1,iamp, iseg2,0
arra	diskin2	gSfilename, 1, 0,0,0,8,0
/*the strength of directivity changes at a-rate*/
atheta	linseg		itheta1, id1, itheta1, id2, itheta2, id1, itheta2
arra	FOAdirectO_a 	arra, atheta

	outq	arra[0]*aamp, arra[1]*aamp, arra[2]*aamp, arra[3]*aamp 	
endin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr direct_a	/*test the a-rate version of the FOAdirect_a UDO*/ 

iamp	=p4		;amplitude scaling
iaz	=p5*gipi	;azimuth of the arbitrary axis for directivity
iel	=p6*gipi	;elevation of the arbitrary axis for directivity
itheta1	=p7*gipi;	;directivity strength 1 (must lie between PI/2 and -PI/2)
itheta2	=p8*gipi	;directivity strength 2 (ditto...)
id1	=p3*.2
id2	=p3*.6
iseg1	=p3-0.05
iseg2	=0.05
arra[]	init nchnls	;input/output FOA audio signals array
	;please see comments in file FOA_ATK_Transforms.udo of the temporary (not-idel) use of gi_chnls4. It's value is 4.
;here we don't change the direction angles, but we need to convert them to audio-rate
;because the UDO requires that
aaz	=iaz
ael	=iel
aamp	linseg iamp, iseg1,iamp, iseg2,0
arra	diskin2	gSfilename, 1, 0,0,0,8,0
/*strength of directivity changes at a-rate*/
atheta	linseg		itheta1, id1, itheta1, id2, itheta2, id1, itheta2
arra	FOAdirect_a 	arra, aaz, ael, atheta

	outq	arra[0]*aamp, arra[1]*aamp, arra[2]*aamp, arra[3]*aamp	
endin
;;;;;;;;;;;;;;;;;;;;;;;;;
instr dominate_a	/*test the a-rate version of the FOAdominate_a UDO*/ 

iamp	=p4		;amplitude scaling
iaz	=p5*gipi	;azimuth of the arbitrary axis for dominance
iel	=p6*gipi	;elevation of the arbitrary axis for dominance
igain1	=p7		;dominance strength 1 
igain2	=p8		;dominance strength 2 
id1	=p3*.2
id2	=p3*.6
iseg1	=p3-0.05
iseg2	=0.05
arra[]	init nchnls	;input/output FOA audio signals array
	;please see comments in file FOA_ATK_Transforms.udo of the temporary (not-idel) use of gi_chnls4. It's value is 4.
;here we don't change the direction angles, but we need to convert them to audio-rate
;because the UDO requires that
aaz	=iaz
ael	=iel
aamp	linseg iamp, iseg1,iamp, iseg2,0
arra	diskin2	gSfilename, 1, 0,0,0,8,0
/*strength of dominance changes at a-rate*/
again	linseg		igain1, id1, igain1, id2, igain2, id1, igain2
arra	FOAdominate_a 	arra, aaz, ael, again

	outq	arra[0]*aamp, arra[1]*aamp, arra[2]*aamp, arra[3]*aamp
endin
;;;;;;;;;;;;;;;;;;;;;;;;;
/*test the a-rate version of the FOAzoom_a, FOAfocus_a 
FOApush_a and FOApress_a UDOs
*/ 
instr zfpp_a

iamp	=p4		;amplitude scaling
iaz	=p5*gipi	;azimuth of the arbitrary axis for zoom
iel	=p6*gipi	;elevation of the arbitrary axis for zoom
itheta1	=p7*gipi	;zoom strength 1 
itheta2	=p8*gipi	;zoom strength 2
iwhich	=p9		;which transform to apply (zoom=0, focus=1, push=2, press=3)
print	iwhich

id1	=p3*.2
id2	=p3*.6
iseg1	=p3-0.05
iseg2	=0.05
arra[]	init nchnls	;input/output FOA audio signals array
	;please see comments in file FOA_ATK_Transforms.udo of the temporary (not-idel) use of gi_chnls4. It's value is 4.
;here we don't change the direction angles, but we need to convert them to audio-rate
;because the UDO requires that
aaz	=iaz
ael	=iel
aamp	linseg iamp, iseg1,iamp, iseg2,0
arra	diskin2	gSfilename, 1, 0,0,0,8,0
/*strength of zoom changes at a-rate*/
atheta	linseg		itheta1, id1, itheta1, id2, itheta2, id1, itheta2
/*process according the selected transform*/
if(iwhich==$ZOOM) then
	arra	FOAzoom_a arra, aaz, ael, atheta
elseif(iwhich==$FOCUS) then
	arra	FOAfocus_a arra, aaz, ael, atheta
elseif(iwhich==$PUSH) then
	arra	FOApush_a arra, aaz, ael, atheta
elseif(iwhich==$PRESS) then
	arra	FOApress_a arra, aaz, ael, atheta
endif
	outq	arra[0]*aamp, arra[1]*aamp, arra[2]*aamp, arra[3]*aamp
endin


</CsInstruments>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
<CsScore>
;some useful macros
#define		ROT	#0#	;rotate, tilt, tumble
#define		TIL	#1#
#define		TUM	#2#

#define		ZOOM	#0#	;types of transforms
#define		FOCUS	#1#
#define		PUSH	#2#
#define		PRESS	#3#

#define		D1	#5.3#	;audio files durations
#define		D2	#10.845#

;UNCOMMENT EACH BLOCK TO TEST EACH TRANSFORM
/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FOArtt_a test
;Here the angle is delivered in normalized values from 0 (0 radians) to 1 (PI) and
;is converted to radians by the instrument called.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			st	dur	amp	axis	ang1	ang2
i	"rtt_a"		0	$D2	.707	$TUM	0	0	;unchanged
i	"rtt_a"		+	$D2	.	$ROT	0	2	;rotation
i	"rtt_a"		+	$D2	.	$TIL	0	2	;tilting
i	"rtt_a"		+	$D2	.	$TUM	0	2	;tumbling

/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FOAdirectO_a tests
;warning: directivity strength must lie between 0 and PI/2
;Here the angle is delivered in normalized values from 0 (0 radians) to 1 (PI) and
;is converted to radians by the instrument called.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			st	dur	amp	theta1	theta2
i	"directO_a"	0	$D2	.701	0	0	;unchanged
;			st	dur	amp	theta1	ang2
i	"directO_a"	+	$D2	.701	0.5	.5	;only W signal
;			st	dur	amp	theta1	ang2
i	"directO_a"	+	$D2	.701	0	.5	;transition from original soundfield to mono
*/
/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FOAdirect_a tests
;warning: directivity strength must lie between -PI/2 and PI/2
;Here the angle is delivered in normalized values from 0 (0 radians) to 1 (PI) and
;is converted to radians by the instrument called.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;			st	dur	amp	azim	elev	theta1	theta2
i	"direct_a"	0	$D2	.701	0.	0.	0	0	;unchanged
;			st	dur	amp	azim	elev	theta1	ang2
i	"direct_a"	+	$D2	.701	0.	.	.5	-.5	;aiming Y
;			st	dur	amp	azim	elev	theta1	theta2
i	"direct_a"	+	$D2	.701	0.5	.	.5	-.5	;aiming Y
;			st	dur	amp	azim	elev	theta1	theta2
i	"direct_a"	+	$D2	.701	0.	.5	.5	-.5	;aiming Z
*/
/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FOAdominance_a tests
;warning: dominance gain must be in dBfs 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			st	dur	amp	azim	elev	gain1	gain2
i	"dominate_a"	0	$D2	1	0.	0.	0	0	;unchanged
;			st	dur	amp	azim	elev	gain1	gain2
i	"dominate_a"	+	$D2	0.3	0.	0.	12	-12	;aiming X 
;			st	dur	amp	azim	elev	gain1	gain2
i	"dominate_a"	+	$D2	0.3	0.5	0.	12	-12	;aiming Y
;			st	dur	amp	azim	elev	gain1	gain2
i	"dominate_a"	+	$D2	0.3	0.	0.5	12	-12	;aiming Z
*/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FOAzoom_a tests
;warning: zoom strength must lie between -PI/2 and PI/2 
;Here the angle is delivered in normalized values from 0 (0 radians) to 1 (PI) and
;is converted to radians by the instrument called.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	0	$D2	.45	0.0	0.0	0	0	$ZOOM	;unchanged
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	+	$D2	.	.	.	.5	-.5	$ZOOM    ;Aiming X
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	+	$D2	.	0.5	0.0	.	-.5	$ZOOM    ;Aiming Y
;			st	dur	amp	azim	elev	theta1	theta2	transform	
i	"zfpp_a"	+	$D2	.	0.0	0.5	.	-.5	$ZOOM    ;Aiming Z

/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FOAfocus_a tests
;warning: focus strength must lie between -PI/2 and PI/2 
;Here the angle is delivered in normalized values from 0 (0 radians) to 1 (PI) and
;is converted to radians by the instrument called.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	0	$D2	.8	0.0	0.0	0	0	$FOCUS	;unchanged
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	+	$D2	.	.	.	.5	-.5	$FOCUS    ;Aiming X
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	+	$D2	.	0.5	0.0	.	-.5	$FOCUS    ;Aiming Y
;			st	dur	amp	azim	elev	theta1	theta2	transform	
i	"zfpp_a"	+	$D2	.	0.0	0.5	.	-.5	$FOCUS    ;Aiming Z
*/
/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FOApush_a tests
;warning: push strength must lie between -PI/2 and PI/2 
;Here the angle is delivered in normalized values from 0 (0 radians) to 1 (PI) and
;is converted to radians by the instrument called.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	0	$D2	.707	0.0	0.0	0	0	$PUSH	;unchanged
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	+	$D2	.	.	.	.5	-.5	$PUSH    ;Aiming X
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	+	$D2	.	0.5	0.0	.	-.5	$PUSH    ;Aiming Y
;			st	dur	amp	azim	elev	theta1	theta2	transform	
i	"zfpp_a"	+	$D2	.	0.0	0.5	.	-.5	$PUSH    ;Aiming Z
*/
/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FOApress_a tests
;warning: press strength must lie between -PI/2 and PI/2 
;Here the angle is delivered in normalized values from 0 (0 radians) to 1 (PI) and
;is converted to radians by the instrument called.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	0	$D2	.707	0.0	0.0	0	0	$PRESS	;unchanged
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	+	$D2	.	.	.	.5	-.5	$PRESS    ;Aiming X
;			st	dur	amp	azim	elev	theta1	theta2	transform
i	"zfpp_a"	+	$D2	.	0.5	0.0	.	-.5	$PRESS    ;Aiming Y
;			st	dur	amp	azim	elev	theta1	theta2	transform	
i	"zfpp_a"	+	$D2	.	0.0	0.5	.	-.5	$PRESS    ;Aiming Z
*/
e
</CsScore>


</CsoundSynthesizer>
