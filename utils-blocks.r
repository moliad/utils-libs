REBOL [
	; -- Core Header attributes --
	title: "Generic block! handling functions"
	file: %utils-blocks.r
	version: 1.0.2
	date: 2013-10-8
	author: "Maxim Olivier-Adlhoch"
	purpose: {Collection of generic, re-useable functions for handling block! values.}
	web: http://www.revault.org/modules/utils-blocks.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-blocks
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-blocks.r

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
		v1.0.1 - 2013-9-10
			-creation of history
			-license changed to Apache v2
	

		v1.0.2 - 2013-10-08
			-Added 'POP function and a few unit tests for it.
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
; test-enter-slim 'utils-blocks
;
;--------------------------------------

slim/register [
	

	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-     set-tag()
	;--------------------------
	; purpose:  changes the first matching tag pair value or adds a new tag pair to a block
	;
	; returns:  the taglist just past where you changed it
	;
	; notes:    you CAN use word! types for the value, it will be ignored as a tag name.
	;
	; tests:  
	;  
	;	-create tag list from scratch
	;		test [ set-tag utils block! utils-block.r ] [ [ tag value ] = head set-tag [] 'tag 'value ]
	;
	;	-add a tag to an existing list		                   
	;		test [ set-tag utils block! utils-block.r ] [ [ tag value  aaa 666] = head set-tag [ tag value ] 'aaa 666 ]
	;
	;	-replace a value in an existing list
	;		test [ set-tag utils block! utils-block.r ] [ [ tag value  aaa "success!"] = head set-tag [ tag value  aaa 666] 'aaa "success!" ]
	;	
	;	-index of change is after manipulated tag value pair
	;		test [ set-tag utils block! utils-block.r ] [ 3 = index? set-tag [ tag value  aaa 666] 'tag "success!" ]
	;
	;--------------------------
	set-tag: func [
		blk [block!]
		tag [word! tag!]
		value
	][
		blk: change next any [
			find/skip blk tag 2
			tail append blk tag
		] value
		
		blk
	]




	;-----------------
	;-     find-same()
	;
	; like find but will only match the exact same series within a block.  mere equivalence is not enough.
	;
	; beware, this can be very slow for blocks, as it does a deep compare!
	;-----------------
	find-same: func [
		blk [block!]
		item [series! none! ]
		/local s 
	][
		unless none? item [
			while [s: find blk item] [
				if same? first s item [return  s]
				blk: next s
			]
		]
		none
	]




	
	;--------------------------
	;-     include-different()
	;--------------------------
	; purpose:  only includes data in a block when the exact same item isn't in the list.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    mere equivalence isn't enough, it requires same? comparison.
	;
	; tests:    
	;--------------------------
	include-different: funcl [
		blk [block!]
		data [series!]
	][
		unless find-same blk data [
			append blk data
		]
	]


	
	;--------------------------
	;-     replace-deep()
	;--------------------------
	; purpose:  given a tree of blocks finds a value and replaces it with another.
	;
	; inputs:   
	;
	; returns:  none if the search isn't found, the replaced value at block when it is found.
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	replace-deep: funcl [
		block [ block! ]
		search-value 
		replace-value 
	][
		;vin "replace-deep()"
		rval: none
		done?: false
		stack: clear []
		
		while [
			all [
				block
				not done?
		 	] 
		 ][
		 	;vprint "================"
		 	;v?? block
		 	
		 	sblk: find block search-value
		 	bblk: find block block!
		 	
			any [
			
				all [
					sblk 
					any [
						not bblk
						(index? sblk) < (index? bblk)
					]
					
					change/only sblk replace-value
					rval: sblk
					done?: true
				]
				
				
				if bblk [
					append stack next bblk
					block: first bblk
				]
				
				
				unless empty? stack [
					block: last stack
					remove back tail stack
					block
				]
				
				block: none
			]
		]
		
		;vout
		rval
	]


	
	;--------------------------
	;-     pop()
	;--------------------------
	; purpose:  removes the last item from a block, returning it
	;
	; inputs:   stack in block format
	;
	; returns:  none when list is empty.
	;
	; notes:    - none transparent
	;           - WILL NOT attempt to go back on a given block which is given at its tails but contains items preceding it.
	;
	; tests:    
	;
	;    test-group [ stack  utils-blocks.r  block! ]
	;		[ all [ r: pop   b: [1 2 3]   r = 3   b = [ 1 2 ]  ] ]
	;		[ all [ none? pop  tail b: [ 1 2 3 ]  b = [1 2 3]  ] ]
	;		[ none = pop [] ]
	;		[ none = pop none ]
	;	end-group
	;		
	;--------------------------
	pop: funcl [
		stack [block! none!]
	][
		all [
			stack
			not empty? stack
			first reduce [
				last stack 
				remove back tail stack 
				stack: none
			]
		]
	]
	


	
	;--------------------------
	;-             keep-duplicates()
	;--------------------------
	; purpose:  returns only duplicates from a block
	;
	; notes:    returns a new series.
	;           current implementation may be quite slow on large lists.
	;--------------------------
	keep-duplicates: func [
		series [block!]
		/local i
	][
		;print [">>>>" now/precise]
		series: make hash! out-blk: series
		out-blk: unique out-blk

		had-none?: found? find series none
		foreach item out-blk [
		;while [not tail? series] [
		;	i: first series  
			change find series item none
		]
		out-blk: unique out-blk
		
		;---
		; remove the none entry if there where none on entry
		all [
			had-none?
			blk: find out-blk none
			remove blk
		]
		
		;print ["<<<" now/precise]
		
		out-blk
	]
			
	
	
	
	
	
		
	;--------------------------
	;-     extract-set-words()
	;--------------------------
	; purpose:  finds set-words within a block of code, hierarchically if required.
	;
	; inputs:   block!
	;
	; returns:  the list of words in set or normal word notation
	;
	; notes:    none-transparent
	;
	; tests:    [  
	;				probe extract-set-words/only [ t: rr x: 5]  
	;			]
	;--------------------------
	extract-set-words: funcl [
		blk [block! none!]
		/only "returns values as set-words, not ordinary words.  Useful for creating object specs."
		/ignore iblk [block!] "don't extract these words."
		/deep "find set-words in sub-blocks too"
		;/local words rule word =rule= =deep-rules=
	][
		word: none
		
		words: make block! 12
		iblk: any [iblk []]
		=deep-rule=: [skip]
		
		=rule=: [
			any [
				set word set-word! (
					unless find iblk to-word :word [
						append words either only [ word ][to-word word]
					]
				)
				| hash! 
				| list!
				| =deep-rule=
				| skip
			]
		]
		
		if deep [
			=deep-rule=: [ into =rule= ]
		]
		
		parse blk =rule= 
		
		words
	]
	
	
	
	;--------------------------
	;-     load-fragment()
	;--------------------------
	; purpose:  given a script of rebol code, attempt to load it up to the last incomplete value.
	;
	; inputs:   a string of rebol source.
	;
	; returns:  similar to load/all but the first item is a block of ALL loaded values, instead of just one.
	;
	;           we also add a third item , which is either none, if all went well,  or an disarmed error
	;           object in the event of a failed load/next.
	;
	;           we expect errors in many cases, since we use this function to load partial scripts, which may or may not
	;           be fully downloaded yet.
	;
	;
	;
	; notes:    we clear the given script of any value which was successfully loaded.
	;           The last value in the script MAY not be loaded when it can be extended by more script.
	;
	;           ex:  numbers, words, etc.  In such case we leave the potential last value in the script and do not 
	;                return it in the return value block.
	;
	;           if you put a whitespace (or comment) at the end, it will definitely terminate the last value. 
	;           we then include that last value, since it is unambiguously terminated..
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	load-fragment: funcl [
		script [ string! binary! ]
		/cut "Automatically clear the input script with whatever was successfully loaded.  Doesn't clear the error generating input string."
	][
		;vin "load-buffer()"
		;v?? xfer-buffer
		
		script: as-string script
		rval: copy [  ]
		
		;--- 
		; loop over block until we hit its end or an incomplete value.
		;
		until [
			not all [
				error-at: script
				not error? blk: try [ load/next script ]
				(error-at: none  'continue)
				not empty? blk
				any [
					not empty? second blk ; if its not empty, we know all types are complete.
					find [ string! block! object! none! logic! tag!] type?/word first blk
				]
				rval: insert/only rval first blk
				script: second blk
			]
		]
		
		if error? blk [
			blk: disarm blk
		]
		
		error-at: all [
			error-at
			blk
		]
		
		if cut [
			remove/part  head script  script
			script: head script
		]
		
		;vout
		first reduce [ compose/deep [ [(head rval)]  (script) (error-at) ] rval: none ]  
	]
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------
