REBOL [
	; -- Core Header attributes --
	title: "Generic series handling tools."
	file: %utils-series.r
	version: 1.0.1
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: "Collection of generic, re-useable functions"
	web: http://www.revault.org/modules/utils-series.rmrk
	source-encoding: "Windows-1252"
	note: {Steel Library Manager (SLiM) is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-series
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-series.r

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
			-license changed to Apache v2
}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
]




slim/register [

	;--------------------------------------
	; unit testing setup
	;--------------------------------------
	;
	; test-enter-slim 'utils-series
	;
	;--------------------------------------
	

	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------

			
	
	
	;--------------------------
	;-     probe-binary-block()
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
	;--------------------------
	probe-binary-block: funcl [
		bin  [binary!]
		amount [integer!]
		/binary
	][
		vin "stone/probe-binary-block()"
		i: 0
		words: 4
		li: 0
		wi: 0
		
		either binary [
			repeat i amount [
				if li >= 4 [wi: wi + 1  vprin "  "  li: 0]
				if wi >= words [vprint "" li: 0 wi: 0]
				li: li + 1
				letter: pick bin i
				
				vprin rejoin [(next next head remove back tail mold (to-binary to-char letter)) "(" (either (letter > 31) [to-char letter ]["."] ) ")"  "  "]
				
				;vprin rejoin [to-integer letter  "(" (either (letter > 31) [to-char letter ][".."] ) ")"  "  "]
			]
		][
			repeat i amount [
				if li >= 4 [wi: wi + 1  vprin "  "  li: 0]
				if wi >= words [vprint "" li: 0 wi: 0]
				li: li + 1
				letter: pick bin i
				vprin rejoin [to-integer letter  "(" (either (letter > 31) [to-char letter ][".."] ) ")"  "  "]
			]
		]
		vprint ""
	
		vout
	]
	
	
	
	
	
	;--------------------------
	;-     count()
	;--------------------------
	; purpose:  returns the number of times a value is in a series (string or block)
	;
	; inputs:   series to search
	;
	; returns:  the count, as an integer!
	;
	; notes:    is NOT none-transparent
	;
	; tests:    
	;
	;		test-group  [count series string! utils-series.r ] [ ]
	;			[ 0 = count "123" "44" ]
	;			[ 0 = count "123" "4" ]
	;			[ 0 = count "" "4" ]
	;			[ 1 = count "1234567890" "4"]
	;			[ 3 = count "444" "4" ]
	;			[ 2 = count "4444" "44" ]
	;			[ 1 = count "444" "44" ]
	;			[ 1 = count/part a: "4444" "44" back back tail a ]
	;			[ 1 = count/part a: next next "4444" "44" tail a ]
	;			[ 0 = count "123" "" ]
	;		end-group
	;
	;		test-group  [count series block! utils-series.r ] [ ]
	;
	;			[ 2 = count [1 2  3 4  5  3 4] [ 3 4 ] ]
	;			[ 0 = count [1 2 3 ] [] ]
	;
	;		end-group
	;
	;--------------------------
	count: funcl [
		series [series!] "A series to search, using the 'FIND function for speed."
		item "Something to find and count."
		/part end "Do not count beyond this point. note that item must be COMPLETELY enclosed by /part"
		/skip record-size "Treat the series as records of fixed size."
	][
		i: 0
		
		end: any [
			end
			tail series 
		]
		
		record-size: any [
			record-size
			1
		]
		
		until [
			not all [
				series: find/part/tail/skip series item end record-size
				i: i + 1
			]
		]
		
		i
	]




	
	;--------------------------
	;-     contains?()
	;--------------------------
	; purpose:  returns true or false depending on if the serie-a contains some (or all) elements of serie-b
	;
	; inputs:   the /all refinement is used when you need all of series b to be in series a
	;
	;--------------------------
	contains?: func [
		serie-a [series!]
		serie-b [series!]
		/all "Set this if you need to know if ALL of serie-b is within serie-a ."
	][
		unless (type? serie-a) = (type? serie-b) [
			to-error "'CONTAINS?: both series have to be of the same type"
		]
		either all [
			empty? exclude serie-b serie-a
		][
			not empty? intersect serie-a serie-b
		]
	]
	
	
	
	
	;--------------------------
	;-     peek()
	;--------------------------
	; purpose:  like pick but doesn't raise an error on none
	;
	; returns:  the result of pick, or none if the inputs are invalid.
	;
	; notes:    this is a 100% none transparent pick (use with any/all)
	;
	;--------------------------
	peek: funcl [
		series [series! none!]
		index [integer! none!]
	][
		attempt [
			pick series index
		]
	]
	
	

	;-----------------
	;-     remove-duplicates()
	;
	; like unique, but in-place
	; removes items from end
	;-----------------
	remove-duplicates: func [
		series
		/local dup item
	][
		;vin [{remove-duplicates()}]
		
		until [
			item: first series
			if dup: find next series item [
				remove dup
			]
			
			tail? series: next series
		]
		
		;vout
		series
	]
	
	;-----------------
	;-     text-to-lines()
	;-----------------
	text-to-lines: func [
		str [string!]
	][
		either empty? str [
			copy ""
		][
			parse/all str "^/"
		]
	]
	
	;-----------------
	;-     shorter?/longer?/shortest/longest()
	;-----------------
	shorter?: func [a [series!] b [series!]][
		lesser? length? a length? b
	]
	
	longer?: func [a [series!] b [series!]][
		greater? length? a length? b
	]
	
	shortest: func [a [series!] b [series!]] [
		either shorter? a b  [a][b]
	]
	
	longest: func [a [series!] b [series!]] [
		either longer? a b  [a][b]
	]	
	
	
	;-----------------
	;-     shorten()
	; returns series truncated to length of shortest of both series.
	;-----------------
	shorten: func [
		a [series!] b [series!]
	][
		head either shorter? a b [
			clear at b 1 + length? a
		][
			clear at a 1 + length? b
		]
	]
	
	;-----------------
	;-     elongate()
	; returns series elongated to longest of both series.
	;-----------------
	elongate: func [
		a [series!] b [series!]
	][
		either longer? a b [
			append b copy at a 1 + length? b
		][
			append a copy at b 1 + length? a
		]
	]
		
	;-----------------
	;-     include()
	;
	; will only add an item if its not already in the series
	;-----------------
	include: func [
		series [series!]
		data
	][
		;vin [{include()}]
		unless find/only series data [
			append series data
		]
		;vout
	]


	
	;--------------------------
	;-     extract-tags()
	;--------------------------
	; purpose:  extracts tag-pair of data within a block.  Using /all will return all of the tags in the list.
	;
	; inputs:   a flat block  and the tag pair key to match (see tests for examples)
	; 
	; returns:  -a block with both the tag and its data 
	;           -returns none when no tags match the input
	;
	; notes:    
	;
	; tests:    [ 
	;               extract-tags 'b [ a 1  b 2  a 1 ]       returns  [b 2]
	;               extract-tags/all 'a [ a 1  b 2  a 1 ]   returns  [a 1 a 1]
	;           ]
	;--------------------------
	extract-tags: funcl [
		tag 
		blk [any-block!]
		/all "return all tags, not just the first one"
	][
		vin "extract-tags()"
		
		either all [
			if found: find/skip blk tag 2 [
				result: copy []
				
				until [
					append result copy/part found 2
					not found: find/skip (next next found) tag 2
				]
			]
		][
			if result:  find/skip blk tag 2 [
				result: copy/part result 2
			]
		]
		
		vout
		result
	]	
	

	;--------------------------
	;-     comply()
	;--------------------------
	; purpose:  a handy function for conditional inclusion of data within COMPOSE blocks.
	;           it replaces this idiom:
	;			odd: false 
	;			compose [ 
	;                0 
	;                ( either odd [1] [[]] ) 
	;                2 
	;                ( either odd [3] [[]] )
	;           ]
	;
	;           with:
	;			compose [ 
	;                0 
	;                ( comply odd [1] ) 
	;                2 
	;                ( comply odd [3] )
	;           ]
	;
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    -when used in a 'COMPOSE, do NOT use /only or else the empty block will be inserted
	;            in the result set.
	;
	;           -this is especially useful when the data to be included is a complex multi-line expression, since the
	;            false expression of the 'EITHER and its empty block return, are far from obvious when its being included
	;            large-ish/nested compose blocks
	;
	; tests:    
	;--------------------------
	comply: func [
		"Used with compose for conditional inclusion of data.   its like an 'IF, but returns [] (empty block!) when false, instead of none."
		value [any-type!] "a truthy value"
		expression [block!] "executed when value is true"
	][
		either value expression [
			; compose will reduce this to nothing, when /only isn't used with compose.
			[]
		]
	]
	


;--------------------------
;-     complete()
;--------------------------
; purpose:  alternative to compose which allows to pass through parens, with a little trick.
;			#( ... ) is ignored  (note the # is independent of the () and is a valid issue! in R2

;
; inputs:   
;
; returns:  
;
; notes:    infinite cycle if given recursive block
;
; to do:    
;
; tests:    
;--------------------------
complete: funcl [
	[THROW]
	blk [block!]
	/deep "compose inner blocks"
	/only "leave result blocks as-is"
][
	here: none
	
	;vin "complete()"
	;v?? blk
	; note conform may be called from within a conform, so ALL data must be re-entry safe
	token-table: copy []
	
	;---
	; this is ONLY used if we are about to do a token replace in the original block given to us.
	;
	; we MUST COPY that block because, if we change it "in-place", we end up with a corrupted user block.
	; 
	; the original user's block is change by us, without his knowledge (evil).
	;
	; (when we do the reverse token replace, its on the result of the compose, which is always a new block.
	;---
	new-blk: none
	
	=deep?=: either deep [
		[into rule]
	][
		[end skip] ; always false
	]
	
	=add-token=: [
		here: # paren! (  
			append token-table token: to-issue rejoin [ "*_#" (length? token-table ) / 2 ] 
			append/only token-table second here
			change/part here token 2 ; we remove the paren!
			here: next here
		) :here
	]
	=erase-token=: [
		here: set tk tokens (
			;vprint ["FOUND TOKEN " tk]
			change/only here select token-table tk ; we replace token by paren!
		)	
	]
	
	=restore-parens=: [
		here: set tk tokens (
			;vprint ["FOUND TOKEN " tk]
			here: change/part here reduce [ # select token-table tk  ] 1 ; we replace token by  [ # (...) ]
		)	
		:here
	]
	
	;----
	; find and nullify tokenised parens
	;----
	rule: [
		any [
			=add-token=
			| paren!
			| =deep?= ; enters blocks when /deep is specified, we try and find ALL inner tokens and replace them
			| skip
		]
	]
	
	;v?? token-table
	parse blk rule
	
	;----
	; compose data
	;----
	new-blk: any [
		all [deep only compose/only/deep blk]
		all [deep compose/deep blk]
		all [only compose/only blk]
		compose blk
	]
	
	
	;----
	; reset token parens
	;----
	unless empty? token-table [
		tokens: extract token-table 2
		merge/between tokens '|
		;v?? tokens
		;v?? token-table
		
		rule: [
			any [
				=restore-parens=
				| paren!
				| =deep?= ; enters blocks when /deep is specified, we try and find ALL inner tokens and replace them
				| skip
			]
		]
		parse blk rule ; we have to restore the original block data to its former glory.
		
		rule: [
			any [
				=erase-token=
				| paren!
				| =deep?= ; enters blocks when /deep is specified, we try and find ALL inner tokens and remove them in end-user result
				| skip
			]
		]
		parse new-blk rule ; we 
	]
	tokens: none
	token-table: none
	;v?? blk
	;v?? new-blk
	;vout
	new-blk
]




	
	;--------------------------
	;-     conform()
	;--------------------------
	; purpose:  guarantees that  series will conform to some pattern.  
	;           if they already conform they are untouched, otherwise they are modified
	;           to comply.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    modifies input
	;
	;           - the various conforming inputs are typed to the given serie, so that you can
	;             supply most rebol values as patterns and they can be used directly.
	;
	; tests:    
	;  (following must be converted to slut tests)
	;	probe {conform/end/merge "12345xyz_z" "xyz"}
	;	conform/end/merge "12345xyz_z" "xyz"
	;	
	;	
	;	probe conform/start "123" "12"
	;	probe conform/start "134" "12"
	;	probe conform/start/merge "134" "12"
	;--------------------------
	conform: funcl [
		serie [series!]
		/start st
		/end nd
		/merge {when set, the compliance is interleaved into the series. Not all modes supply /merge. ex: conform/start/merge "134" "12"  returns "1234" instead of "12134"}
	][
		;vin "conform()"
		
		backup: serie ; we backup this since we want to keep the input offset.
		
		case/all [
			;-------
			; START
			;-------
			start [
				;print "start"
				if (type? serie) <> (type? st) [
					st: to type? serie st ; let it crash if incompatible.
				]
				
				l: length? st
				
				if ((copy/part serie l) <> (st)) [
					either merge [
						foreach item st [
							either item <> pick serie 1 [
								serie: insert/only serie item
							][
								serie: next serie
							]
						]
					][
						insert/only serie st
					]
				]
			
			]
			
			
			;-------
			; END
			;-------
			end [
				;print "^/^/-----end-----"
				if (type? serie) <> (type? nd) [
					nd: to type? serie nd ; let it crash if incompatible.
				]
				l: length? nd
				i: (max ((length? serie) - l) 0) + 1 ; rebol is 1 based for indexing (+1)
				st: index? serie ; preserve index of given serie so that we insert from this point on, even if merge is chosen.
				l-st: length? serie
				
				if ((at serie i) <> (nd)) [
					either not merge [
						append/only serie nd
					][
						; double cursor backward progression
						; because he must not support cyclic data we cannot use copy which makes this much more complex.
						serie: tail serie
						nd: tail nd
						until [
							;print ""
							nd: back nd
							unless empty? nd [
								item: first nd
								
								
;								if all [
;									(index? serie) > (st) 
;								][
;									serie: back serie
;								]
								
								ser: pick serie -1 ; ends up being irrelevant once we are at start of string, so it stays valid.
								;?? item
								;?? ser
								;?? serie
								;print ["different? " item <> ser ]
								
								; here we must insert
								either any [
									head? serie ; also handles 
									
									; preserve input index as a backward boundary to conform to.
									; thus if we provide a series at index of 2, the first two items of this serie
									; are guaranteed not to change... 
									;
									; this is similar to other rebol functions like reverse, which also consider input
									; index as a boundary for their effects.
									(index? serie) <= (st) ; should never be negative
									item <> ser
								][
									;print "inserting"
									insert serie item
								][
									;if ser = item [
										serie: back serie
									;]
								
								]
							]
							head? nd
						]
					]
				]
			
			]
		
		]
		
		
		;vout
		st: nd: serie: l: i: none
		
		; if an error occurs, we return none
		backup
	]
	
	
	;--------------------
	;-     merge()
	;--------------------
	at*: :at
	skip*: :skip
	merge: funcl [
		container "series to insert into" [series!]
		data "data to insert within, single value or series, a single value will be repeated as needed to reach end of container."
		/between "Do not add item at end, only in-between container items."
		/zero "insert data before first element of container"
		/skip step [integer!] "skip container records when merging" 
		/every n [integer!]   "view the data as fixed-sized records, first being always inserted. (ex: 2= 1 3 5 7)"
		/amount a [integer!]  "insert this many elements from data at a time, if every is specified, this amount cannot be larger than it."
		/at ata [integer! none!] "start merge at this offset within container, use none value to follow skip size"
		/only "treat series data as single values (repeating the series in container till the end).  Note that data is not copied."
		;/local repeat
	][
		; usefull copy to end use of merge
		if any [
			not series? data
			only
		][data: head insert/only tail copy [] data repeat: true]
		
		either skip [step: step + 1][step: 1]
		unless every [n: 1]
		unless amount [a: 1]
		unless zero [container: at* container 2]
		if at [
			if none? ata [ata: step]
			container: skip* container ata
		]
		
		; change amount functionality based on if every is specified.
		if every [
			either n >= a [n: n - a + 1][to-error "merge: amount cannot be larger than every"]
		]
		
		until [
			loop a [
				unless any [
					tail? data
					all [
						between 
						tail? at* container step
					]
				][
					container: insert/only container first data
					unless repeat [
						data: at* data 2 ; skip to next item in data
					]
				]
			]
			
			;stop merging past container
			if tail? container [
				data: tail data
			]

			container: at* container step + 1
			unless repeat [
				data: at* data n
			]

			any [
				tail? data
				all [
					between 
					tail? at* container step
				]
			]
		]
		first reduce [ head container container: none data: none ]
	]
	
	
	;--------------------
	;-     separate()
	;--------------------
	SEPARATE: func [
	    "separates the serie into a serie of the same type using a specified separator and many flexible options"
	    serie [series!] "series you wish to separate"
	    separator "if this is a series, it cycles each item at each separation."
	    /only "if separator is a series, insert it as-is at each separation."
	    /skip skip-count
	    /at offset "note, use 0 to insert at head of (before) series!"
	    /local here
	][
	   
	    skip-count: (any [skip-count 1]) - 1 + either only[length? separator] [1]
	    if at [
	        serie: system/words/at serie offset
	        ; add an item in serie so algorythm adds something after it, instead of after first char
	        if offset = 0 [
	            serie: head insert serie "#"
	        ]
	    ]
	    parse/all serie [any [
	        here: skip
	        (
	            unless empty? next here [
	                either all [ series? separator not only] [
	                    insert next here  any [
	                        ; cycle through separator
	                        all [not empty? separator first separator ]
	                        first separator: head separator
	                    ]
	                    separator: system/words/skip separator 1 ; error free way to go to next item
	                ][
	                    insert next here separator
	                ]
	            ]
	        ) skip-count skip ]
	    ]
	
	    if offset = 0 [
	        ; remove the first item of series, which we added
	        remove serie
	    ]
	
	    head serie
	]

	
	
]


	

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

