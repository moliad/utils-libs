REBOL [
	; -- Core Header attributes --
	title: {utils-codecs | data encoding/decoding utilities and helpers.}
	file: %utils-codecs.r
	version: 1.0.0
	date: 2013-9-10
	author: "Maxim Olivier-Adlhoch"
	purpose: {Collection of functions to help in manipulation of data to/from different encodings.  Also includes functions which help in those tasks.}
	web: http://www.revault.org/modules/utils-codecs.rmrk
	source-encoding: "Windows-1252"
	note: {Steel Library Manager (SLiM) is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-codecs
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-codecs.r

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
		2013-09-10 - v1.0.0
			-creation of history.
			-license changed to Apache v2
	}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
]



;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-codecs
;
;--------------------------------------

slim/register [

	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- DATA CREATION 
	;- 
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;- bit()
	;--------------------------
	; purpose:  generates an integer which only has the specified bit set.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    offsets larger than 32 will cycle through the 32 bits. (so bit 33 == bit 1 == bit 65)
	;
	; tests:    
	;--------------------------
	bit: func [
		offset [integer!]
	][
		; we use 1 based index (so you use bits 1 - 32,  as opposed to 0 - 31)
		offset: offset - 1
		
		shift/left 1 offset
	]

	
	
	
	
	


	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- DATA CONVERTION
	;- 
	;-----------------------------------------------------------------------------------------------------------
	
	
	;--------------------------
	;-     u32-to-binary()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	u32-to-binary: func [
		n [number!] 
		/rev
	][
		if n > (2 ** 31 - 1) [
			n: n - (2 ** 32)
		]
		n: load join "#{" [form to-hex to-integer n "}"]
		either rev [head reverse n][n]
	]
	

	
	;--------------------------
	;-     load-u32()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    may return a decimal if the number is larger than 31 bits.
	;
	; tests:    
	;--------------------------
	load-u32: funcl [
		data [string! binary!]
	][
		n: to-integer to-binary data
		if negative? n [
			n: n + 2 ** 32
		]
	]



	;--------------------------
	;-     i32-to-binary()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	i32-to-binary: func [
		n [integer!] 
		/rev
	][
		n: load join "#{" [form to-hex to-integer n "}"]
		either rev [head reverse n][n]
	]
	

	
	;--------------------------
	;-     load-i32()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    may return a decimal if the number is larger than 31 bits.
	;
	; tests:    
	;--------------------------
	load-i32: funcl [
		data [string! binary!]
		/rev
	][
		
		n: to-integer to-binary either rev [ head reverse data ][ data ]
	]

	
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------
