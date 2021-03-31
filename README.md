# Ambisonic experimentation repo for Csound

## Ambisonic sound fields

## More about the opcode library used 
FOA ATK Transforms.
By Oscar Pablo Di Liscia.
<br>Research Program STSEAS, Escuela Universitaria de Musica, UNQ, Argentina. 
PICT 2015-2604 FONCyT Argentina
 
Csound UDOs for First Order B-Format Ambisonic Transforms.
Based on the Ambisonics Toolkit (ATK) for Super Collider (Joseph Anderson, John Mc Crea, Juan Pampin, Josh Parmenter, Daniel Peterson).
The original SC code can be obtained [here:](https://github.com/ambisonictoolkit/atk-sc3/blob/master/Classes/ATKMatrix.sc#L1260)
For an explanation of the transforms, as well as plots of almost all of these, [see:](http://www.ambisonictoolkit.net/documentation/supercollider/)
 
The current available UDOs Tranforms are:
 
A-Full soundfield transforms UDOs
(where the transform is applied to the complete soundfield)
 
* A.1-`FOArtt_a` rotates, tilts, tumbles, a-rate

* A.2-`FOAdirectO_a	` apply directivity from unchanged soundfield to mono, a-rate
	todo:
* A.3-`FOAmirrorO_a` mirrors the soundfield towards a specified direction, a-rate
 
B-"Aimed" transforms UDOs
(where the user specifies the direction (azimuth, elevation) towards which the transform will be performed)
 
* B.1-`FOAdirect_a` apply directivity towards a specified direction, a-rate
* B.2-`FOAdominate_a` dominates the soundfield towards a specified direction, a-rate
* B.3-`FOAzoom_a` zooms the soundfield towards a specified direction, a-rate
* B.4-`FOAfocus_a` focus the soundfield towards a specified direction, a-rate
* B.5-`FOApush_a` pushes the soundfield towards a specified direction, a-rate	
* B.6-`FOApress_a` presses the soundfield towards a specified direction, a-rate
	todo:
* B.7-`FOAmirror_a` mirrors the soundfield towards a specified direction, a-rate
 
Check each transform comments in order to see the type, range and meaning of their arguments.
 
NB: The author is aware that the use of matrices holding the transforms coefficients
may result in a more neat and readable code. 
However, because of performance reasons in the Csound environment, the code was written using single 
variables for the transforms coefficients.

## Csound UDOs

### FOA_ATK (1.)

`ao[] FOArtt_a ai[], iX, iG`
<br>
`ao[] FOAdirect0_a ai[], aT`
<br>
`ao[] FOAdirect_a ai[], aZ, aL, aT`
<br>
`ao[] FOAdominate_a ai[], aZ, aL, aA`
<br>
`ao[] FOAfocus_a ai[], aZ, aL, aT`
<br>
`ao[] FOAzoom_a ai[], aZ, aL, aT`
<br>


### ambisonicambi/ (2.)

## Other

* Stravinsky.wav B-format sound recording usually read from disk using the `diskin` opcode