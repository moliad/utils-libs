REBOL [
	; -- Core Header attributes --
	title: "program flow control utility code."
	file: %utils-flow.r
	version: 1.0.0
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: {Collection of generic, re-useable program flow functions}
	web: http://www.revault.org/modules/utils-flow.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-flow
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-flow.r

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
		2013-01-03 - v1.0.0
			-creation
			-MULTI-SWITCH() added
			
	
		v1.0.1 - 2013-09-12
			-license changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
	library: {[
	level: 'intermediate 
	platform: 'all 
	type: [tool module] 
	domain: [external-library file-handling] 
	tested-under: [win view 2.7.8] 
	support: "same as author" 
	license: 'Apache-v2 
	see-also: http://www.revault.org/modules/utils-flow.rmrk
]}
]





slim/register [

	;--------------------------------------
	; unit testing setup
	;--------------------------------------
	;
	; test-enter-slim 'utils-flow
	;
	;--------------------------------------
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- CLASSES
	;- 
	;-----------------------------------------------------------------------------------------------------------


	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------

	
			
			
		
			
	
	;--------------------------
	;-     multi-switch()
	;--------------------------
	; purpose:  Iteratively descend the tree, given one or more items to select with.
	;           when the path is given as a block, each element of the block is one selection.
	;
	;           We match items using the 'SWITCH metaphor, rather than 'SELECT.
	;
	;           this means we can supply several items which match the same block.
	;
	;           we must wrap the data to return within a block, since we will execute the block (just like switch)
	;
	; inputs:   -blocks hierarchy
	;           -browsing path (as a lit path or a block of items to match, at each depth).
	;           -parens are legal within path BLOCK!
	;
	; returns:  The item within tree which your path refers to.
	;
	;           When browsing is not able to find your path (not in tree or path is deeper than tree)
	;           we return none.
	;
	;
	; notes:    -none-transparent
	;
	;           -when path arguments are given using the 'PATH! datatype, they are converted to a block of words/parens, 
	;
	;           -paren! path items are evaluated before browsing.
	;
	;           -if you provide partial paths within the tree, you MUST also call multi-switch with the /only refinement.
	;
	; tests:    
	;       test-preamble 'multi-switch-block <[ 
	;           fruits: [
	;               red green [
	;                   apple  [ 1 ]
	;                   tomato [ 2 ]
	;               ]
	;               
	;               orange [
	;                   orange [ 3 ]
	;               ]
	;               
	;               blue purple black [
	;                   berry [ 4 ]
	;                   blueberry [ 5 ]
	;                   blackberry [ 6 ]
	;               ]
	;           ]
	;       ]>
	;
	;       test-group [ multi-switch  flow  utils-flow.r ] [ multi-switch-block ]
	;           [ probe multi-switch [black berry] fruits ]
	;           [ probe multi-switch 'red/tomato fruits ]
	;           [ probe multi-switch 'red/tomato/joj fruits ]
	;           [ probe multi-switch [green orange] fruits ]
	;           [ probe multi-switch/only 'red fruits ]
	;       end-group
	;--------------------------
	multi-switch: func [
		path [block! lit-path! path! word!]
		tree [block!]
		/only "do not execute the last item, only return the block as-is"
		/catch
	][
		vin "multi-switch()"
		result: none
		
		if lit-path? path [
			path: to block path
		]
		
		path: compose [(path)]
		v?? path
		v?? tree
		
		foreach item path [
			;vprint "======================"
			;v?? item
			;v?? tree
			either tree [
				if paren? item [
					item: do item
				]
				switch type?/word :item [
					word! [
						;vprint "WORD !!!!"
						item: to-lit-word item
					]
					none! [
						;vprint "NONE !!!!"
						; we return the datatype, not the value
						; this is because none, as a rule, is a no-op which creates endless cycles in parse loops.
						item: none!
					]
				]
				
				;vprobe type? item
				;vprobe item
				;
				parse tree [
					(tree: none)
					some [
						set yyy here: item
						
						;(v?? yyy)
						(
							if tree: find here block! [
								tree: first tree
						;       v?? tree
							]
							here: tail here
						)
						:here
						|
						set zzz skip
						;(v?? zzz)
					]
				]
			][
				; skip the rest of the path, we already failed
				break
			]
		]
		
		;v?? tree
		
		; did we browse to where we wanted?
		if tree [
			result: either only [
				tree
			][
				catch do tree
			]
		]
		vout
		; we return none if browse isn't successful
		result
	]



	;--------------------------
	;-     at-each()
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
	;       test-group [ at-each  flow  utils-flow.r ] []
	;           [ total: 0  ( 10 = at-each blk [1 2 3 4] [ total: total + first blk ]  ) ]
	;       end-group
	;--------------------------
	at-each: func [
	    'word
	    series
	    code
	    /local ctx rval
	][
	    ctx: context reduce [to-set-word word #[none]]
	    code: bind/copy code ctx
	    while [not tail? series] [
	        set in ctx word series
	        rval: do code
	        series: next series
	    ]
	    rval
	]


	
	
	;--------------------------
	;-     partial()
	;--------------------------
	; purpose:  attempt to evaluate ALL expressions, but notify if incomplete.
	;
	; inputs:   block of code to evaluate
	;
	; returns:  returns true when at least one expression returns NONE or FALSE
	;
	; notes:    like 'ALL, the value of the last item is also taken into consideration.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	partial: funcl [
		eval-block [block!]
	][
		not all eval-block
	]


	;--------------------------
	;-         getc()
	;--------------------------
	; purpose:  low-level character input method.
	;--------------------------
	getc: has [ console-port char ][
		if console-port: open/binary [scheme: 'console] [
			wait console-port
			char: to-char first console-port
			;?? char
			close console-port
			char
		]
	]



	;--------------------------
	;-         askchar()
	;--------------------------
	; purpose:  like ASK but returns after a single char, from a given list.
	;
	; inputs:   a block of options which are pairs of [ char! word! ...]
	;			/fail allows you to fail if wrong character is pressed, we return none in such a case.
	;
	; returns:  
	;
	; notes:    - unless you use /fail the function doesn't return until a valid char is pressed.
	;			- you CAN use any value a part char! for the value part of the selection
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	askchar: funcl [
		selection [block!]
		/fail
	][
		vin "askchar()"
		spec: copy []

		either fail [
			char: getc
			rval: select selection char
		][
			forever [
				char: getc
				if find selection char [
					rval: select selection char
					break
				]
			]
		]
		
		vout
		rval
	]
	
	
	;--------------------------
	;-         confirm()
	;--------------------------
	; purpose:  a helper around the askchar method for y/n confirmation.
	;
	; inputs:   
	;
	; returns:  true or none.
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	confirm: funcl [
		/msg message [ string! block! ]
	][
		if msg [
			if block? message [
				message: rejoin message
			]
			print message
		]
		askchar [
			#"y"	#[true]
			#"Y"	#[true]
			#"n"	#[none]
			#"N"	#[none]
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
