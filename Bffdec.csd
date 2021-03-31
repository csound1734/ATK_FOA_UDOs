<CsoundSynthesizer>
<CsOptions>
</CsOptions>
; ==============================================
<CsInstruments>

sr	=	48000
ksmps	=	1
nchnls	=	2 ;decodes from a 4-channel B-format input to stereo
0dbfs	=	1

#include "ambisonicambi/ambisonics_udos.txt"

instr 1	
arri[] diskin p4
aL, aR bformdec1 1, arri[0], arri[1], arri[2], arri[3] ;WXYZ - to - LR decoder (-+ 90 MS)
outs aL, aR
endin

</CsInstruments>
; ==============================================
<CsScore>

i 1 0 z "$FILEI"

</CsScore>
</CsoundSynthesizer>

