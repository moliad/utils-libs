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

