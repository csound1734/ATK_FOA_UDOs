/*****************************
 * an example ambisonics
 * decoder file. pass the name
 * of a 4-channel (WXYZ) B-
 * format file like this:
 * —smacro:FILEI=recording.wav
 * There are three decoders:
 *  -Instr 1: bformdec1.
 *    Csound’s “improved”
 *    decoder opcode.
 *  -Instr 2: ambi_dec_inph
 *    Just plain decoding,
 *    now using a decoder udo
 *    from a different source
 *  -Instr 3: experimental
 *    Used the same decoder
 *    as Instr 2 but adds one
 *    of the FOA opcodes to
 *    transform soundfield 
 ****************************/


<CsoundSynthesizer>
<CsOptions>
</CsOptions>
; ==============================================
<CsInstruments>

sr	=	48000
ksmps	=	512
nchnls	=	2 ;decodes from a 4-channel B-format input to stereo
0dbfs	=	1

giAmbiFn = 101

zakinit 25, 25

#include "FOA_ATK_Transforms.udo"
#include "ambisonicambi/ambisonics_udos.txt"

/***************************/
/* csound built-in decoder */
/***************************/
 instr 1	
arri[] init 4   ;FOR INPUT
arri diskin2 p4 ;READ FILE IN
/* NEXT LINE DOES DECODING*/
aL, aR bformdec1 1, arri[0], arri[1], arri[2], arri[3]
outs aL, aR     ;WRITE OUTPUT
 endin

/**********************/
/* Zurich decoder udo */
/**********************/
 instr 2
arri[] init 4    ;FOR INPUT
arri diskin2 p4  ;READ FILE IN
zacl 0, 3        ;CLEAR ACCUM
zawm arri[0], 0  ;ACCUM W CHN
zawm arri[1], 1  ;ACCUM X CHN
zawm arri[2], 2  ;ACCUM Y CHN
zawm arri[3], 3  ;ACCUM Z CHN
/* NEXT LINE DOES DECODING */
aL, aR ambi_dec_inph 1, giAmbiFn
outs aL, aR      ;WRITE OUTPUT
 endin

/****************/
/* EXPERIMENTAL */
/****************/
 instr 3
arri1[] init 4
arri[] init 4
arri1 diskin2 p4
/* NEXT LINE LFO AZIMUTH */
aAzimuth = $M_PI*phasor:a(1/11)
aTheta   = .5*$M_PI*oscil:a(1,1/4)
printk .5, k(aAzimuth)
/* NEXT LINE APPLY TRNSFRM */
arri FOAzoom_a     arri1, aAzimuth, a($M_PI/2), -a($M_PI/3)
zacl 0, 3        ;ZERO ACCUM
zawm arri[0], 0 ;ACCUM W CHN
zawm arri[1], 1 ;ACCUM X CHN
zawm arri[2], 2 ;ACCUM Y CHN
zawm arri[3], 3 ;ACCUM Z CHN
/* NEXT LINE DOES DECODING */
aL, aR ambi_dec_inph 1, giAmbiFn
outs aL*db(0), aR*db(0)
 endin

 instr 4	
arri[] init 4   ;FOR INPUT
arrs[] init 2   ;FOR OUTPUT
arri diskin2 p4, .5 ;READ FILE IN
/* NEXT LINE DOES DECODING*/
arrs bformdec2 2, arri
outs arrs[0], arrs[1];WRITE OUTPUT
 endin

 instr 5	
arri[] init 4   ;FOR INPUT
arr1[] init 4   ;FOR TRANSFORM
arr2[] init 4   ;2ND TRANSFORM
arrs[] init 2   ;FOR OUTPUT
arri diskin2 p4, 1 ;READ FILE IN
/* NEXT LINE LFO AZIMUTH */
kAzimuth jitter $M_PI/2, 1/10, 1/5
aAzimuth upsamp kAzimuth
printk .5, kAzimuth, 10
/* NEXT LINE LFO ELEVATION */
kElevation jitter $M_PI/4, 1/10, 1/6
aElevation = kElevation + $M_PI/4
printk .5, kElevation, 20
/* NEXT LINE APPLY TRNSFRM */
;arr1 FOArtt_a      arri, $TIL, aAzimuth
arr2 FOAzoom_a     arri, aAzimuth, a(0), -a($M_PI/3)
/* NEXT LINE DOES DECODING*/
arrs bformdec2 21, arr2, 0, .5, 400, 0, "hrtf/hrtf-48000-left.dat", "hrtf/hrtf-48000-right.dat"
outs arrs[0], arrs[1];WRITE OUTPUT
 endin
</CsInstruments>
; ==============================================
<CsScore>
f 101 0 64 -2 0  0 0   90 0   0 90   0 0  0 0  0 0 ;copied directly from source
;    giAmbiFn = 101

i 5 0 z "$FILEI"

</CsScore>
</CsoundSynthesizer>

