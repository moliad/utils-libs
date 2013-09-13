REBOL [
	; -- Core Header attributes --
	title: "script/application handling tools."
	file: %utils-script.r
	version: 1.0.1
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: "Collection of generic, re-useable functions"
	web: http://www.revault.org/modules/utils-script.rmrk
	source-encoding: "Windows-1252"
	note: {Steel Library Manager (SLiM) is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-script
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-script.r

	; -- Licensing details  --
	copyright: "Copyright © 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2013 Maxim Olivier-Adlhoch

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
	history: {
		v1.0.1 - 2013-09-12
			-added source-entab}
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
; test-enter-slim 'utils-script
;
;--------------------------------------


slim/register [


	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------

	;-----------------
	;-     get-application-title()
	;-----------------
	get-application-title: func [
		/local script parent
	][
		parent: system/script
		until [
			;print parent/header
			script: parent
			parent: script/parent
			any [
				none? parent
				none? parent/header
			]
		]
		script/title
	]   
			


	
	
	;--------------------------
	;-     source-entab()
	;--------------------------
	; purpose:  similar to 'ENTAB, but only at the head of the lines... not within.
	;
	; inputs:   string to entab
	;
	; returns:  entabed string
	;
	; notes:    
	;           -if the first column contains a semi-colon (';') we should entab until the non-space character.
	;
	; bugs:     -if there is a multi-line string with spaces at the begining, it will be entabbed"
	;
	; tests:    
	;
	;   test [ source-entab utils-string.r] [ von  (source-entab 4 {     this is tabbed^/;   this is not^/  ^-    ;   this is.})   =  {  ^-this is tabbed;^/^-this is too^/^-;   folowing tab is not.} ]
	;--------------------------
	source-entab: funcl [
		tab-length [ none! integer! ]
		source [string!]
	][
		vin "source-entab()"
		
		default tab-length 4
		result: make string! to-integer ( 1.25 * length? source )
		
		;v?? source
		;vprint "============================================>>>>>>>>>>>>>"
		end-rule: copy/deep [ to end ( end-rule: [thru end] ) ]
		space-rule: [
			( i: 0 )
			any [
				  " "     ( i: i + 1 )
				| "^-"  ( i: i +  tab-length - ( i // tab-length ) )
			]
		]       
		
		ws: charset " ^-"
		parse/all source [
			some [
				here:
				space-rule 
				[
					copy txt [ thru "^/" ]
					| 
					copy txt end-rule
				]
				
				there:
				(
					;vprint "--"
					;vprobe i
					insert/dup tail result "^-" to-integer (i / tab-length)
					insert/dup tail result " " i // tab-length
					append result any [txt ""] ; prevent adding a none at the end of all results!
				)
			]
		]
		
		;vprint "<<<<<<<<<<<<============================================"
		
		;print result
		;probe result
		
		vout
		result
	]

			
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

