rebol [
	; -- Core Header attributes --
	title: "command-line and shell extensions using rebol"
	file: %utils-process-win32.r
	version: 0.0.1
	date: 30-Oct-2018/21:24:43
	author: "Maxim Olivier-Adlhoch"
	purpose: "iii"
	web: http://www.revault.org/modules/utils-process-win32.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-process-win32
	slim-version: 1.3.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-process-win32.r

	; -- Licensing details  --
	copyright: "Copyright © 2018 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2018 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: ""
	;-  \ history

	;-  / documentation
	documentation: {
		Documentation goes here
	}
	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-process-win32
;
;--------------------------------------

slim/register [

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     PARSE CHARSET
	;
	;-----------------------------------------------------------------------------------------------------------

	=space=: charset [ #" " #"^(A0)" #"^(8D)"   #"^(8F)"   #"^(90)" ]
	=spaces=: [some [=space=]]
	=spaces?=: [ any [=space=]]
	
	=blanks=: [any =space=]
	=tab=: charset "^-"
	=tabs=: [some =tab=]
	=tabs?=: [any =tab=]
	....: =tab=

	=spacer=:   union =space= =tab=
	=spacers=:  [some =spacer=]
	=spacers?=: [any =spacer=]
	
	=newline=: charset crlf
	=newlines=: [ some =newline= ]
	
	=eol=: [ opt cr  lf | end ]
	=eols=: [ some =eol= ]
	=not-eol=: complement =newline= ; TO DO should build a real complement to =eol=
	!not-eol!: [.flow-here: =not-eol= :.flow-here]

	=whitespace=: union =spacer= =newline=
	=whitespaces=: [some =whitespace=]
	=whitespaces?=: [any =whitespace=]


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     CONTENT RULES
	;
	;-----------------------------------------------------------------------------------------------------------
	=digit=: charset "0123456789"
	=alpha=: charset [ #"a" - #"z" #"A" - #"Z" ]
	=digits=: [some =digit=]
	=alphanumeric=: union =alpha= =digit=


	=uppercase-letter=: charset "ABCDEFGHIJKLMNOPQRSTUVWXYZ¡…Õ”⁄›¿»Ã“Ÿ¬ Œ‘€ƒÀœ÷‹ü—’√≈«å∆äéﬂ" ; probably should be expanded to other spanish chars
	=lowercase-letter=: charset "abcdefghijklmnopqrstuvwxyz·ÈÌÛ˙˝‡ËÏÚ˘‚ÍÓÙ˚‰ÎÔˆ¸ˇÒı„ÂÁúÊöû" ; probably should be expanded to other spanish chars
	=letter=: union =uppercase-letter= =lowercase-letter=
	=letters=: [some  =letter= ]


	=task-name=: complement =spacer=


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         kill-process()
	;--------------------------
	; purpose:  given a process name or id, will ask the system to kill it.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	kill-process: funcl [
		process [string! integer!] "string is a process name (.exe not required) integer is a PID"
		/tree "Also kill all subtasks"
	][
		vin "kill-process()"
		
		vout
	]


	;--------------------------
	;-         list-processes()
	;--------------------------
	; purpose:  return a simple list of all processes running
	;
	; inputs:   
	;
	; returns:  a block with a list of: [ name pid .mem .user .time .wintitle ]
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	list-processes: func [
		/filter ftext "only list these processes (.exe optional)"
	][
		vin "list-processes()"
		
		unless find ftext ".exe" [
			ftext: join ftext ".exe"
		]
		proc-data: make string! 500'000
		vprint "calling OS task listing function"
		either ftext [
			cmd: rejoin [{tasklist /V /FO list /FI "IMAGENAME eq } ftext {"}]
			call/output/show  cmd proc-data
		][
			call/output/show "tasklist /V /FO list " proc-data
		]
		vprint "OS done, parsing results..."
		;vprobe proc-data
		procs: copy []
		parse/all proc-data [
			some [
				[
					here:
					"Image Name:   "	copy .name to LF LF 
					"PID:          "	copy .pid some =digit= (.pid: to-integer .pid) LF
					"Session Name: "	thru LF
					"Session#:     "	thru LF
					"Mem Usage:    "	copy .mem any [=digit= | #","] =space= [
											  "b" (.mem: to-integer head replace/all .mem "," "")
											| "k" (.mem: 1000 * to-integer head replace/all .mem "," "")
											| "m" (.mem: 1'000'000 * to-integer head replace/all .mem "," "")
											| "g" (.mem: 1'000'000'000.0 * to-integer head replace/all .mem "," "")
										] LF
					"Status:       "	thru LF
					"User Name:    "	copy .user to LF LF
					"CPU Time:     "	copy .time to LF LF (.time: load .time)
					"Window Title: "	[
											  "N/A" (.wintitle: none)
											| copy .wintitle TO LF
										]
										LF
					(
						append procs reduce [
							.name .pid .mem .user .time .wintitle
						]
					)
				]
				| skip
			]
		]
		sort/skip procs 6
		new-line/skip procs true 6
		v?? procs
		vout
		procs
	]


]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

