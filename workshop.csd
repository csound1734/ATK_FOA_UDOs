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

 instr 1	
arri[] init 4
arri diskin2 p4
aL, aR bformdec1 1, arri[0], arri[1], arri[2], arri[3] ;WXYZ - to - LR decoder (-+ 90 MS)
outs aL, aR
 endin

 instr 2
arri[] init 4
arri diskin2 p4
zacl 0, 3
zawm arri[0], 0
zawm arri[1], 1
zawm arri[2], 2
zawm arri[3], 3
aL, aR ambi_dec_inph 1, giAmbiFn
outs aL, aR
 endin

 instr 3
arri1[] init 4
arri[] init 4
arri1 diskin2 p4, 0.5, 60
aAzimuth oscil $M_PI, 1/8 ;sweeping azimuth for FOAfocus_a transform
printk 0.15, k(aAzimuth), 20
arri FOAfocus_a arri1, aAzimuth, a($M_PI/7), a($M_PI*.5)
zacl 0, 3
zawm arri1[0], 0
zawm arri1[1], 1
zawm arri1[2], 2
zawm arri1[3], 3
aL, aR ambi_dec_inph 1, giAmbiFn
outs aL*db(0), aR*db(0)
 endin


</CsInstruments>
; ==============================================
<CsScore>
f 101 0 64 -2 0  0 0   90 0   0 90   0 0  0 0  0 0 ;copied directly from source
;    giAmbiFn = 101

i 3 0 z "$FILEI"

</CsScore>
</CsoundSynthesizer>

