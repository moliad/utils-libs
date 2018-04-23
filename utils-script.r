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

	slim/open/expose 'utils-strings none [ international-datestring ]


	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;-     FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------


	;-----------------
	;-         get-application-title()
	;-----------------
	get-application-title: funcl [
	][
		parent: system/script
		until [
			script: parent
			parent: script/parent
			any [
				none? parent
				none? parent/header
			]
		]
		all [
			ttl: get in script 'title
			to-string ttl
		]
	]  
	
	 
	;-----------------
	;-         get-application-path()
	;-----------------
	get-application-path: funcl [
	][
		parent: system/script
		until [
			script: parent
			parent: script/parent
			any [
				none? parent
				none? parent/header
			]
		]
		all [
			file? dir: dirize get in script 'path
			copy dir
		]
	]  
	
	 

	
	
	;--------------------------
	;-         source-entab()
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
			


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     HEADER MANIPULATION FUNCS
	;
	;-----------------------------------------------------------------------------------------------------------


	;--------------------------
	;-         get-header-value()
	;--------------------------
	; purpose:  a generic func to get header info, not fast, but effective.
	;--------------------------
	get-header-value: funcl [
		src [file! string! object!]
		attr [word!]
	][
		vin "get-header-value()"

		if file? src [
			src: read src
		]
		
		src-hdr: switch type?/word src [
			object! [src]
			string! [
				first load/header src
			]
		]
		
		unless value: in src-hdr attr [
			to-error rejoin ["source has no '" attr " to get!"]
		]
		value: get value
		v?? value
			
		vout
		value
	]


	;--------------------------
	;-         get-script-version()
	;--------------------------
	; purpose:  a generic func to get header info, not fast, but effective.
	;--------------------------
	get-script-version: funcl [
		src [file! string! object!]
	][
		vin "get-script-version()"

		ver: get-header-value src 'version
		v?? ver
		
		ver: switch/default type?/word ver [
			decimal! [
				to-tuple to-string ver
			]
			integer! [
				1.0.0 * ver
			]
			string! [
				any [
					all [
						tuple? ver: attempt [to-tuple ver]
						ver
					]
					0.0.0
				]
			]
			tuple! [
				ver
			]
		][
			0.0.0
		]
		v?? ver
		vout
		ver
	]


	;--------------------------
	;-         bump-script-version()
	;--------------------------
	; purpose:  automatically find and replace a version value in a header.   
	;
	; notes:    The version MUST exist (though it may not be a valid tuple equivalent value... like none).
	;--------------------------
	bump-script-version: funcl [
		[catch]
		src [file! string! object!]
	][
		throw-on-error [
			vin "bump-script-version()"
			
			if file? src [
				src: read src
			]
			src-version: get-header-value src 'version
			
			src-version: any [
				all [
					tuple? v: attempt [ to-tuple to-string src-version ]
					v
				]
				0.0.0
			]
			
			v?? src-version
;			unless tuple? src-version [
;				to-error "source version is not a tuple or numeric scalar value."
;			]
			
			dest-version: src-version + 0.0.1
			
			v?? dest-version
			
			;-------
			; do a version substitution within source!
			;-------
			either object? src [
				src/version: dest-version
			][
				;---
				; follow rebol interpreter rules for header identification
				;
				; but assume a well-formed header with a version inside.
				;---
				str: find/tail src "REBOL"
				
				;---
				; skip block start
				str: find/tail str "["
				
				; move ahead until we find a version 
				value-start: find/tail str "version:"
				v: value-start
				parse/all value-start [
					; skip all whitespace
					any [" " | "^-" | "^/" ] v:
				]
				value-start: v

				
				;---
				; find end of that version value
				set [tmp value-end] load/next value-start
				
				vprint  [ "replacing: " copy/part value-start value-end]
				
				change/part value-start to-string dest-version value-end
			]
			
			vout
						
			src
		]
	]
	
	
	;--------------------------
	;-         update-script-date()
	;--------------------------
	; purpose:  
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
	update-script-date: funcl [
		[catch]
		src [file! string! object!]
	][
		throw-on-error [
			vin "update-script-date()"
	
			if file? src [
				src: read src
			]
			
			;unless src-date: get-header-value src 'date
			
			dest-date: international-datestring now
			v?? dest-date
			
			;-------
			; do a date substitution within source!
			;-------
			either object? src [
				src/date: dest-date
			][
				;---
				; follow rebol interpreter rules for header identification
				;
				; but assume a well-formed header with a date inside.
				;---
				str: find/tail src "REBOL"
				
				;---
				; skip block start
				str: find/tail str "["
				
				; move ahead until we find a date 
				value-start: find/tail str "date:"
				v: value-start
				parse/all value-start [
					any [" " | "^-" | "^/" ] v:
				]
				value-start: v
				
				;---
				; find end of that version value
				set [tmp value-end] load/next value-start
				
				vprint  [ "replacing: " copy/part value-start value-end]
				
				change/part value-start to-string dest-date value-end
			]
			
			vout
						
			src
		]
	]
	
	
	;--------------------------
	;-         extend-script-history()
	;--------------------------
	; purpose:  
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
	extend-script-history: funcl [
		[catch]
		src [ file! string! object! ]
		comment [ string! ]
	][
		throw-on-error [
			vin "extend-script-history()"
	
			if file? src [
				src: read src
			]
			
			history: any [
				get-header-value src 'history
				copy ""
			]
			version: get-header-value src 'version
			
			unless find rejoin ["v" version " - "] history [
				append history rejoin [	"^/^-^-v" version " - " international-datestring now "^/^-^-^-"]
			]
			trim comment
			
			history: rejoin [
				"{" history
				"-" comment "^/"
				"^-}"
			]
			
			;-------
			; do a date substitution within source!
			;-------
			either object? src [
				src/history: history
			][
				;---
				; follow rebol interpreter rules for header identification
				;
				; but assume a well-formed header with a date inside.
				;---
				str: find/tail src "REBOL"
				
				;---
				; skip block start
				str: find/tail str "["
				
				; move ahead until we find a history 
				value-start: find/tail str "history:"
				v: value-start
				parse/all value-start [
					any [" " | "^-" | "^/" ] v:
				]
				value-start: v
				
				;---
				; find end of that version value
				set [tmp value-end] load/next value-start
				
				vprint  [ "replacing: " copy/part value-start value-end]
				
				change/part value-start history value-end
			]
			vout
						
			src
		]
	]
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

