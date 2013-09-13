REBOL [
	title:      "String handling tools."
	file:       %utils-strings.r
	version:    1.0.1
	date:       2013-01-09
	
	author:     "Maxim Oliver-Adlhoch"
	purpose:    "Collection of generic, re-useable string! handling functions"
	web:        http://www.revault.org/modules/utils-strings.rmrk
	
	source-encoding: "Windows-1252"
	note:		"slim Library Manager is Required to use this module."

	; SLiM - Steel Library Manager, minimal requirements
	slim-name:    'utils-strings
	slim-version: 1.0.5
	slim-prefix:  none
	slim-update:  http://www.revault.org/downloads/modules/utils-strings.r


	;-- Licensing details --
	copyright:  "Copyright © 2013 Maxim Oliver-Adlhoch"
	license-type: "Apache License v2.0"
	license:      {Copyright © 2013 Maxim Olivier-Adlhoch

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
		2012-02-21 - v1.0.0
			-creation
			-compiling previous code from other libraries
			
		2013-01-09 - v1.0.1
			-Adding slut.r tests.
	}
	;-  \ history 
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-strings
;
;--------------------------------------



slim/register [




	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- STRING
	;- 
	;-----------------------------------------------------------------------------------------------------------
	;--------------------
	;-    zfill()
	;
	;		test-group [  zfill  string  utils-strings.r  ] [  ]
	;			[  "0000003" = zfill 3 7     ]
	;			[  "0000666" = zfill 666 7   ]
	;			[  "0000055" = probe zfill "55" 7  ]
	;		end-group
	;
	;--------------------
	zfill: func [
		"left fills the supplied string with zeros to amount size."
		data [string! integer! decimal!]
		length [integer!]
		/local string
	][
		string: either string? data [
			data
		][
			to-string data
		]
		
		if (length? string) < length [
			head insert/dup string "0" (length - length? string)
		]
		head string
	]



	;--------------------
	;-    fill()
	;--------------------
	fill: func [
		"Fills a series to a fixed length"
		data "series to fill, any non series is converted to string!"
		len [integer!] "length of resulting string"
		/with val "replace default space char"
		/right "right justify fill"
		/truncate "will truncate input data if its larger than len"
		/local buffer
	][
		unless series? data [
			data: to-string data
		]
		val: any [
			val " " ; default value
		]
		buffer: head insert/dup make type? data none val len
		either right [
			reverse data
			change buffer data
			reverse buffer
		][
			change buffer data
		]
		if truncate [
			clear next at buffer len
		]
		buffer
	]
	
	
	
	;--------------------------
	;-    coerce-string()
	;--------------------------
	; purpose:  a merge of to-string and as-string, the most memory efficient.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	coerce-string: funcl [
		data
	][
		vin "coerce-string()"
		data: either any-string? data [
			as-string data
		][
			to-string data
		]
		vout
		data
	]
	
			
				
	;--------------------------
	;-    make-mem-buffer()
	;--------------------------
	; purpose:  Create a mem cleared memory buffer for use with system functions
	;
	; inputs:   when a string is given on input, its length is used.
	;
	; returns:  a 0 filled sting of length bytes.
	;--------------------------
	make-mem-buffer: funcl [
		length [integer! string!]
	][
		;vin "make-mem-buffer()"
		if string? length [
			length: length? string
		]
		;vout/return
		str: head insert/dup make string! length to-char 0 length
	]
	
	
	
	;-----------------
	;-     text-to-lines()
	;-----------------
	text-to-lines: func [
		str [string!]
	][
		either empty? str [
			copy []
		][
			parse/all str "^/"
		]
	]
	
	

	;-----------------
	;-     count-lines()
	;
	; given any string of text, returns at what line that text character
	; is at within the text. (minimum is 1)
	;
	; used to report errors in general.  
	;
	; note that this function is meant to be fast, not memory efficient.
	;-----------------
	count-lines: func [
		string [string!]
	][
		vin [{count-lines()}]
		parse-utils/line-count: 1
		
		parse/all copy/part head string string parse-utils/=line-counter=
		vout
		parse-utils/line-count
	]

]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim  
;
;------------------------------------




