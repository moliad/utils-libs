rebol [
	title: "C struct binary loader"
	file: %utils-structs.r
	version: 1.0.0
	date: 2016-01-03
	author: "Maxim Olivier-Adlhoch"

	; -- slim - Library Manager --
	slim-name: 'utils-structs
	slim-version: 1.2.1
	slim-prefix: none
]

;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- STRUCTOR-LIB
;
;-----------------------------------------------------------------------------------------------------------
slim/register [
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     LOCALS
	;
	; values which should not pollute the global namespace
	;-----------------------------------------------------------------------------------------------------------
	.here: .type: .sizeof: .array-count: .array?: .value: .endianness: .loadtype: .loadspec: none
	.opt: .optval: .scalar?: none

	;                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     CLASSES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-         !member [...]
	;--------------------------
	!member: context [
		type:	none
		sizeof: 0  ; byte size of each atom.  1 for C strings  2 for wide chars, and respective int & float sizes as usual.
		count:  1  ; number of atoms for this member. when non-0 is either an array or a word to lookup (in current struct) for count.
		array?: none ; is this an array (count may be 1 and still be an array)
		value:  none ; the REBOL loaded value.  will store the transient binary! while its being loaded.
		endianness: none ; is platform-endian by default. how to load scalar values. strings are always in byte order.
		loadtype: none ; when loadtype is NONE!, it uses a default 'LOADTYPE for each 'TYPE.
		loadspec: none ; not always required. is only set when loadtype is also set.
		scalar?: true  ; things are all scalar by default.
	]
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     PRESETS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         platform-endianness:
	;
	; indicates the default expected endian format used by this platform, usualy is set by CPU type.
	;
	; should be improved to include per platform switch. 
	;
	;   note: x86 & x64 CPUs are little endian.    MIPS, PPV are big-endian.
	;
	; each struct starts off its magic expecting this format by default, setup endinanness explicitely
	; by adding the proper endianness keyword at the start (or even midway!) of your struct spec.
	;
	;      #LITTLE-ENDIAN  or  #BIG-ENDIAN
	;
	; you can also return to the default by using:
	;
	;      #PLATFORM-ENDIAN
	;--------------------------
	platform-endianness: 'little-endian 
	
	;--------------------------
	;-         platform-ptr-size:
	;--------------------------
	platform-ptr-size: 4  ;  (should be set to 8 on 64 bit builds)
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     Pod Specs
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         =pod-type=:
	;
	; POD "plain old data" types, basic C types.
	;--------------------------
	=pod-type=: [
		(.sizeof: none)
		[
			  'char		(.sizeof: 1 )
			| 'short	(.sizeof: 2)
			| 'long		(.sizeof: 4)
			| 'int		(.sizeof: 4)
			| 'float	(.sizeof: 4)
			| 'double	(.sizeof: 8)
			
			; MS typedefs
			| 'BYTE		(.sizeof: 1) ; should be unsigned.
			| 'WORD		(.sizeof: 2)
			| 'DWORD    (.sizeof: 4)
		]
		
		
		;---
		; pointer types. 
		| [
			'char*	(.sizeof: platform-ptr-size)
			| 'short*	(.sizeof: platform-ptr-size)
			| 'word*	(.sizeof: platform-ptr-size)
			| 'long*	(.sizeof: platform-ptr-size)
			| 'int*		(.sizeof: platform-ptr-size)
			| 'float*	(.sizeof: platform-ptr-size)
			| 'double*	(.sizeof: platform-ptr-size)
			| 'void*    (.sizeof: platform-ptr-size)
		] (.scalar?: false)
	]
	
	
	;--------------------------
	;-         =structor-type=:
	;
	; special structor helpers
	;--------------------------
	=structor-type=: [
		'CSTRING  (.sizeof: #"^@" .scalar?: false ) ; when sizeof is a char!, string! or binary!, it means copy TO this byte sequence
	]
	
	
	;--------------------------
	;-         =array-spec=:
	;
	; tells the loader that the data is a fixed sized array.
	;--------------------------
	=array-spec=: [
		into [ 
			set .array-count integer! 
		]
	]
	
	
	;--------------------------
	;-         =counted-array-spec=:
	;
	; tells the loader that the data is a variable length sized array.
	;
	; the size MUST be a member of the struct declared before the
	; current member
	;
	; when the de-struct is called, it will use this value at run time to iterate.
	;--------------------------
	=counted-array-spec=:  [
		into [ 
			set .array-count get-word!
		]
	]
	
	
	;--------------------------
	;-         =literal=:
	;
	; this is a litteral byte (sequence) value you expect directly at the current location.
	;
	; note that this is not currently affected by endianness.
	;--------------------------
	.lit-count: 0
	=literal=: [
		set .value [
			  string!
			| binary!
		]
		(
			.lit-count: .lit-count + 1
			.array-count: length? .value
			.member: to-word rejoin ['lit .lit-count]
		)
	]
	
	
	;--------------------------
	;-         =type-decorations=:
	;
	; type interpretation modifiers which may or may not affect how the data is loaded
	;--------------------------
	=type-decorations=: [
		'unsigned 
		| 'signed 
		| 'const 
		| 'static ; not sure if this can be in structs
	]
	
	
	;--------------------------
	;-         =member-instructions=:
	;
	; these are de-struct specific instructions which allow us to interpret the data
	; while loading it.  this goes beyond what is specified in the C struct language.
	;
	; we use refinements for member instructions (to separate them visually)
	;
	; these differ from struct instructions which toggle on/off for all members
	;--------------------------
	=member-instructions=: [
		;-----
		;-              /hex
		;
		; load this as a hexadecimal value (the result value is type specific, it usualy ends up a binary!).
		;-----
		/hex (.loadtype: 'hex)
		
		;-----
		;-              /string /str
		;
		; whatever the source we want a string of that value.  this is usually a string version of the binary! source.
		;-----
		| [/string | /str] (.loadtype: 'string .scalar?: false)
		
		;-----
		;-              /binary /bin
		;
		; whatever the source we want a string of that value.  this is usually a string version of the binary! source.
		;-----
		| [/binary | /bin] (.loadtype: 'binary .scalar?: false)
		
		;-----
		;-              /flags
		;
		; the bitset spec is a tag list of  words and values.
		;
		; you can give the spec inline, or refer to it using a bound word
		; values can be in integer!, binary!, or string! format depending on what type they refer to.
		;
		; we will compare ALL values and add their respective word
		; if they are part of given flag pattern.
		;
		; this allows us to setup flag sets and they will be reported.
		;
		; ex:
		;   if you specify:  [low-bit 1   mid-bit 2   high-bit 4   ultra-bit 8   low-bits 3   low-high-bits 5]
		;   and are given:   13
		;   the result will be:  [low-bit  high-bit  ultra-bit  low-high-bits]
		;-----
		| [
			/flags set .loadspec [
				(print "found flags")
				word! 
				| [ 
					; we don't want to go INTO parens... only blocks
					.here: block! :.here block!
				]
			]
			(
			 	if word? :.loadspec [
			 		.loadspec: get .loadspec
			 		unless block? :.loadspec [
			 			to-error "de-struct() /options MUST be a block! or refer to a block! value."
			 		]
			 	]
			 	.blk: copy []
			 	parse .loadspec [
					some [
						set .opt 	word! 
						set .optval	[ integer! | binary! ] (
							.optval: to-integer .optval ; binaries may be easier to spec, but the actual value is int.
							append .blk .opt
							append .blk .optval
						)
					]
				]
				.loadtype: 'flags
				.loadspec: .blk
				?? .loadtype
				?? .loadspec
				?? .blk
				ask "!"
			)
		]
		
		;-----
		;-              /options
		;
		; the options spec is a tag list of  words and values.
		;
		; you can give the spec inline, or refer to it using a bound word
		; values can be in integer!, binary!, or string! format depending on what type they refer to.
		;
		; result is ONE word out of a list of possibilities.
		;
		; if the value is not in the spec, you end up with a none!
		;-----
		| [
			/options set .loadspec [
				word! 
				| [ 
					; we don't want to go INTO parens... only blocks
					.here: block! :.here block!
				]
			]
			(
			 	if word? :.loadspec [
			 		.loadspec: get .loadspec
			 		unless block? :.loadspec [
			 			to-error "de-struct() /options MUST be a block! or refer to a block! value."
			 		]
			 	]
			 	.blk: copy []
			 	parse .loadspec [
					some [0
						set .opt 	word! 
						set .optval	[
							  integer! 
							| binary! 
							| string! ; this is only valid for string based types
						]
						(
							if .scalar? [
								unless string? [to-error "cannot use string! for scalar types"]
								.optval: to-integer .optval ; binaries are easier to spec, but the actual value is int.
							]
							append .blk .opt
							append .blk .optval
						)
					]
				]
				.loadtype: 'options
				.loadspec: .blk
			)
		]
	]
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     Struct Specs
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-         =struct-instructions=:
	;
	; instructions are all issue! types with possible values after.
	;
	; these modify how the struct loader does its job, for ALL FOLLOWING declarations
	;--------------------------
	=struct-instructions=: [
		;-------------------------
		;-             -endinanness control 
		;-------------------------
		; not sure about leaving short forms in the long-term... depends on feedback and long-term use.
		;-------------------------
		 [ #big-endian | #be ] (
			.endianness: 'big-endian
		)
		
		| [ #little-endian | #le ] (
			.endianness: 'little-endian
		)
		
		| [ #platform-endian | #pe ] (
			.endianness: PLATFORM-ENDIANNESS
		)
	]
	
	
	
	
	;--------------------------
	;-         =cstruct-member=:
	;
	; C structured data
	;--------------------------
	=cstruct-member=: [
		(
			.decl: none
			.data: none ; when type is recognized, we will load the data here
			.array-count: 1 ; will only be set if an array is specified.
			.value: none
			.array?: none
			.loadtype: none ; may be [ hex | flags | options ]
			.loadspec: none ; depends on .loadtype
			.scalar?: none
		)
		[
			err-here: 
			opt =type-decorations=  
			err-here: 
			set .type [
				  =pod-type=  
				| =structor-type= ; these handle special non struct binary layouts frequently used in files and codecs.
			]
			err-here: 
			opt =member-instructions=
			err-here: 
			[
				[
					set .member  word! 
					err-here:
					;---
					; if this is an array, we must mark it (even if size is 1)
					opt [
						[
						  	  =array-spec=
							| =counted-array-spec=
						]
						(.array?: true)
					]
				]
				| [
					err-here: 
					=literal=
				]
			]
			(
				.decl: compose/deep  [
					(to-set-word .member)
					(make !member [
						type:	(.type)
						sizeof: (.sizeof) 
						count:  (.array-count )
						array?: (.array?)
						value:  (.value )
						endianness: (.endianness) 
						loadtype: (.loadtype) 
						loadspec: (.loadspec)
					])
				]
			)
		] | skip [
			(to-error rejoin [ "syntax error in see-struct specification, at: "  mold copy/part err-here 3])
		]
	]
	
	
	;--------------------------
	;-         =cstruct=:
	;
	; the top-level C structure loader
	;--------------------------
	=cstruct=: [
		;             -init 
		(	
			.spec: copy []
			.endianness: PLATFORM-ENDIANNESS ; this is reset at each scan.
		)
		some [
			;-             -instructions 
			=struct-instructions=
			
			;-             -declarations
			| =cstruct-member=  (append .spec .decl)
		]
		( .spec: context .spec )
	]
	
	
		
		
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-         de-struct()
	;--------------------------
	; purpose:  Loads binary data using a C-struct dialect
	;
	; returns:  
	;
	; notes:    - when passing in a word, it modifies the index of the word.
	;             this allows us to chain several calls on the same buffer, loading back to back, with minimal fuss
	;
	; to do:    <TODO> add /C-align property which will use default C struct alignment rules. (objects are aligned to their byte size)
	;
	; tests:    
	;--------------------------
	de-struct: funcl [
		spec [block!]  "C struct specification in =see-struct= dialect"
		'bytes [binary! word! path!] "binary buffer to load. (be careful to read/BINARY"
		/extern .spec
	][
		vin "de-struct()"
		parse/all spec =cstruct=
		
		;probe bytes
		switch/default type?/word bytes [
			path! [ buffer: do bytes ]
			word! [ buffer: get bytes ]
		][
			buffer: bytes
		]
		
		;v?? bytes
		;v?? .spec
		spec: .spec
		out: make .spec [
			**sizeof**: 0
		]
		
		bytes-read: 0
	
		foreach member words-of spec [
			;vprint "----------------"
			;vprobe member
			attr: get in spec member
			;vprobe attr
			;vprobe type? buffer
			
			
			unless array-count: any [
				all [
					integer? attr/count
					attr/count
				]
				all [
					get-word? attrcnt: attr/count
					;v?? attrcnt
					attr-ref: get in spec attr/count
					;v?? attr-ref
					integer? attr-ref/value
					attr-ref/value
				]
			][
				to-error rejoin ["de-struct(): array size specification is invalid for member: " member]
			]
			
			;v?? array-count
			
			
			switch/default/all attr/type [
				char BYTE [
					data: copy/part buffer buffer: skip buffer ( attr/sizeof * array-count )
					bytes-read: bytes-read + ( attr/sizeof * array-count )
					;v?? data
	
					value: data
					either attr/value [
						;vprint "COMPARING!"
						either value <> as-binary attr/value [
							( to-error rejoin [ "invalid value in binary data: "  mold copy/part err-here 3] )
						][
	;						vprint "Value is ok!?"
						]
					][
	;					vprint "LOADING!"
						attr/value: value
					]
					
					if attr/loadtype != 'hex [
						attr/value: as-string attr/value
					]
				]
				
				CSTRING [
	;				vprint "FOUND CSTRING (ARRAY?)"
					; uniformitize the sizeof into a binary, so we can search directly in data.
					pattern: to-binary to-string attr/sizeof
					if attr/array? [
						attr/value: blk: copy []
					]
					
					v?? array-count
					loop array-count [
						v?? pattern
						data-end: find/tail buffer pattern
						
						;vprobe buffer
	
						;---
						; note that if find doesn't work, then the copy/part will fail and an error raised...
						; this is native, binary data, it can't be filled with errors.
						str: copy/part buffer back data-end
						
						;attr/value: str
						if attr/loadtype != 'hex [
							str: as-string str
						]
						either attr/array? [
							append blk str
						][
							attr/value: str
						]
	
						;v?? str  
						buffer: data-end
						bytes-read: bytes-read + (length? str) + 1
					]
					new-line/all blk true
				]
				
				char* short* word* long* int* float* double* void* [
					data: copy/part buffer buffer: skip buffer ( attr/sizeof * array-count )
					bytes-read: bytes-read + ( attr/sizeof * array-count )
					;---
					; pointer loading is not yet implemented.
					attr/value: 0
				]
			][
				data: copy/part buffer buffer: skip buffer ( attr/sizeof * array-count )
				bytes-read: bytes-read + ( attr/sizeof * array-count )
				;v?? data
	
				either array-count > 1 [
					attr/value: blk: copy []
					repeat i array-count [
					
						itemdata: copy/part data attr/sizeof
						data: skip data attr/sizeof
					
						;----------------------
						; integer numeric types
						;----------------------
						either attr/loadtype = 'hex [
							itemvalue: itemdata 
							if attr/endianness = 'little-endian [
								itemvalue: head sort/reverse itemvalue
							]
						][
							either attr/endianness = 'big-endian [
								itemvalue: to-integer itemdata
							][
								itemvalue: load-le-i32 itemdata
							]
						]
	
						;v?? itemvalue
						append blk itemvalue
					]
				][
					;----------------------
					; integer numeric types
					;----------------------
					either attr/loadtype = 'hex [
						attr/value: data 
						if attr/endianness = 'little-endian [
							attr/value: head reverse data
						]
					][
						either attr/endianness = 'big-endian [
							attr/value: to-integer data
						][
							attr/value: load-le-i32 data
						]
					]
				]
			]
			
			;set in .spec attr  take/part lib len
			value: attr/value
			;v?? data
	;		v?? value
			set in out member attr/value
		]
		
		;---
		; modify the input word, if given.
		if word? bytes [
			set bytes buffer
		]
		
		out/**sizeof**: bytes-read
		vout
		
		out
	]

	
	
	
	;--------------------------
	;-         load-value()
	;--------------------------
	; purpose:  convert data to the specced REBOL value
	;
	; inputs:   spec of a member and its extracted data
	;
	; returns:  rebol-loaded value (including none! for some types)
	;
	; notes:    some spec and data combinations may be invalid... 
	;
	; to do:    allow a global switch for ERROR! generating on errors instead of fallback values.
	;--------------------------
	load-value: funcl [
		spec [object!]
		data [binary!]
	][
		vin "load-value()"
		switch/default spec/loadtype [
		
		][
			
		]

; when we have a bitset, the result value will be a block of words.

		vout
	]
	
	
	
]

