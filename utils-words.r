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
	;-----------------
	swap-values: func [
		'a 'b 
		/local c
	][c: get a set a get b set b  c]


]



;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

