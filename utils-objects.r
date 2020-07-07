rebol [
	title: "object manipulation"
	file: %utils-objects.r
	version: 1.0.0
	date: 2020-06-04
	author: "Maxim Olivier-Adlhoch"

	; -- slim - Library Manager --
	slim-name: 'utils-objects
	slim-version: 1.4.0
	slim-prefix: none
]


;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-objects
;
;--------------------------------------


slim/register [

	

	;--------------------------
	;-     literally()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	literally: funcl [
		"returns a block with which you can rebuild an object, fixes lit-word datatype"
		object "the object you want the specification for"
		/no-func {do not include any functions in the specification.
			this is usefull to template objects which have methods,
			for which you do not want to duplicate code in ram.
			This also allows you to reimport old data while keeping newer methods}
		/ignore ignore-list[block!]{do not include the words in this list}
	][
		blk: third object
		
		forall blk [
			item: first blk
			if word! = (type? first blk) [
				if not (value? item) [
					change blk to-lit-word item
				]
			]
			
			; do we strip functions from the specification?
			if no-func [
				if function! = (type? first blk) [
					blk: back blk
					remove/part blk 2
				]
			]
		]
		
		;probe head blk
		;probe ignore-list
		
		
		; ignore list 
		if ignore [
			blk: head blk
			while [ not tail? blk ] [
				;print "^/---"
				item: first blk
				;probe item
				either find ignore-list to-word item [
					;print ["removed"]
					remove/part blk 2
					;probe blk
					; blk: back blk
				][
					; skip every other value
					blk: skip blk 2
				]
			]
		]
		;ask""
		return head blk
	]

]



;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

