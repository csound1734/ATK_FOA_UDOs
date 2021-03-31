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

zakinit 256, 256
#include "ambisonicambi/ambisonics_udos.txt"

 instr 1	
arri[] diskin p4
aL, aR bformdec1 1, arri[0], arri[1], arri[2], arri[3] ;WXYZ - to - LR decoder (-+ 90 MS)
outs aL, aR
 endin

 instr 2
arri[] diskin p4
zacl 0, 3
zawm arri[0], 0
zawm arri[1], 1
zawm arri[2], 2
zawm arri[3], 3
aL, aR ambi_dec_inph 1, giAmbiFn
outs aL, aR
 endin

</CsInstruments>
; ==============================================
<CsScore>
f 101 0 64 -2 0  0 0   90 0   0 90   0 0  0 0  0 0 ;copied directly from source
;    giAmbiFn = 101

i 2 0 z "$FILEI"

</CsScore>
</CsoundSynthesizer>

