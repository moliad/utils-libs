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
	;			fruits: [
	;				red green [
	;					apple  [ 1 ]
	;					tomato [ 2 ]
	;				]
	;				
	;				orange [
	;					orange [ 3 ]
	;				]
	;				
	;				blue purple black [
	;					berry [ 4 ]
	;					blueberry [ 5 ]
	;					blackberry [ 6 ]
	;				]
	;			]
	;
	;			probe multi-switch [black berry] fruits
	;			probe multi-switch 'red/tomato fruits
	;			probe multi-switch 'red/tomato/joj fruits
	;			probe multi-switch [green orange] fruits
	;			probe multi-switch/only 'red fruits
	;--------------------------
	select*: :select
	all*: :all
	multi-switch: funcl [
		path [block! lit-path! path! word!]
		tree [block!]
		/only "do not execute the last item, only return the block as-is"
		/select "use select-mode semantics(chose what follows, not just the next block), implies /only"
		/all
		/catch
	][
		;vin "multi-switch()"
		result: none
		
		if select [only: true]
		
		if lit-path? path [
			path: to-block path
		]
		if path? path [
			path: to-block path
		]
		
		path: compose [(path)]
		;v?? path
		;v?? tree ; careful, on long blocks this can jam app
		
		foreach item path [
			;vprint "======================"
			;v?? item
			;vprint ["tree: " copy/part mold tree 50 ]
			either block? tree [
				if paren? item [
					item: do item
				]
	;			switch type?/word :item [
	;				word! [
	;					;vprint "WORD !!!!"
	;					item: to-lit-word item
	;				]
	;				none! [
	;					;vprint "NONE !!!!"
	;					; we return the datatype, not the value
	;					; this is because none, as a rule, is a no-op which creates endless cycles in parse loops.
	;					item: none!
	;				]
	;			]
				
				;vprobe type? item
				;vprobe item
				either select [
					;vprint "using select-mode"
					tree: select* tree :item
				][
					tree: all* [
						blk: find tree :item
						blk: find blk block!
						first blk
					]
				]
	;				parse tree [
	;					(tree: none)
	;					some [
	;						;set yyy 
	;						;(v?? yyy)
	;						here: item
	;						(
	;							either tree: find here block! [
	;								tree: first tree
	;								;v?? tree
	;							][
	;								;---
	;								; this is a fallback for the case where we use this function for selection.
	;								tree: pick here 2
	;							]
	;							here: tail here
	;						)
	;						:here
	;						|
	;						;set zzz 
	;						skip
	;						;(v?? zzz)
	;					]
	;				]
	;			]
			][
				; skip the rest of the path, we already failed or found the item.
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
		;vout
		
		;v?? result
		
		; we return none if browse isn't successful
		result
	]


	;--------------------------
	;-     deep-select()
	;--------------------------
	; purpose:  like multi-switch but with select semantics.
	;
	; if series is none! we just stay none transparent and return none as well
	;--------------------------
	deep-select: funcl [
		series [block! none!]
		selector [block! lit-path! path! word!]
	][
		either series [
			multi-switch/select selector series
		][
			none
		]
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
	;-     btype()
	;--------------------------
	; purpose:  a complement to forboth returning a special type based on first element of given block
	;--------------------------
	btype: funcl [
		data
	][
		case [
			(tail? data) [
				#[none]
			]
			(block? first data) [
				'block
			]
			'default [
				'item
			]
		]
	]
	
	;--------------------------
	;-     forboth()
	;--------------------------
	; purpose:  execute a block on each item of a pair of datasets.
	;
	; inputs:   using /deep will enter sub-blocks and fail if the whole block structure is not symmetric
	;
	; returns:  a block containing both series at their head
	;--------------------------
	forboth: funcl [
		'serie-a [word!]
		'serie-b [word!]
		body [block!]
		/deep "go into sub-blocks"
		/trace "print trace of function registers while looping"
	][
		result: none
	
		stack-a: copy []
		stack-b: copy []
		
		word-a: serie-a
		word-b: serie-b
		
		serie-a: get serie-a
		serie-b: get serie-b
		if trace [
			?? serie-a
			?? serie-b
			?? word-a
			?? word-b
		]
		
		ctx: copy []
		append ctx reduce [to-set-word word-a #[none]]
		append ctx reduce [to-set-word word-b #[none]]
		
		append ctx compose/only [eval-blk: (body)]
		if trace [?? ctx]
		
		ctx: context ctx
		if trace [?? ctx]
	
		; loop over both datasets, and run body setting both series words.
		; if the datasets are not symmetric in block structure, we raise an error at that point.
		
		until [
			if trace [print "--------------------"]
			ba: btype serie-a
			bb: btype serie-b
			unless deep [
				ba: not not ba
				bb: not not bb
			]
			
			if trace [
				?? ba
				?? bb
				?? serie-a
				?? serie-b
				?? stack-a
				?? stack-b
			]
			case [
				((ba) <> (bb)) [ ; if we hit a structure difference
					to-error "structure difference"
				]
				
				(all [empty? stack-a  empty? serie-a])[  ; we are at end of all data.
					if trace [print "TAIL!"]
					result: reduce [head serie-a head serie-b]
				]
				
				(ba = 'block) [
					if trace [print "SUB BLOCK DETECTED"]
					
					append/only stack-a next serie-a
					append/only stack-b next serie-b
					
					serie-a: first serie-a
					serie-b: first serie-b
					false
				]
				(none? ba) [
					if trace [print "AT END OF SUBBLOCK"]
					serie-a: last stack-a
					serie-b: last stack-b
					
					remove back tail stack-a
					remove back tail stack-b
					false
				]
				
				'default [
					if trace [ print ">>>>"]
					set in ctx word-a serie-a
					set in ctx word-b serie-b
					
					do ctx/eval-blk
					
					serie-a: next serie-a
					serie-b: next serie-b
					false
				]
			]
		]
		
		;print "WE SHOULD NEVER REACH HERE!"
		result
	]

	;--------------------------
	;-     getc()
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
	;-     askchar()
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
	;-     confirm()
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
