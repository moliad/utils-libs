rebol [
	; -- Core Header attributes --
	title: "Data creation utilities"
	file: %utils-datagen.r
	version: 1.0.1
	date: 2015-8-14
	author: "Maxim Olivier-Adlhoch"
	purpose: "Collection of generic, re-useable functions"
	web: http://www.revault.org/modules/utils-datagen.rmrk
	source-encoding: "Windows-1252"
	note: {Steel Library Manager (SLiM) is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-datagen
	slim-version: 1.2.7
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-datagen.r

	; -- Licensing details  --
	copyright: "Copyright © 2015 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2015 Maxim Olivier-Adlhoch

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
		v1.0.1 - 2015-08-14
			-creation of lib
			-build-integer-list() Added
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
; test-enter-slim 'utils-datagen
;
;--------------------------------------
slim/register [                                                                                                               
	;--------------------------
	;-         build-integer-list()
	;--------------------------
	; purpose:  Build an ordered list of integers
	;
	; inputs:   start and end are INCLUSIVE
	;
	; returns:  
	;
	; notes:    when /count is given, step can be negative. (it means "count down")
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	build-integer-list: funcl [
		start [integer!]
		end [integer!]
		/skip step [integer!] "Skip values, does not not need to be an exact multiple of start-end range."
		/in blk [any-block!] "provide block to dump list within. Will be INSERTED AT location of block"
		/count "the end value, is in fact a COUNT, not the end of the range. Output will have exactly that number of items in it (step is still considered)"
	][
;		vin "build-integer-list()"
		step: any [ step 1 ]
		blk:   any [ blk copy [] ]

		either count [	
			iterations: end
		][
			iterations: (ABS to-integer  ( ( end - (start ) ) / step)) + 1
			
			;---
			; in this mode, we cannot have a negative step.
			step: ABS step
			
			if start > end [
				step: step * -1
			]
		]
		
		; we create a temp block pointer, to keep the original position.
		b: blk
		
;		?? blk
;		?? start
;		?? end
;		?? step
;		?? iterations
		repeat i iterations [
			;?? i
			b: insert b start + (step * (i - 1))
		]
;		vout
		
		
		; if the user provided a block, we return it at its given position.
		blk
	]
]



;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

