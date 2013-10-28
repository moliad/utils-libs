rebol [
	; -- Core Header attributes --
	title: "Rebol word manipulation utilities"
	file: %utils-words.r
	version: 1.0.1
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: "Collection of generic, re-useable functions"
	web: http://www.revault.org/modules/utils-words.rmrk
	source-encoding: "Windows-1252"
	note: {Steel Library Manager (SLiM) is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-words
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-words.r

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
			-license changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
]






;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-words
;
;--------------------------------------


slim/register [                                                                                                               
	;-----------------
	;-     swap-values()
	;
	; given two words, it will swap the values these words reference or contain.
	;
	;    test [swap-values word! any-word! utils-word.r ] [ a: 1  b: 2  swap-values a b  all [a = 2  b = 1]]
	;-----------------
	swap-values: funcl [
		'a [ word! ]
		'b [ word! ]
	][c: get a set a get b set b  c]



	;--------------------------
	;- as-lit-word()
	;--------------------------
	; purpose:  converts any word to a lit-word type even some which are notoriously hard to manage like '< or '>
	;
	; inputs:   a word to convert
	;
	; returns:  a lit-word!
	;
	; notes:    function code suggested by Ladislav Mecir on Altme' Rebol discussion forum
	;
	; tests:    
	;	test-group [as-lit-word word! any-word! utils-word.r][]
	;   	["'>" = mold as-lit-word > ]
	;   	["'<" = mold as-lit-word < ]
	;   	["'<=" = mold as-lit-word <= ]
	;   	["'haha" = mold as-lit-word haha: ]
	;   end-group
	;--------------------------
	as-lit-word: funcl ['word [any-word!]] [to lit-word! word]
	

]



;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

