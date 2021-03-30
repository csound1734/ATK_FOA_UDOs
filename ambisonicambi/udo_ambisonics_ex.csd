<CsoundSynthesizer>
<CsInstruments>

sr      =  44100
ksmps   =  100
nchnls  =  8
0dbfs 	 = 1

zakinit 81,1	

#include "ambisonics_udos.txt"
#include "ambisonics_utilities.txt"

instr 1

asnd	buzz		p4,p5,50,1
kx   	line		p7,p3,p8		
ky		line		p9,p3,p10		
kz		line		p11,p3,p12	
kaz,kel,kdist	xyz_to_aed kx,ky,kz
aabs 	Absorb		asnd,kdist
adop	Doppler	.2*aabs,kdist
k0		ambi_enc_dist		adop,5,kaz,kel,kdist 
	
endin

instr 17

a1,a2,a3,a4,a5,a6,a7,a8 	ambi_dec_inph		5,17
;k0		ambi_write_B	"B_form_test1.wav",5,14

		outc			a1,a2,a3,a4,a5,a6,a7,a8
		zacl 	0,80
		
endin

</CsInstruments>
<CsScore>
f1 0 32768 10 1
;f17 0 64 -2 0  0 0  1.5707 0  3.141593 0  0 1.5707  0 -1.5707 0 0	0 0 
;f17 0 64 -2 0  0 0  0 .5  0  1  0  1.5  0  2 0  0 0	0 0 
f17 0 64 -2 0 0 0 0.79 0  1.57 0   2.36 0 3.14 0 3.93 0 4.71 0 5.5 0 0 

;			amp	 	f 		0		x1	 x2  y1  y2  z1  z2
i1 0 5 	.6  		200 	0 	10	-10	 0	  0		0	0
i17 0 5
</CsScore>
</CsoundSynthesizer>















<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>234</r>
  <g>255</g>
  <b>246</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="420" y="293" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
