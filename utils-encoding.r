REBOL [
	; -- Core Header attributes --
	title: "Files encoding management"
	file: %utils-encoding.r
	version: 1.3.0
	date: 2018-11-23
	author: "Peter W A Wood"
	purpose: {A set of string utilities created to help with text encoding in 8-bit
	character strings}
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-encoding
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-blocks.r

	;-  / license
	license: 'mit
	;-  \ license
	
	;-  / history
	history: {
		v1.2.2 - 2018-11-23
			-Semantic API version

		v1.3.0 - 2018-11-23 <SMC>
			-Slimified the library 
			-Fixed strip-bom that was expecting BOM to be an object instead of a block
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
; test-enter-slim 'utils-encoding
;
;--------------------------------------

slim/register [

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBAL
	;
	;-----------------------------------------------------------------------------------------------------------
	BOM: [
		"utf-32be" "^(00)^(00)^(FE)^(FF)"
		"utf-32le" "^(FF)^(FE)^(00)^(00)"
		"utf-16be" "^(FE)^(FF)"
		"utf-16le" "^(FF)^(FE)"
		"utf-8" "^(EF)^(BB)^(BF)"
	]
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- PARSING RULES
	;- 
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     constants
	;
	;--------------------------
	replacement-char: #"?"
	
	;--------------------------
	;-     standard bitsets
	;
	;--------------------------
	ascii: charset [#"^(00)" - #"^(7F)"]
	non-ascii: charset [#"^(80)" - #"^(FF)"]
	characters: charset [#"^(00)" - #"^(FF)"]
	ch128-159: charset [#"^(80)" - #"^(9F)"]
	ch160-255: charset [#"^(A0)" - #"^(FF)"]
	ch128-255: charset [#"^(80)" - #"^(FF)"]
	alpha: charset [#"a" - #"z" #"A" - #"Z"]
	digit: charset [#"0" - #"9"]
	alphanumeric: union alpha digit
	letter-hyphen: union alphanumeric charset ["-"]
	byte: charset [#"^(00)" - #"^(FF)"]
	
	;--------------------------
	;-     UTF-8 bitsets
	;
	;--------------------------
	first-2-byte: charset [#"^(C2)" - #"^(DF)"]
	first-3-byte: charset [#"^(E0)" - #"^(EF)"]
	first-4-byte: charset [#"^(F0)" - #"^(F4)"]
	subsequent-byte: charset [#"^(80)" - #"^(BF)"]
	not-subsequent-byte: complement subsequent-byte
	invalid: charset [#"^(C0)" - #"^(C1)" #"^(F5)" - #"^(FF)"]
	
	;--------------------------
	;-     8-bit bitsets
	;
	;--------------------------
	x80-xBF: charset [#"^(80)" - #"^(BF)"]
	xA0-xBF: charset [#"^(A0)" - #"^(BF)"]
	xC0-xFF: charset [#"^(C0)" - #"^(FF)"]
	
	;--------------------------
	;-     reduced bitsets
	;
	;--------------------------
	ascii-less-ampltgt: charset [
		#"^(00)" - #"^(25)"
		#"^(27)" - #"^(3B)"
		#"^(3D)"
		#"^(3F)" - #"^(7F)"
	]
	ascii-less-cr-lf: charset [
		#"^(00)" - #"^(09)" #"^(0B)" - #"^(0C)" #"^(0E)" - #"^(7F)"
	]
	characters-less-gt: charset [
		#"^(00)" - #"^(3D)"
		#"^(3F)" - #"^(7F)"
	]
	
	;--------------------------
	;-     standard patterns
	;
	;--------------------------
	a-tag: ["<" some characters-less-gt ">"]
	a-utf-8-two-byte: [first-2-byte subsequent-byte]
	a-utf-8-three-byte: [first-3-byte 2 subsequent-byte]
	a-utf-8-four-byte: [first-4-byte 3 subsequent-byte]
	invalid-utf-8-two-byte: [first-2-byte not-subsequent-byte]
	invalid-utf-8-three-byte: [
		first-3-byte [
			subsequent-byte not-subsequent-byte
			|
			not-subsequent-byte subsequent-byte
			|
			2 not-subsequent-byte
		]
	] 
	invalid-utf-8-four-byte: [
		first-4-byte [
			subsequent-byte not-subsequent-byte subsequent-byte
			|
			subsequent-byte not-subsequent-byte not-subsequent-byte
			|
			subsequent-byte subsequent-byte not-subsequent-byte
			|
			not-subsequent-byte not-subsequent-byte subsequent-byte
			|
			not-subsequent-byte subsequent-byte not-subsequent-byte
			|
			not-subsequent-byte subsequent-byte subsequent-byte
			|
			3 not-subsequent-byte
		]
	]

	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         	bom?()
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
	bom?: make function! [
		{Checks a string to see if it starts with a Unicode Byte Order Mark (BOM).
		Returns one of the following:
		"utf-32be"
		"utf-32le"
		"utf-16be"
		"utf-16le"
		"utf-8"
		#[none]
		}
		str [string!]
	][
		
		foreach [encoding bom] BOM [
			if find/part str bom length? bom [
				return encoding
			]
		]
		
		#[none]
	]
	
	;--------------------------
	;-         	encoding?()
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
	encoding?: make function! [
		{Ascertains the character encoding of a string by applying a few rules of
		thumb.
		Returns the following:
		"us-ascii"
		"utf-8"
		"iso-8859-1"
		"macintosh"
		"windows-1252"
		One of the following may possibly be returned but only if there is a 
		Unicode Byte Order Mark at the beginning of the string:
		"utf-32be"
		"utf-32le"
		"utf-16be"
		"utf-16le"
		}
		str [string!]
		/local
		count-chars   {object to hold parse rules and reuslts to count the
		different types of characters in a string.}
		bom           {temporary variable to hold the type of BOM}
	][
		count-chars: make object! [
			
			;--------------------------
			;-             local
			;
			;--------------------------
			
			;--------------------------
			;-             accumulators
			;
			;--------------------------
			number-of: make object! [
				ascii: 0
				crs: 0
				crlfs: 0
				lfs: 0
				macroman: 0
				upper-80-9f: 0
				upper-a0-ff: 0
				utf-8-2: 0
				utf-8-3: 0
				utf-8-4: 0
				invalid-utf-8: 0
				
				utf-8-valid-patterns: copy []
				utf-8-invalid-patterns: copy []
			]
			
			;--------------------------
			;-             bitsets
			;
			;--------------------------
			macroman: charset [#"^(81)" #"^(8D)" #"^(90)" #"^(9D)"]
			
			
			;--------------------------
			;-             character sequences
			;
			;--------------------------
			ascii-chars: [some ascii-less-cr-lf]
			
			;--------------------------
			;-             rules
			;
			;--------------------------
			ascii-rule: [
				copy substr ascii-chars (
				number-of/ascii: number-of/ascii + length? substr
				)
			]
			
			byte-rule: [
				byte
				parse-input: (parse-input: back parse-input) :parse-input
				
			]
			
			cr-rule: [
				cr (
				number-of/crs: number-of/crs + 1
				number-of/ascii: number-of/ascii + 1
				)
			]
			
			crlf-rule: [
				crlf (
				number-of/crlfs: number-of/crlfs + 1
				number-of/crs: number-of/crs + 1
				number-of/lfs: number-of/lfs + 1
				number-of/ascii: number-of/ascii + 2
				)
			]
			
			lf-rule: [
				lf (
				number-of/lfs: number-of/lfs + 1
				number-of/ascii: number-of/ascii + 1
				)
			]
			
			macroman-rule: [
				macroman (
				number-of/macroman: number-of/macroman + 1
				number-of/upper-80-9f: number-of/upper-80-9f + 1
				)
			]
			
			upper-80-9f-rule: [
				ch128-159 (
				number-of/upper-80-9f: number-of/upper-80-9f + 1
				)
			]
			
			upper-a0-ff-rule: [
				ch160-255 (
				number-of/upper-a0-ff: number-of/upper-a0-ff + 1
				)
			]
			
			
			;--------------------------
			;-             invalid-utf-8-rule
			;
			;--------------------------
			invalid-utf-8-rule: [
				.here:
				copy bytes invalid (
					append number-of/utf-8-invalid-patterns index? .here
					append number-of/utf-8-invalid-patterns bytes
					number-of/invalid-utf-8: number-of/invalid-utf-8 + 1
				)
				;parse-input: (parse-input: back parse-input) :parse-input
				.here:
			]
			
			;--------------------------
			;-             invalid-utf-8-2-rule
			;
			;--------------------------
			invalid-utf-8-2-rule: [
				.here:
				copy bytes invalid-utf-8-two-byte (
					append number-of/utf-8-invalid-patterns index? .here
					append number-of/utf-8-invalid-patterns bytes
					number-of/invalid-utf-8: number-of/invalid-utf-8 + 1
				)
				;parse-input: (parse-input: back back parse-input) :parse-input
				.here:
			]
			
			;--------------------------
			;-             invalid-utf-8-3-rule
			;
			;--------------------------
			invalid-utf-8-3-rule: [
				.here:
				copy bytes invalid-utf-8-three-byte (
					append number-of/utf-8-invalid-patterns index? .here
					append number-of/utf-8-invalid-patterns bytes
					number-of/invalid-utf-8: number-of/invalid-utf-8 + 1
				)
				;parse-input: (parse-input: back back back parse-input) :parse-input
				.here:
			]
			
			;--------------------------
			;-             invalid-utf-8-4-rule
			;
			;--------------------------
			invalid-utf-8-4-rule: [
				.here:
				copy bytes invalid-utf-8-four-byte (
					append number-of/utf-8-invalid-patterns index? .here
					append number-of/utf-8-invalid-patterns bytes
					number-of/invalid-utf-8: number-of/invalid-utf-8 + 1
				)
				;parse-input: (parse-input: back back back back parse-input) :parse-input
				.here:
			]
			
			;--------------------------
			;-             utf-8-2-rule:
			;
			;--------------------------
			utf-8-2-rule: [
				.here:
				copy bytes a-utf-8-two-byte (
				append number-of/utf-8-valid-patterns index? .here
				append number-of/utf-8-valid-patterns bytes
					number-of/utf-8-2: number-of/utf-8-2 + 1
				)
				parse-input: (parse-input: back back parse-input) :parse-input
			]
			
			;--------------------------
			;-             utf-8-3-rule:
			;
			;--------------------------
			utf-8-3-rule: [
				.here:
				copy bytes a-utf-8-three-byte (
				append number-of/utf-8-valid-patterns index? .here
				append number-of/utf-8-valid-patterns bytes
					number-of/utf-8-3: number-of/utf-8-3 + 1
				)
				parse-input: (parse-input: back back back parse-input) :parse-input
			]
			
			;--------------------------
			;-             utf-8-4-rule:
			;
			;--------------------------
			utf-8-4-rule: [
				.here:
				copy bytes a-utf-8-four-byte (
				append number-of/utf-8-valid-patterns index? .here
				append number-of/utf-8-valid-patterns bytes
					number-of/utf-8-4: number-of/utf-8-4 + 1
				)
				parse-input: (parse-input: back back back back parse-input) :parse-input
			]
			
			;--------------------------
			;-             rules:
			;
			;--------------------------
			rules: [
				any [
					crlf-rule
					|
					[cr-rule | lf-rule]
					|
					[
						utf-8-2-rule
						|
						utf-8-3-rule
						|
						utf-8-4-rule
						|
						invalid-utf-8-rule
						|
						invalid-utf-8-2-rule
						|
						invalid-utf-8-3-rule
						|
						invalid-utf-8-4-rule
						|
						byte-rule
					]
					[
						ascii-rule
						|
						upper-a0-ff-rule
						|
						macroman-rule
						|
						upper-80-9f-rule
					]
				]
			]
		]
		
		;; check for a BOM
		if bom: bom? str [return bom]
		
		;; count the types of characters in the input string
		parse/all str count-chars/rules
		
		;print "====================================="
		;print "       Decoding input text"
		;print "====================================="
		;probe mold/all count-chars/number-of
		
		
		;; apply rules of thumb
		if count-chars/number-of/ascii = length? str [
			return "us-ascii"
		]
		
		if count-chars/number-of/invalid-utf-8 <
		( count-chars/number-of/utf-8-2 +
		count-chars/number-of/utf-8-3 +
		count-chars/number-of/utf-8-4
		)
		[
			return "utf-8"
		]
		
		if all [
			count-chars/number-of/upper-a0-ff > 0
			count-chars/number-of/upper-80-9f = 0
		][
			return "iso-8859-1"
		]
		
		if any [
			count-chars/number-of/macroman > 0
			all [
				count-chars/number-of/crs > 0
				count-chars/number-of/lfs = 0
			]
		][
			return "macintosh"
		]
		
		return "windows-1252"
		
	]   
	
	;--------------------------
	;-         	macroman-to-utf-8()
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
	macroman-to-utf-8: make function! [
		{
		Converts a MacRoman encoded string to UTF-8.
		Invalid characters are replaced
		}
		input-string [string!]
		/local
		extra-rules
		trans-table
	][
		;; translation table
		trans-table: [
			"^(80)" "^(C3)^(84)"
			"^(81)" "^(C3)^(85)"
			"^(82)" "^(C3)^(87)"
			"^(83)" "^(C3)^(89)"
			"^(84)" "^(C3)^(91)"
			"^(85)" "^(C3)^(96)"
			"^(86)" "^(C3)^(9C)"
			"^(87)" "^(C3)^(A1)"
			"^(88)" "^(C3)^(A0)"
			"^(89)" "^(C3)^(A2)"
			"^(8A)" "^(C3)^(A4)"
			"^(8B)" "^(C3)^(A3)"
			"^(8C)" "^(C3)^(A5)"
			"^(8D)" "^(C3)^(A7)"
			"^(8E)" "^(C3)^(A9)"
			"^(8F)" "^(C3)^(A8)"
			"^(90)" "^(C3)^(AA)"
			"^(91)" "^(C3)^(AB)"
			"^(92)" "^(C3)^(AD)"
			"^(93)" "^(C3)^(AC)"
			"^(94)" "^(C3)^(AE)"
			"^(95)" "^(C3)^(AF)"
			"^(96)" "^(C3)^(B1)"
			"^(97)" "^(C3)^(B3)"
			"^(98)" "^(C3)^(B2)"
			"^(99)" "^(C3)^(B4)"
			"^(9A)" "^(C3)^(B6)"
			"^(9B)" "^(C3)^(B5)"
			"^(9C)" "^(C3)^(BA)"
			"^(9D)" "^(C3)^(B9)"
			"^(9E)" "^(C3)^(BB)"
			"^(9F)" "^(C3)^(BC)"
			"^(A0)" "^(E2)^(80)^(A0)"
			"^(A1)" "^(C2)^(B0)"
			"^(A2)" "^(C2)^(A2)"
			"^(A3)" "^(C2)^(A3)"
			"^(A4)" "^(C2)^(A7)"
			"^(A5)" "^(E2)^(80)^(A2)"
			"^(A6)" "^(C2)^(B6)"
			"^(A7)" "^(C3)^(9F)"
			"^(A8)" "^(C2)^(AE)"
			"^(A9)" "^(C2)^(A9)"
			"^(AA)" "^(E2)^(84)^(A2)"
			"^(AB)" "^(C2)^(B4)"
			"^(AC)" "^(C2)^(A8)"
			"^(AD)" "^(E2)^(89)^(A0)"
			"^(AE)" "^(C3)^(86)"
			"^(AF)" "^(C3)^(98)"
			"^(B0)" "^(E2)^(88)^(9E)"
			"^(B1)" "^(C2)^(B1)"
			"^(B2)" "^(E2)^(89)^(A4)"
			"^(B3)" "^(E2)^(89)^(A5)"
			"^(B4)" "^(C2)^(A5)"
			"^(B5)" "^(C2)^(B5)"
			"^(B6)" "^(E2)^(88)^(82)"
			"^(B7)" "^(E2)^(88)^(91)"
			"^(B8)" "^(E2)^(88)^(8F)"
			"^(B9)" "^(CF)^(80)"
			"^(BA)" "^(E2)^(88)^(AB)"
			"^(BB)" "^(C2)^(AA)"
			"^(BC)" "^(C2)^(BA)"
			"^(BD)" "^(CE)^(A9)"
			"^(BE)" "^(C3)^(A6)"
			"^(BF)" "^(C3)^(B8)"
			"^(C0)" "^(C2)^(BF)"
			"^(C1)" "^(C2)^(A1)"
			"^(C2)" "^(C2)^(AC)"
			"^(C3)" "^(E2)^(88)^(9A)"
			"^(C4)" "^(C6)^(92)"
			"^(C5)" "^(E2)^(89)^(88)"
			"^(C6)" "^(E2)^(88)^(86)"
			"^(C7)" "^(C2)^(AB)"
			"^(C8)" "^(C2)^(BB)"
			"^(C9)" "^(E2)^(80)^(A6)"
			"^(CA)" "^(C2)^(A0)"
			"^(CB)" "^(C3)^(80)"
			"^(CC)" "^(C3)^(83)"
			"^(CD)" "^(C3)^(95)"
			"^(CE)" "^(C5)^(92)"
			"^(CF)" "^(C5)^(93)"
			"^(D0)" "^(E2)^(80)^(93)"
			"^(D1)" "^(E2)^(80)^(94)"
			"^(D2)" "^(E2)^(80)^(9C)"
			"^(D3)" "^(E2)^(80)^(9D)"
			"^(D4)" "^(E2)^(80)^(98)"
			"^(D5)" "^(E2)^(80)^(99)"
			"^(D6)" "^(C3)^(B7)"
			"^(D7)" "^(E2)^(97)^(8A)"
			"^(D8)" "^(C3)^(BF)"
			"^(D9)" "^(C5)^(B8)"
			"^(DA)" "^(E2)^(81)^(84)"
			"^(DB)" "^(E2)^(82)^(AC)"
			"^(DC)" "^(E2)^(80)^(B9)"
			"^(DD)" "^(E2)^(80)^(BA)"
			"^(DE)" "^(EF)^(AC)^(81)"
			"^(DF)" "^(EF)^(AC)^(82)"
			"^(E0)" "^(E2)^(80)^(A1)"
			"^(E1)" "^(C2)^(B7)"
			"^(E2)" "^(E2)^(80)^(9A)"
			"^(E3)" "^(E2)^(80)^(9E)"
			"^(E4)" "^(E2)^(80)^(B0)"
			"^(E5)" "^(C3)^(82)"
			"^(E6)" "^(C3)^(8A)"
			"^(E7)" "^(C3)^(81)"
			"^(E8)" "^(C3)^(8B)"
			"^(E9)" "^(C3)^(88)"
			"^(EA)" "^(C3)^(8D)"
			"^(EB)" "^(C3)^(8E)"
			"^(EC)" "^(C3)^(8F)"
			"^(ED)" "^(C3)^(8C)"
			"^(EE)" "^(C3)^(93)"
			"^(EF)" "^(C3)^(94)"
			"^(F0)" "^(EF)^(A3)^(BF)"
			"^(F1)" "^(C3)^(92)"
			"^(F2)" "^(C3)^(9A)"
			"^(F3)" "^(C3)^(9B)"
			"^(F4)" "^(C3)^(99)"
			"^(F5)" "^(C4)^(B1)"
			"^(F6)" "^(CB)^(86)"
			"^(F7)" "^(CB)^(9C)"
			"^(F8)" "^(C2)^(AF)"
			"^(F9)" "^(CB)^(98)"
			"^(FA)" "^(CB)^(99)"
			"^(FB)" "^(CB)^(9A)"
			"^(FC)" "^(C2)^(B8)"
			"^(FD)" "^(CB)^(9D)"
			"^(FE)" "^(CB)^(9B)"
			"^(FF)" "^(CB)^(87)"
		]
		
		;; Define the additional rules to be applied before the default rules
		extra-rules: [
			copy transfer ch128-255 (
			insert tail output-string select/case trans-table transfer
			)
		]
		
		iso-8859-to-utf-8/addl-rules input-string extra-rules
		
	]
	
	;--------------------------
	;-         	mail-encoding?()
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
	mail-encoding?: make function! [
		{Returns the charset of the first Content-type entry in a mail message}
		mail-str [string!]
		/local
		cset    ;; character set
	][
		
		either parse/all mail-str [
			to "Content-type" thru "charset=" copy cset some letter-hyphen to end end
		][
			lowercase cset
		][
			#[none]
		]
	]   
	
	;--------------------------
	;-         	iso-8859-1-to-html()
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
	iso-8859-1-to-html: make function! [
		{Converts an ISO-8859-1 encoded string to pure ASCII with characters 128
		and above converted to html escape sequences}
		input-string [string!]
		/esc-lt-gt-amp  {Escape <, > and &}
		/keep-tags  {leave < ....> alone}
		/local
		output-string
		rule
		transfer
		escape
		no-refinement-rule
		esc-lt-gt-amp-rule
		keep-tags-rule
		standard-rule
		variable-rule
	][
		
		no-refinement-rule: [
			copy transfer  [some ascii] (
			insert tail output-string transfer
			)
		]
		
		esc-lt-gt-amp-rule: [
			"<" (insert tail output-string "&lt;")
			|
			">" (insert tail output-string "&gt;")
			|
			"&" (insert tail output-string "&amp;")
			|
			copy transfer [some ascii-less-ampltgt] (
			;print "here"
			insert tail output-string transfer
			)
		]
		
		keep-tags-rule: [
			copy transfer a-tag (
			insert tail output-string transfer
			)
		]
		
		;; rule to deal with characters above 127
		standard-rule: [
			some ch128-159         ;; ignore characters in this range
			|
			copy escape ch160-255 (
			insert tail output-string join "&#" [to integer! first escape ";"]
			)
			|
			skip
		]
		
		;; assemble the parse rule according to the refinements
		
		either esc-lt-gt-amp [
			either keep-tags [
				rule: [
					any [
						keep-tags-rule
						|
						esc-lt-gt-amp-rule
						|
						standard-rule
					]
				]
			][
				rule: [
					any [
						esc-lt-gt-amp-rule
						|
						standard-rule
					]
				]
			]
		][
			rule: [
				any [
					no-refinement-rule
					|
					standard-rule
				]
			]
		]
		
		output-string: copy ""
		parse/all input-string rule
		head output-string
		
	]
	
	;--------------------------
	;-         	iso-8859-to-utf-8()
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
	iso-8859-to-utf-8: make function! [
		{
		Converts an ISO-8859 encoded string to UTF-8.
		The default processing assumes the input is ISO-8859-1
		The /addl-rules refinement allows rules to be supplied for other ecodings
		}
		input-string [string!]
		/addl-rules
		extra-rules [block!]
		/local
		output-string
		rule
		ascii-rule
		rule-80-BF
		C0-FF-rule
		transfer
	][
		;; temporary variables and constants
		output-string: copy ""
		transfer: none
		
		;; sub-rules
		ascii-rule: [
			copy transfer [some ascii] (
			insert tail output-string transfer
			)
		]
		
		rule-80-BF: [
			;; characters in the range 80-BF relate to C280-C2BF
			copy transfer x80-xBF (
			insert tail output-string compose [#"^(C2)" (transfer)]
			)
		]
		
		C0-FF-rule: [
			;; characters in the range C0-FF relate to C380-C3BF
			copy transfer xC0-xFF (
			insert tail output-string compose [
				#"^(C3)" (#"^(40)" xor to char! transfer)
			]
			)
		]
		
		rule: [
			any [
				ascii-rule
				|
				rule-80-BF
				|
				C0-FF-rule
			]
		]
		
		;; add the extra rules to the rule
		if addl-rules [
			bind extra-rules 'output-string
			insert find/tail second rule 'ascii-rule [| extra-rules]
		]
		
		parse/all/case input-string rule
		head output-string
	]
	
	;--------------------------
	;-         	iso-8859-1-to-utf-8()
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
	iso-8859-1-to-utf-8: make function! [
		{
		Converts an ISO-8859-1 encoded string to UTF-8.
		}
		input-string [string!]
	][
		iso-8859-to-utf-8 input-string
	]
	
	;--------------------------
	;-         	iso-8859-2-to-utf-8()
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
	iso-8859-2-to-utf-8: make function! [
		{
		Converts an ISO-8859-2 encoded string to UTF-8.
		Invalid characters are replaced
		}
		input-string [string!]
		/local
		extra-rules
		trans-table
	][
		;; translation table
		trans-table: [
			"^(A0)" "^(C2)^(A0)"
			"^(A1)" "^(C4)^(84)"
			"^(A2)" "^(CB)^(98)"
			"^(A3)" "^(C5)^(81)"
			"^(A4)" "^(C2)^(A4)"
			"^(A5)" "^(C4)^(BD)"
			"^(A6)" "^(C5)^(9A)"
			"^(A7)" "^(C2)^(A7)"
			"^(A8)" "^(C2)^(A8)"
			"^(A9)" "^(C5)^(A0)"
			"^(AA)" "^(C5)^(9E)"
			"^(AB)" "^(C5)^(A4)"
			"^(AC)" "^(C5)^(B9)"
			"^(AD)" "^(C2)^(AD)"
			"^(AE)" "^(C5)^(BD)"
			"^(AF)" "^(C5)^(BB)"
			"^(B0)" "^(C2)^(B0)"
			"^(B1)" "^(C4)^(85)"
			"^(B2)" "^(CB)^(9B)"
			"^(B3)" "^(C5)^(82)"
			"^(B4)" "^(C2)^(B4)"
			"^(B5)" "^(C4)^(BE)"
			"^(B6)" "^(C5)^(9B)"
			"^(B7)" "^(CB)^(87)"
			"^(B8)" "^(C2)^(B8)"
			"^(B9)" "^(C5)^(A1)"
			"^(BA)" "^(C5)^(9F)"
			"^(BB)" "^(C5)^(A5)"
			"^(BC)" "^(C5)^(BA)"
			"^(BD)" "^(CB)^(9D)"
			"^(BE)" "^(C5)^(BE)"
			"^(BF)" "^(C5)^(BC)"
			"^(C0)" "^(C5)^(94)"
			"^(C1)" "^(C3)^(81)"
			"^(C2)" "^(C3)^(82)"
			"^(C3)" "^(C4)^(82)"
			"^(C4)" "^(C3)^(84)"
			"^(C5)" "^(C4)^(B9)"
			"^(C6)" "^(C4)^(86)"
			"^(C7)" "^(C3)^(87)"
			"^(C8)" "^(C4)^(8C)"
			"^(C9)" "^(C3)^(89)"
			"^(CA)" "^(C4)^(98)"
			"^(CB)" "^(C3)^(8B)"
			"^(CC)" "^(C4)^(9A)"
			"^(CD)" "^(C3)^(8D)"
			"^(CE)" "^(C3)^(8E)"
			"^(CF)" "^(C4)^(8E)"
			"^(D0)" "^(C4)^(90)"
			"^(D1)" "^(C5)^(83)"
			"^(D2)" "^(C5)^(87)"
			"^(D3)" "^(C3)^(93)"
			"^(D4)" "^(C3)^(94)"
			"^(D5)" "^(C5)^(90)"
			"^(D6)" "^(C3)^(96)"
			"^(D7)" "^(C3)^(97)"
			"^(D8)" "^(C5)^(98)"
			"^(D9)" "^(C5)^(AE)"
			"^(DA)" "^(C3)^(9A)"
			"^(DB)" "^(C5)^(B0)"
			"^(DC)" "^(C3)^(9C)"
			"^(DD)" "^(C3)^(9D)"
			"^(DE)" "^(C5)^(A2)"
			"^(DF)" "^(C3)^(9F)"
			"^(E0)" "^(C5)^(95)"
			"^(E1)" "^(C3)^(A1)"
			"^(E2)" "^(C3)^(A2)"
			"^(E3)" "^(C4)^(83)"
			"^(E4)" "^(C3)^(A4)"
			"^(E5)" "^(C4)^(BA)"
			"^(E6)" "^(C4)^(87)"
			"^(E7)" "^(C3)^(A7)"
			"^(E8)" "^(C4)^(8D)"
			"^(E9)" "^(C3)^(A9)"
			"^(EA)" "^(C4)^(99)"
			"^(EB)" "^(C3)^(AB)"
			"^(EC)" "^(C4)^(9B)"
			"^(ED)" "^(C3)^(AD)"
			"^(EE)" "^(C3)^(AE)"
			"^(EF)" "^(C4)^(8F)"
			"^(F0)" "^(C4)^(91)"
			"^(F1)" "^(C5)^(84)"
			"^(F2)" "^(C5)^(88)"
			"^(F3)" "^(C3)^(B3)"
			"^(F4)" "^(C3)^(B4)"
			"^(F5)" "^(C5)^(91)"
			"^(F6)" "^(C3)^(B6)"
			"^(F7)" "^(C3)^(B7)"
			"^(F8)" "^(C5)^(99)"
			"^(F9)" "^(C5)^(AF)"
			"^(FA)" "^(C3)^(BA)"
			"^(FB)" "^(C5)^(B1)"
			"^(FC)" "^(C3)^(BC)"
			"^(FD)" "^(C3)^(BD)"
			"^(FE)" "^(C5)^(A3)"
			"^(FF)" "^(CB)^(99)"
		]
		
		;; Define the additional rules to be applied before the default rules
		extra-rules: [
			copy transfer ch160-255 (
			insert tail output-string select/case trans-table transfer
			)
		]
		
		iso-8859-to-utf-8/addl-rules input-string extra-rules
		
	]
	
	;--------------------------
	;-         	iso-8859-9-to-utf-8()
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
	iso-8859-9-to-utf-8: make function! [
		{
		Converts an ISO-8859-9 encoded string to UTF-8.
		}
		input-string [string!]
		/local
		extra-rules
	][
		;; Define the additional rules to be applied before the default rules
		extra-rules: [
			#"^(D0)" (insert tail output-string {^(C4)^(9E)}) 
			|
			#"^(DD)" (insert tail output-string {^(C4)^(B0)})
			|
			#"^(DE)" (insert tail output-string {^(C5)^(9E)})
			|
			#"^(F0)" (insert tail output-string {^(C4)^(9F)})
			|
			#"^(FD)" (insert tail output-string {^(C4)^(B1)})
			|
			#"^(FE)" (insert tail output-string {^(C5)^(9F)})
		]
		
		iso-8859-to-utf-8/addl-rules input-string extra-rules
		
	]
	
	;--------------------------
	;-         	iso-8859-15-to-utf-8()
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
	iso-8859-15-to-utf-8: make function! [
		{
		Converts an ISO-8859-15 encoded string to UTF-8.
		}
		input-string [string!]
		/local
		extra-rules
	][
		;; Define the additional rules to be applied before the default rules
		extra-rules: [
			#"^(A4)" (insert tail output-string {^(E2)^(82)^(AC)})
			|
			#"^(A6)" (insert tail output-string {^(C5)^(A0)})
			|
			#"^(A8)" (insert tail output-string {^(C5)^(A1)})
			|
			#"^(B4)" (insert tail output-string {^(C5)^(BD)})
			|
			#"^(B8)" (insert tail output-string {^(C5)^(BE)})
			|
			#"^(BC)" (insert tail output-string {^(C5)^(92)})
			|
			#"^(BD)" (insert tail output-string {^(C5)^(94)})
			|
			#"^(BE)" (insert tail output-string {^(C5)^(B8)})
		]
		
		iso-8859-to-utf-8/addl-rules input-string extra-rules
		
	]
	
	;--------------------------
	;-         	strip-bom()
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
	strip-bom: make function! [
		{Strips any BOM from the start of a string and returns the string.
		Note: the input string is modified.
		}
		str [string!]
		/local
		lcl-bom "store result of bom?"
	][
		either lcl-bom: bom? str [
			remove/part str length? BOM/:lcl-bom
		][
			str
		]
	]
	
	;--------------------------
	;-         	utf-8-to-iso-8859()
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
	utf-8-to-iso-8859: make function! [
		{
		Converts a UTF-8 encoded string to ISO-8859 and similar eoncodings
		These are a lossy conversion:
		Characters that cannot be converted are changed to "?"
		(That includes any invalid UTF-8 characters in the input)
		The default processing assumes the input is ISO-8859-1
		The /addl-rules refinement allows rules to be supplied for other ecodings
		}
		input-string [string!]
		/addl-rules
		extra-rules [block!]
		/local
		output-string
		rule
		ascii-rule
		nbsp-rule
		xA0-xBF
		C2A0-C2BF
		C2A0-C2BF-rule
		x80-xBF
		C380-C3BF
		C380-C3BF-rule
		transfer
	][
		;; temporary variables and constants
		output-string: copy ""
		transfer: none
		
		;; bit sets
		xA0-xBF: charset [#"^(A0)" - #"^(BF)"]
		x80-xBF: charset [#"^(80)" - #"^(BF)"]
		
		;; character sequences
		C2A0-C2BF: [#"^(C2)" xA0-xBF]
		C380-C3BF: [#"^(C3)" x80-xBF]
		
		;; sub-rules
		ascii-rule: [
			copy transfer [some ascii] (
			insert tail output-string transfer
			)
		]
		
		C2A0-C2BF-rule: [
			;; characters in the range C2A0-C2BF relate to A0-BF
			copy transfer C2A0-C2BF (insert tail output-string second transfer)
		]
		
		C380-C3BF-rule: [
			;; characters in the range C380-C3BF relate to C0-FF
			copy transfer C380-C3BF (
			insert tail output-string #"^(40)" or second transfer 
			)
		]
		
		rule: [
			any [
				ascii-rule
				|
				C2A0-C2BF-rule
				|
				C380-C3BF-rule
				|
				[
					[a-utf-8-two-byte | a-utf-8-three-byte | a-utf-8-four-byte] (
					insert tail output-string replacement-char
					)
				]
				|
				skip (insert tail output-string replacement-char)
			]
		]
		
		;; add the extra rules to the rule
		if addl-rules [
			bind extra-rules 'output-string
			insert find/tail second rule 'ascii-rule [| extra-rules]
		]
		
		parse/all/case input-string rule
		head output-string
	]
	
	;--------------------------
	;-         	utf-8-to-iso-8859-1()
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
	utf-8-to-iso-8859-1: make function! [
		{
		Converts a UTF-8 encoded string to ISO-8859-1.
		This is a lossy conversion:
		Characters that cannot be converted are changed to "?"
		(That includes any invalid UTF-8 characters in the input)
		}
		input-string [string!]
	][
		utf-8-to-iso-8859 input-string
	]
	
	;--------------------------
	;-         	utf-8-to-iso-8859-15()
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
	utf-8-to-iso-8859-15: make function! [
		{
		Converts a UTF-8 encoded string to ISO-8859-15.
		This is a lossy conversion:
		Characters that cannot be converted are changed to "?"
		(That includes any invalid UTF-8 characters in the input)
		}
		input-string [string!]
		/local
		extra-rules
	][
		;; Define the additional rules to be applied before the default rules
		extra-rules: [
			{^(E2)^(82)^(AC)} (insert tail output-string #"^(A4)")
			|
			{^(C5)^(A0)} (insert tail output-string #"^(A6)")
			|
			{^(C5)^(A1)} (insert tail output-string #"^(A8)")
			|
			{^(C5)^(BD)} (insert tail output-string #"^(B4)")
			|
			{^(C5)^(BE)} (insert tail output-string #"^(B8)")
			|
			{^(C5)^(92)} (insert tail output-string #"^(BC)")
			|
			{^(C5)^(94)} (insert tail output-string #"^(BD)")
			|
			{^(C5)^(B8)} (insert tail output-string #"^(BE)")
			|
			{^(C3)^(27)} (insert tail output-string #"^(F4)")
		]
		
		utf-8-to-iso-8859/addl-rules input-string extra-rules
		
	]
	
	;--------------------------
	;-         	utf-8-to-macroman()
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
	utf-8-to-macroman: make function! [
		{
		Converts a UTF-8 encoded string to MacRoman.
		This is a lossy conversion:
		Characters that cannot be converted are changed to "?"
		(That includes any invalid UTF-8 characters in the input)
		}
		input-string [string!]
		/local
		extra-rules
		trans-table
	][
		
		;; Define the additional rules to be applied before the default rules
		extra-rules: [
			"^(C3)^(84)"          (insert tail output-string #"^(80)") |
			"^(C3)^(85)"          (insert tail output-string #"^(81)") |
			"^(C3)^(87)"          (insert tail output-string #"^(82)") |
			"^(C3)^(89)"          (insert tail output-string #"^(83)") |
			"^(C3)^(91)"          (insert tail output-string #"^(84)") |
			"^(C3)^(96)"          (insert tail output-string #"^(85)") |
			"^(C3)^(9C)"          (insert tail output-string #"^(86)") |
			"^(C3)^(A1)"          (insert tail output-string #"^(87)") |
			"^(C3)^(A0)"          (insert tail output-string #"^(88)") |
			"^(C3)^(A2)"          (insert tail output-string #"^(89)") |
			"^(C3)^(A4)"          (insert tail output-string #"^(8A)") |
			"^(C3)^(A3)"          (insert tail output-string #"^(8B)") |
			"^(C3)^(A5)"          (insert tail output-string #"^(8C)") |
			"^(C3)^(A7)"          (insert tail output-string #"^(8D)") |
			"^(C3)^(A9)"          (insert tail output-string #"^(8E)") |
			"^(C3)^(A8)"          (insert tail output-string #"^(8F)") |
			"^(C3)^(AA)"          (insert tail output-string #"^(90)") |
			"^(C3)^(AB)"          (insert tail output-string #"^(91)") |
			"^(C3)^(AD)"          (insert tail output-string #"^(92)") |
			"^(C3)^(AC)"          (insert tail output-string #"^(93)") |
			"^(C3)^(AE)"          (insert tail output-string #"^(94)") |
			"^(C3)^(AF)"          (insert tail output-string #"^(95)") |
			"^(C3)^(B1)"          (insert tail output-string #"^(96)") |
			"^(C3)^(B3)"          (insert tail output-string #"^(97)") |
			"^(C3)^(B2)"          (insert tail output-string #"^(98)") |
			"^(C3)^(B4)"          (insert tail output-string #"^(99)") |
			"^(C3)^(B6)"          (insert tail output-string #"^(9A)") |
			"^(C3)^(B5)"          (insert tail output-string #"^(9B)") |
			"^(C3)^(BA)"          (insert tail output-string #"^(9C)") |
			"^(C3)^(B9)"          (insert tail output-string #"^(9D)") |
			"^(C3)^(BB)"          (insert tail output-string #"^(9E)") |
			"^(C3)^(BC)"          (insert tail output-string #"^(9F)") |
			"^(E2)^(80)^(A0)"     (insert tail output-string #"^(A0)") |
			"^(C2)^(B0)"          (insert tail output-string #"^(A1)") |
			"^(C2)^(A2)"          (insert tail output-string #"^(A2)") |
			"^(C2)^(A3)"          (insert tail output-string #"^(A3)") |
			"^(C2)^(A7)"          (insert tail output-string #"^(A4)") |
			"^(E2)^(80)^(A2)"     (insert tail output-string #"^(A5)") |
			"^(C2)^(B6)"          (insert tail output-string #"^(A6)") |
			"^(C3)^(9F)"          (insert tail output-string #"^(A7)") |
			"^(C2)^(AE)"          (insert tail output-string #"^(A8)") |
			"^(C2)^(A9)"          (insert tail output-string #"^(A9)") |
			"^(E2)^(84)^(A2)"     (insert tail output-string #"^(AA)") |
			"^(C2)^(B4)"          (insert tail output-string #"^(AB)") |
			"^(C2)^(A8)"          (insert tail output-string #"^(AC)") |
			"^(E2)^(89)^(A0)"     (insert tail output-string #"^(AD)") |
			"^(C3)^(86)"          (insert tail output-string #"^(AE)") |
			"^(C3)^(98)"          (insert tail output-string #"^(AF)") |
			"^(E2)^(88)^(9E)"     (insert tail output-string #"^(B0)") |
			"^(C2)^(B1)"          (insert tail output-string #"^(B1)") |
			"^(E2)^(89)^(A4)"     (insert tail output-string #"^(B2)") |
			"^(E2)^(89)^(A5)"     (insert tail output-string #"^(B3)") |
			"^(C2)^(A5)"          (insert tail output-string #"^(B4)") |
			"^(C2)^(B5)"          (insert tail output-string #"^(B5)") |
			"^(E2)^(88)^(82)"     (insert tail output-string #"^(B6)") |
			"^(E2)^(88)^(91)"     (insert tail output-string #"^(B7)") |
			"^(E2)^(88)^(8F)"     (insert tail output-string #"^(B8)") |
			"^(CF)^(80)"          (insert tail output-string #"^(B9)") |
			"^(E2)^(88)^(AB)"     (insert tail output-string #"^(BA)") |
			"^(C2)^(AA)"          (insert tail output-string #"^(BB)") |
			"^(C2)^(BA)"          (insert tail output-string #"^(BC)") |
			"^(CE)^(A9)"          (insert tail output-string #"^(BD)") |
			"^(C3)^(A6)"          (insert tail output-string #"^(BE)") |
			"^(C3)^(B8)"          (insert tail output-string #"^(BF)") |
			"^(C2)^(BF)"          (insert tail output-string #"^(C0)") |
			"^(C2)^(A1)"          (insert tail output-string #"^(C1)") |
			"^(C2)^(AC)"          (insert tail output-string #"^(C2)") |
			"^(E2)^(88)^(9A)"     (insert tail output-string #"^(C3)") |
			"^(C6)^(92)"          (insert tail output-string #"^(C4)") |
			"^(E2)^(89)^(88)"     (insert tail output-string #"^(C5)") |
			"^(E2)^(88)^(86)"     (insert tail output-string #"^(C6)") |
			"^(C2)^(AB)"          (insert tail output-string #"^(C7)") |
			"^(C2)^(BB)"          (insert tail output-string #"^(C8)") |
			"^(E2)^(80)^(A6)"     (insert tail output-string #"^(C9)") |
			"^(C2)^(A0)"          (insert tail output-string #"^(CA)") |
			"^(C3)^(80)"          (insert tail output-string #"^(CB)") |
			"^(C3)^(83)"          (insert tail output-string #"^(CC)") |
			"^(C3)^(95)"          (insert tail output-string #"^(CD)") |
			"^(C5)^(92)"          (insert tail output-string #"^(CE)") |
			"^(C5)^(93)"          (insert tail output-string #"^(CF)") |
			"^(E2)^(80)^(93)"     (insert tail output-string #"^(D0)") |
			"^(E2)^(80)^(94)"     (insert tail output-string #"^(D1)") |
			"^(E2)^(80)^(9C)"     (insert tail output-string #"^(D2)") |
			"^(E2)^(80)^(9D)"     (insert tail output-string #"^(D3)") |
			"^(E2)^(80)^(98)"     (insert tail output-string #"^(D4)") |
			"^(E2)^(80)^(99)"     (insert tail output-string #"^(D5)") |
			"^(C3)^(B7)"          (insert tail output-string #"^(D6)") |
			"^(E2)^(97)^(8A)"     (insert tail output-string #"^(D7)") |
			"^(C3)^(BF)"          (insert tail output-string #"^(D8)") |
			"^(C5)^(B8)"          (insert tail output-string #"^(D9)") |
			"^(E2)^(81)^(84)"     (insert tail output-string #"^(DA)") |
			"^(E2)^(82)^(AC)"     (insert tail output-string #"^(DB)") |
			"^(E2)^(80)^(B9)"     (insert tail output-string #"^(DC)") |
			"^(E2)^(80)^(BA)"     (insert tail output-string #"^(DD)") |
			"^(EF)^(AC)^(81)"     (insert tail output-string #"^(DE)") |
			"^(EF)^(AC)^(82)"     (insert tail output-string #"^(DF)") |
			"^(E2)^(80)^(A1)"     (insert tail output-string #"^(E0)") |
			"^(C2)^(B7)"          (insert tail output-string #"^(E1)") |
			"^(E2)^(80)^(9A)"     (insert tail output-string #"^(E2)") |
			"^(E2)^(80)^(9E)"     (insert tail output-string #"^(E3)") |
			"^(E2)^(80)^(B0)"     (insert tail output-string #"^(E4)") |
			"^(C3)^(82)"          (insert tail output-string #"^(E5)") |
			"^(C3)^(8A)"          (insert tail output-string #"^(E6)") |
			"^(C3)^(81)"          (insert tail output-string #"^(E7)") |
			"^(C3)^(8B)"          (insert tail output-string #"^(E8)") |
			"^(C3)^(88)"          (insert tail output-string #"^(E9)") |
			"^(C3)^(8D)"          (insert tail output-string #"^(EA)") |
			"^(C3)^(8E)"          (insert tail output-string #"^(EB)") |
			"^(C3)^(8F)"          (insert tail output-string #"^(EC)") |
			"^(C3)^(8C)"          (insert tail output-string #"^(ED)") |
			"^(C3)^(93)"          (insert tail output-string #"^(EE)") |
			"^(C3)^(94)"          (insert tail output-string #"^(EF)") |
			"^(EF)^(A3)^(BF)"     (insert tail output-string #"^(F0)") |
			"^(C3)^(92)"          (insert tail output-string #"^(F1)") |
			"^(C3)^(9A)"          (insert tail output-string #"^(F2)") |
			"^(C3)^(9B)"          (insert tail output-string #"^(F3)") |
			"^(C3)^(99)"          (insert tail output-string #"^(F4)") |
			"^(C4)^(B1)"          (insert tail output-string #"^(F5)") |
			"^(CB)^(86)"          (insert tail output-string #"^(F6)") |
			"^(CB)^(9C)"          (insert tail output-string #"^(F7)") |
			"^(C2)^(AF)"          (insert tail output-string #"^(F8)") |
			"^(CB)^(98)"          (insert tail output-string #"^(F9)") |
			"^(CB)^(99)"          (insert tail output-string #"^(FA)") |
			"^(CB)^(9A)"          (insert tail output-string #"^(FB)") |
			"^(C2)^(B8)"          (insert tail output-string #"^(FC)") |
			"^(CB)^(9D)"          (insert tail output-string #"^(FD)") |
			"^(CB)^(9B)"          (insert tail output-string #"^(FE)") |
			"^(CB)^(87)"          (insert tail output-string #"^(FF)") 
		]
		
		;; Define the additional rules to be applied before the default rules
		
		
		utf-8-to-iso-8859/addl-rules input-string extra-rules
		
	]
	
	;--------------------------
	;-         	utf-8-to-win-1252()
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
	utf-8-to-win-1252: make function! [
		{
		Converts a win-1252 encoded string to UTF-8.
		This is a lossy conversion:
		Characters that cannot be converted are changed to "?"
		(That includes any invalid UTF-8 characters in the input)
		}
		input-string [string!]
		/local
		extra-rules
		trans-table
	][
		;; Define the additional rules to be applied before the default rules
		extra-rules: [
			;{^(E2)^(82)^(A0)}     (insert tail output-string #"^(80)") | ; error euro.
			{^(E2)^(82)^(AC)}     (insert tail output-string #"^(80)") | 
			{^(E2)^(80)^(9A)}     (insert tail output-string #"^(82)") |
			{^(C6)^(92)}          (insert tail output-string #"^(83)") |
			{^(E2)^(80)^(9E)}     (insert tail output-string #"^(84)") |
			{^(E2)^(80)^(A6)}     (insert tail output-string #"^(85)") |
			{^(E2)^(80)^(A0)}     (insert tail output-string #"^(86)") |
			{^(E2)^(80)^(A1)}     (insert tail output-string #"^(87)") |
			{^(CB)^(86)}          (insert tail output-string #"^(88)") |
			{^(E2)^(80)^(B0)}     (insert tail output-string #"^(89)") |
			{^(C5)^(A0)}          (insert tail output-string #"^(8A)") |
			{^(E2)^(80)^(B9)}     (insert tail output-string #"^(8B)") |
			{^(C5)^(92)}          (insert tail output-string #"^(8C)") |
			{^(C5)^(BD)}          (insert tail output-string #"^(8E)") |
			{^(E2)^(80)^(98)}     (insert tail output-string #"^(91)") |
			;{^(E2)^(80)^(99)}     (insert tail output-string #"^(92)") |
			{^(E2)^(80)^(9C)}     (insert tail output-string #"^(93)") |
			{^(E2)^(80)^(9D)}     (insert tail output-string #"^(94)") |
			{^(E2)^(80)^(A2)}     (insert tail output-string #"^(95)") |
			{^(E2)^(80)^(93)}     (insert tail output-string #"^(96)") |
			{^(E2)^(84)^(84)}     (insert tail output-string #"^(97)") |
			{^(CB)^(96)}          (insert tail output-string #"^(98)") |
			{^(E2)^(84)^(A2)}     (insert tail output-string #"^(99)") |
			{^(C5)^(A1)}          (insert tail output-string #"^(9A)") |
			{^(E2)^(80)^(BA)}     (insert tail output-string #"^(9B)") |
			;{^(C5)^(93)}          (insert tail output-string #"^(9C)") |
			{^(C5)^(BE)}          (insert tail output-string #"^(9E)") |
			{^(C5)^(B8)}          (insert tail output-string #"^(9F)") |
			{^(C3)^(27)} 		 (insert tail output-string #"^(F4)") |
			{^(C2)^(27)} 		 (insert tail output-string rejoin [ #"^(27)" ] ) |   ;This replaces a utf-8 quote sequence with a quote.
			{^(C5)^(93)} 		 (insert tail output-string rejoin [ #"^(6F)" #"^(65)"] ) |
			
			
			{^(E2)^(80)^(99)} 	 (insert tail output-string #"^(27)" )
		]
		
		utf-8-to-iso-8859/addl-rules input-string extra-rules
		
	]
	
	;--------------------------
	;-         	win-1252-to-utf-8()
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
	win-1252-to-utf-8: make function! [
		{
		Converts a win-1252 encoded string to UTF-8.
		Invalid characters are replaced
		}
		input-string [string!]
		/local
		extra-rules
		trans-table
	][
		;; translation table
		trans-table: compose [
			;"^(80)" {^(E2)^(82)^(A0)} ; error ... 
			"^(80)" {^(E2)^(82)^(AC)} ; error ... 
			"^(81)" (replacement-char)
			"^(82)" {^(E2)^(80)^(9A)}
			"^(83)" {^(C6)^(92)}
			"^(84)" {^(E2)^(80)^(9E)}
			"^(85)" {^(E2)^(80)^(A6)}
			"^(86)" {^(E2)^(80)^(A0)}
			"^(87)" {^(E2)^(80)^(A1)}
			"^(88)" {^(CB)^(86)}
			"^(89)" {^(E2)^(80)^(B0)}
			"^(8A)" {^(C5)^(A0)}
			"^(8B)" {^(E2)^(80)^(B9)}
			"^(8C)" {^(C5)^(92)}
			"^(8D)" (replacement-char)
			"^(8E)" {^(C5)^(BD)}
			"^(8F)" (replacement-char)
			"^(90)" (replacement-char)
			"^(91)" {^(E2)^(80)^(98)}
			"^(92)" {^(E2)^(80)^(99)}
			"^(93)" {^(E2)^(80)^(9C)}
			"^(94)" {^(E2)^(80)^(9D)}
			"^(95)" {^(E2)^(80)^(A2)}
			"^(96)" {^(E2)^(80)^(93)}
			"^(97)" {^(E2)^(84)^(84)}
			"^(98)" {^(CB)^(96)}
			"^(99)" {^(E2)^(84)^(A2)}
			"^(9A)" {^(C5)^(A1)}
			"^(9B)" {^(E2)^(80)^(BA)}
			"^(9C)" {^(C5)^(93)}
			"^(9D)" (replacement-char)
			"^(9E)" {^(C5)^(BE)}
			"^(9F)" {^(C5)^(B8)}
		]
		
		;; Define the additional rules to be applied before the default rules
		extra-rules: [
			copy transfer ch128-159 (
			insert tail output-string select/case trans-table transfer
			)
		]
		
		iso-8859-to-utf-8/addl-rules input-string extra-rules
		
	]
	
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------
