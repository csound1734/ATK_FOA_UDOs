<CsoundSynthesizer>
<CsOptions>
;-o dac
</CsOptions>
<CsInstruments>

sr      =  44100
ksmps   =  10
nchnls  =  8
0dbfs 	 = 1

#include "AEP_udos.txt"
#include "ambisonics_utilities.txt"

instr 1

ain		buzz		p4,p5,40,1
korder	init		7
kt		line		0,p3,p3
kx		=			14*cos(0.61803*kt)		; Lissajous 
ky		=			14*sin(kt) 		
kz		init		0
kdist	Dist		kx,ky
aabs 	Absorb		ain,kdist
adop	Doppler	.2*aabs,kdist
a1,a2,a3,a4,a5,a6,a7,a8 AEP adop,korder,17,kx,ky,kz
		outc			a1,a2,a3,a4,a5,a6,a7,a8
endin

</CsInstruments>
<CsScore>
f1 0 32768 10 1
;fuction for speaker positions
;GEN -2, parameters: max_speaker_distance, xs1,ys1,zs1,xs2,ys2,zs2,...
;octahedron
;f17 0 32 -2 1 1 0 0  -1 0 0  0 1 0  0 -1 0  0 0 1  0 0 -1 
;cube
;f17 0 32 -2 1,732 1 1 1  1 1 -1  1 -1 1  -1 1 1   
;octagon

f17 0 32 -2 1 0.924 -0.383 0 0.924 0.383 0 0.383 0.924 0 -0.383 0.924 0 -0.924 0.383 0 -0.924 -0.383 0 -0.383 -0.924 0 0.383 -0.924 0

i1 0 30 .8 300

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
