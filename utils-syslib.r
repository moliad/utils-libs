Rebol [
	; -- Core Header attributes --
	title: "System Libs & struct utilities"
	file: %utils-syslib.r
	version: 0.0.2
	date: 2014-5-22
	author: "Ladislav Mecir"
	purpose: "Utilities supporting external library interface, for Rebol 2"
	web: http://www.fm.vslib.cz/~ladislav/rebol/
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-syslib
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-syslib.r

	; -- Licensing details  --
	copyright: "None"
	license-type: "Public Domain"

	;-  / history
	history: {
		v0.0.1 - 2010-7-6
			-Original version by Ladislav (http://www.fm.vslib.cz/~ladislav/rebol/library-utils.r)

		v0.0.2 - 2014-05-22 - Maxim Olivier-Adlhoch
			-Reformated the original do script into slim format for better run-time control
			-Added literate header notations for all values and functions.
			-changed the switch statement in CONVERT to make it a bit more readable.
	}
	;-  \ history

	;-  / documentation
	documentation: {
		===Errors in the http://www.rebol.com/docs/library.html
		
		*the "Specifying Datatypes in Routines" section contains the "C to REBOL Datatype Conversions" table, in which the next to the last row is incorrect, since the C struct datatype actually cannot be used in routine specification
		
		*the last row of the table contains a char datatype, while the correct datatype should have been a pointer, i.e. the char* datatype
		
		*the last row of the "REBOL to C Datatype Conversion" table states, that the REBOL STRUCT! datatype is converted to a C struct datatype, which is wrong, since REBOL STRUCT! datatype is rather converted to a C pointer
		
		*there are many places, where a pointer datatype is mentioned using an incorrect notation, e.g. void, instead of the proper void*, char, instead of char*
		
		*the REBOL STRUCT! datatype is not directly compatible with C struct, it is usually handled by the interpreter as a pointer, i.e. as a C struct* datatype.
		
		===Computing the size of a datatype
		
			sizeof 'double ; == 8
			sizeof 'float ; == 4
			sizeof 'long ; == 4
			sizeof 'int ; == 4
			sizeof 'short ; == 2
			sizeof 'char* ; == 4 ; pointer
			sizeof [struct! []] ; == 4 ; pointer
			sizeof 'integer! ; == 4
			sizeof 'char ; == 1
		
		===What is the best REBOL counterpart of a C pointer datatype?
			
		In the C language, there are many distinct pointer types, e.g.:
		void*, char*, double*, int*, float*, etc.
			
		The C pointers have all the same size, i.e. sizeof char* is the same as sizeof void*, etc., and it is easy to convert one pointer type to another, the only difference being, that pointer arithmetic expressions like p + 1 depend on pointer type.
			
		According to http://www.rebol.com/docs/library.html#section-25 the most convenient counterparts of C pointers are REBOL integer! values, interpreted as memory addresses.
			
		---Advantages
			
		*Integer arithmetic can be used to manipulate memory addresses without performing additional conversions. Doing so, REBOL integers behave exactly like char* pointers in C.
		
		*Integer comparison can be used to compare memory addresses. For example, this is how we can find out in REBOL, whether an address was a NULL pointer in C:
		
			0 = address
				
		*Memory addresses can be used in the role of C pointer counterparts both as return values as well as arguments of routines. 
		
		*The address of a REBOL string can be obtained as follows:
		
			string-address? "Hello, world!" ; == 42605768
		
		*If we know the memory address of a string using the C convention (strigs are nul-terminated in C) we can obtain a copy of the string (in this example we use the address obtained above). Note, that the REBOL interpreter automatically appends the NUL (#"^(00)") character to every string, which means, that all REBOL strings not containing the NUL character adhere to the C string convention too. 
		
			address-to-string 42605768 ; == "Hello, world!"
		
		*We can even obtain a REBOL binary copy of a memory region at a given address, provided we supply the length of the region we want to copy:
		
			get-memory 42605768 14
		
		*This is how other values stored at the given address can be obtained:
		
			convert 42605768 [char] ; == #"H"
		
		*The address of a REBOL binary can be obtained using the STRING-ADDRESS? function too.
		
		*The address of a REBOL struct can be obtained as follows:
		
			struct-address? make struct! [i [int]] [1]
		
		*Using the SET-MEMORY function it is possible to directly change the memory at the specific address.
			
		---Disadvantages
				
		*It may happen, that sizeof 'int is not equal to sizeof 'char*, in which case the code below needs adjustments!
		
		---Alternatives
		
		Other REBOL datatypes that can be used as C pointer counterparts are the struct! datatype, string! datatype or the binary! datatype, but:
		
		*the struct! datatype does not support arithmetic operations, neither it supports comparisons like above
		
		*the string! datatype supports the skip (index) arithmetic, but it does not support comparisons like above, moreover, it works well for the returned char* pointers only in case they represent nul-terminated strings; if returned, we actually obtain a copy of the string returned, not the original, which may be a problem if we want to manipulate the original memory
		
		*the binary! datatype supports the skip (index) arithmetic, but it is not suitable to represent a routine return value
		
		===Converting values (or blocks of values) to binaries and vice versa
		
		REBOL decimals are 64-bit IEEE 754 FP numbers (equivalent of C double) in little endian byte order for Intel processors e.g. This is how to convert them to binary:
		
			d: convert [0.2] [double]
			convert d [double] ; == [0.2]
		
		Using an Intel processor, if you prefer a big endian byte order, reverse the conversion result:
		
			reverse convert [0.2] [double]
		
		Conversion to the 32-bit IEEE 754 FP format (C float):
		
			convert [0.2] [float]
		
		This is how to convert more values to binary and vice versa:
		
			b: convert [1 2] [int int]
			convert b [int int] ; == [1 2]
		
		===The endianness of the processor
		
		The endianness of the processor can be found as follows:
		
			endian?: pick [little big] 1 = first convert [1] [int]
		
		Another way:
		
			endian?: get-modes system/ports/system 'endian
		
		===Calling library functions
		
		If a library function f is declared as follows:
			
			int f (double* a, int size);
		
		taking a double array a with a defined size, this is how its REBOL counterpart routine can be defined:
		
			f: make routine! [
				a [integer!] ; using REBOL integer! in place of a C pointer
				size [int]
				return: [int]
			] library "f"
		
		, and this is how we can call the routine using a size = 6 element array filled with 0.0s:
		
			size: 6
			array: make binary! size * sizeof 'double
			insert/dup array convert [0.0] [double] size
			result: f string-address? array size
	}

	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-syslib
;
;--------------------------------------
slim/register [

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-    int-struct:
	;--------------------------
	int-struct: make struct! [int [integer!]] none
	
	
	;--------------------------
	;-    string-struct:
	;--------------------------
	string-struct: make struct! [string [char*]] none
	
	
	;--------------------------
	;-    struct-struct:
	;--------------------------
	struct-struct: make struct! [struct [struct! [[save] c [char]]]] none
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	

	
	
	;--------------------------
	;-    struct-array()
	;--------------------------
	; purpose:  allows us to build a repetition within a struct
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    unfortunately, we must access the values as  struct/val1 struct/val2  (we can't get a block with all values)
	;           with strings we can fudge the system by using the address-to-string function
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	struct-array: funcl [
		name [word!] 
		type [word! datatype!]
		size [integer!]
	][
		vin "struct-array()"
		if datatype? :type [
			type: to-word :type
		]
		
		if size < 1 [
			to-error "utils-syslib/struct-array() size must be larger than 0"
		]
		
		rval: copy []
		type: append copy [] type
		
		repeat i size [
			rval: insert rval reduce [ 
				to-word join name i				type  ; we don't want to add any new-line in the block.  so we but var and type on same line here.
			]
		]
		
		rval: head rval
		
		vout
		rval
	]



	
	;--------------------------
	;-    sizeof()
	;--------------------------
	; purpose:  computes the size of a datatype in bytes
	;
	; returns:  size in integer!
	;--------------------------
	sizeof: func [
		{get the size of a datatype in bytes}
		datatype [word! block!]
	] [
		length? third make struct! compose/deep [value [(datatype)]] none
	]


	;--------------------------
	;-    string-address?()
	;--------------------------
	; purpose:  get the address of the given string
	;
	; returns:  a memory address as an integer!
	;
	; note:     ALWAYS returns the address of the HEAD of the string, no matter what index you give it.
	;--------------------------
	string-address?: func [
		{get the address of the given string}
		string [any-string!]
	] [
		idx: index? string
		string-struct/string: string
		change third int-struct third string-struct
		int-struct/int + idx - 1
	]


	;--------------------------
	;-    address-to-string()
	;--------------------------
	; purpose:  get a copy of the nul-terminated string at the given memory address
	;
	; returns:  a new Rebol String! value
	;--------------------------
	address-to-string: func [
		{get a copy of the nul-terminated string at the given address}
		address [integer!]
	] [
		int-struct/int: address
		change third string-struct third int-struct
		string-struct/string
	]
	

	;--------------------------
	;-    struct-address?()
	;--------------------------
	; purpose:  get the memory address of a Rebol struct!
	;
	; returns:  memory address as an integer!
	;--------------------------
	struct-address?: func [
		{get the address of the given struct}
		struct [struct!]
	] [
		string-address? third struct
	]
	

	;--------------------------
	;-    get-memory()
	;--------------------------
	; purpose:  copy a region of memory having the given address and size
	;
	; returns:  a REBOL binary! value
	;--------------------------
	get-memory: func [
		{
			copy a region of memory having the given address and size,
			the result is a REBOL binary value
		}
		address [integer!]
		size [integer!]
		/local struct
	] [
		int-struct/int: address
		struct: make struct! compose/deep [string [char-array (size)]] none
		change third struct third int-struct
		as-binary struct/string
	]
	

	;--------------------------
	;-    set-memory()
	;--------------------------
	; purpose:  given a string! or binary!, change a region of memory at the given address
	;
	;           in C, similar to : memcpy(address, contents, length? contents)
	;
	; returns:  nothing
	;--------------------------
	set-memory: func [
		{change a region of memory at the given address}
		address [integer!]
		contents [binary! string!]
	][
		int-struct/int: address
		foreach char as-string contents [
			change third struct-struct third int-struct
			struct-struct/struct/c: char
			int-struct/int: int-struct/int + 1
		]
	]
	

	;--------------------------
	;-    convert()
	;--------------------------
	; purpose:  convert block to binary,
	;		binary to block,
	;		or memory region to block
	;
	;       note that I'm not totally sure what this functions does...
	;
	;
	; returns:  depends on input!
	;--------------------------
	convert: func [
		{
			convert block to binary,
			binary to block,
			or memory region to block
		}
		from [block! binary! integer!]
		spec [block!] {
			type specification, supported types are listed in
			http://www.rebol.com/docs/library.html
		}
		/local result struct size
	] [
		switch type?/word from [
			block! [
				result: copy #{}
				repeat i min length? from length? spec [
					append result third make struct! compose/deep [
						value [(pick spec i)]
					] reduce [pick from i]			
				]
			]
			binary! [
				result: copy []
				foreach type spec [
					struct: make struct! compose/deep [value [(type)]] none
					size: length? third struct
					if size > length? from [break]
					change third struct copy/part from size
					append result struct/value
					from: skip from size
				]
			]
			integer! [
				result: copy []
				foreach type spec [
					struct: make struct! compose/deep [
						s [struct! [[save] value [(type)]]]
					] none
					size: length? third struct/s
					int-struct/int: from
					change third struct third int-struct
					append result struct/s/value
					from: from + size
				]
			]
		]
		result
	]
	
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

