REBOL [
	; -- Core Header attributes --
	title: "Generic slim Template."
	file: %utils-http.r
	version: 0.1.0
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: "Manipulate "
	web: http://www.revault.org/modules/utils-http.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-http
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-http.r

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
		2013-05-03 - v0.1.0
			-creation of history.

		v0.1.0 - 2013-09-12
			-License changed to Apache v2
}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
]





;--------------------------------------
; unit testing setup (using slut.r)
;--------------------------------------
;
; test-enter-slim 'utils-http
;
;--------------------------------------

slim/register [
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	 
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PARSE RULES
	;
	;-----------------------------------------------------------------------------------------------------------
	;-    -basic characters & lines
	=lf=: #"^/"
	=crlf=: crlf
	=lf=: lf
	=cr=: cr
	=nl=: [ =crlf= | =cr= | =lf= ]
	=crlfx2=: join =crlf= =crlf=
	=dquote=: #"^""
	

	=alphanum=: charset [#"0" - #"9" #"a" - #"z" #"A" - #"Z"]
	=entity-base=:  charset ["^"&" #"^(A0)" - #"^(FF)"]
	=entity-char=:  union =entity-base= charset "<>"
	=url-special=:  charset "$-_.+!*'(), "
	=url-reserved=: charset "&/:;=?@"
	=not-url=: complement union =url-reserved= union =url-special= =alphanum=
	

	 
	 
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- CLASSES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	 
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-     url-encode()
	;--------------------------
	; purpose:  url-encodes given data or part-of, based on refinements.
	;
	; inputs:   when no refinements are given, we assume /text /paths and NOT /text
	;           url encodes all other characters. 
	;           do not give utf-8 text, it treats the data as a binary string! as per http url conventions (which are ascii).
	;
	; returns:  
	;
	; notes:    - always returns a string, even if given a url
	;           - returned value is a copy (does not modify in place)
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	; always returns a NEW sting
	;--------------------------
	url-encode: funcl [
		data [string! url!] 
		/text "url encodes normal url legal characters"
		/paths "encodes http RFC path & param reserved characters"
		/special "encodes special characters"
	][
		vin "url-encode()"
		;----------------------
		; evaluate function params
		;----------------------
		
		; analyse refinements
		any [
			text
			paths
			special
		
			; no refinements given, we set defaults
			(paths: true special: true)
		]
		
		; chose charsets based on params
		=char=: =not-url=
		
		if text [
			=char=: union =char=  =alphanum=
		]
		if paths [
			=char=: union =char= =url-reserved=
		]
		if special [
			=char=: union =char= =url-special=
		]
		
		data: as-string data
		data: copy data
		parse/all data [
			any [
				here:
				[
					[
					  	copy .char =char= (
					  		here: change/part here ( 
					  			rejoin ["%" skip to-hex to integer! to char! .char 6]
					  		) 1 ; 1 is for the /part argument to change
					  	) 
					  	:here
					]
					| skip
				]
			]
		]
		
		vout
		data
	]
	

	
	;-----------------
	;-    escape-html()
	;
	; returns a new string
	;-----------------
	escape-html: func [
		html [string!]
	][
		vin [{escape-html()}]
		
		html: copy copy
		foreach [char code] [
			"&" "&amp;"
			"<" "&lt;"
			">" "&gt;"
		][
			replace/all html char code
		]
		vout
		
		html
	]
	
	
	
	;--------------------------
	;-    escape-pre()
	;--------------------------
	; purpose:  given html source will find and escape <pre> </pre> tags.
	;--------------------------
	escape-pre: funcl [
		html [string!]
	][
		vin "escape-pre()"
		
		txt: copy html
		parse/all txt [
			some [
				"<pre>" here: copy val to  "</pre>" there: ( change/part here (escape-html val)  there  )
				| skip
			]
		]
		vout
		
		txt
	]
	
	
		
	;-----------------
	;-    decode-multipart()
	;
	; returns a new string
	;-----------------
	decode-multipart: func [data /local bound list name filename value pos][
		list: make block! 2
		attempt [
			parse/all request/headers/Content-type [
				thru "boundary=" opt =dquote= copy bound [to =dquote= | to end]
			]
			unless bound [return ""]	 ;-- add proper error handler
			insert bound "--"	
			parse/all data [
				some [
					bound =nl= some [
						thru {name="} copy name to =dquote= skip
						[#";" thru {="} copy filename to =dquote= | none]
						thru =crlfx2= copy value [to bound | to end] (
							insert tail list to word! name
							trim/tail value ; -- delete ending crlf
							if all [
								#"%" = pick value 1
								".tmp" = skip tail value -4
							][
								value: load value
							]
							either filename [
								insert/only tail list reduce [filename value]
							][
								insert tail list value
							]
							filename: none
						) | "--"
					]
				]
			]
		]
		list
	]	
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

