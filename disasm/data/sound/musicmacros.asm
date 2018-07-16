

channel_end	macro
	db 0FFh
	db 0
	db 0
	endm
	
	
ymInst	macro arg0
	db 0FEh
	db arg0
	endm
	
ymVol	macro arg0
	db 0FDh
	db arg0
	endm
	
release	macro arg0
	db 0FCh
	db arg0
	endm
	
ymSustain	macro 
	db 0FCh
	db 080h
	endm
	
ymSlide	macro arg0
	db 0FCh
	db arg0+080h
	endm
	
ymStopSlide	macro 
	db 0FCh
	db 0FFh
	endm
	
vibrato	macro arg0
	db 0FBh
	db arg0
	endm	
	
ymStereo	macro arg0
	db 0FAh
	db arg0
	endm	
	
shifting	macro arg0
	db 0F9h
	db arg0
	endm		
	
mainLoopStart	macro
	db 0F8h
	db 0
	endm
	
mainLoopEnd	macro
	db 0F8h
	db 0A1h
	endm
	
repeatStart	macro
	db 0F8h
	db 020h
	endm
	
repeatEnd	macro
	db 0F8h
	db 0A0h
	endm
	
repeatSection1Start	macro
	db 0F8h
	db 040h
	endm
	
repeatSection2Start	macro
	db 0F8h
	db 060h
	endm
	
repeatSection3Start	macro
	db 0F8h
	db 080h
	endm
	
countedLoopEnd	macro
	db 0F8h
	db 0E0h
	endm	
	
countedLoopStart macro arg0
	db 0F8h
	db arg0+0C0h
	endm	
	
length	macro arg0
	db 0F0h
	db arg0
	endm	
	
silence	macro
	db 070h
	endm	
	
sampleL	macro arg0,arg1
	db arg0+080h
	db arg1
	endm	
	
noteL	macro arg0,arg1
	db arg0+080h
	db arg1
	endm	
	
psgNoteL	macro arg0,arg1
	db arg0+080h-9
	db arg1
	endm	
	
sample	macro arg0
	db arg0
	endm	
	
note	macro arg0
	db arg0
	endm
		
psgNote	macro arg0
	db arg0-9
	endm	
	
psgInst	macro arg0
	db 0FDh
	db arg0
	endm
	
	
ymTimer	macro arg0
	db 0FAh
	db arg0
	endm		