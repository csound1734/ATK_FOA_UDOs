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
ksmps	=	1
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

</CsInstruments>
; ==============================================
<CsScore>
f 101 0 64 -2 0  0 0   90 0   0 90   0 0  0 0  0 0 ;copied directly from source
;    giAmbiFn = 101

i 4 0 z "$FILEI"

</CsScore>
</CsoundSynthesizer>

