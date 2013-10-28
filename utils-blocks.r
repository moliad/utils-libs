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
	
			
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------
