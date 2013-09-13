REBOL [
	; -- Core Header attributes --
	title: "error and exception handling tools."
	file: %utils-errors.r
	version: 1.0.1
	date: 2012-9-4
	author: "Maxim Olivier-Adlhoch"
	purpose: "Collection of generic, re-useable functions"
	web: http://www.revault.org/modules/utils-errors.rmrk
	source-encoding: "Windows-1252"
	note: {Steel Library Manager (SLiM) is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-errors
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-errors.r

	; -- Licensing details  --
	copyright: "Copyright © 2012 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2012 Maxim Olivier-Adlhoch

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
			-license changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
]








;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-errors
;
;--------------------------------------


slim/register [

	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- CLASSES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;- !exception:
	;
	; The base object for use with the fling system.
	;--------------------------
	!exception: context [
		exception?: 	true
		name:			'generic
		code:			100 ; generic error code.
		message:		"unknown error"
		description:	"Unknown cause"
	]



	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------
;	error-list: [
;		unknown-exception [ code: 1000   exception: 'unknown   message: "Flinged Unknown Exception." ]
;	]
	


	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	
;	
;	
;	;--------------------------
;	;     set-error-list()
;	; (DEPRECATED)  read the core guide to understand how to manipulate internal objects.
;	;--------------------------
;	; purpose:  provide an extended error list for use with build-error.  This prevents us from having to use /from-list on each call.
;	;
;	; inputs:   
;	;
;	; returns:  
;	;
;	; notes:    -we do not replace the current error list, we add to it.
;	;           -if some errors already exist in error-list, your errors will re-define them.
;	;
;	; tests:    
;	;--------------------------
;	set-error-list: funcl [
;		errors [block!] "tag list of named error specs"
;	][
;		vin "set-error-list()"
;		unless all [
;			ok?: true
;			( foreach [name spec] errors [
;				unless all [
;					word? name
;					block? spec
;				][
;					ok?: false
;				]
;			] ok? )
;			insert error-list errors
;		][
;			to-error "set-error-list(): unable to use given errors block, it was invalid."
;		]
;		
;		
;		vout
;	]
;	
;	

	

	;--------------------------
	;-     is-disarmed-error?()
	;--------------------------
	; purpose:  returns true if the given object qualifies as a disarmed object.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    the object is allowed to have more fields than the minium set provided by the error! type.
	;
	; tests:    [
	;				true? is-disarmed-error? disarm try [ 0 / 0 ]
	;			]
	;--------------------------
	is-disarmed-error?: funcl [
		err [any-type!]
	][
		;vin "is-disarmed-error?()"
		all [
			;---
			; inspect input
			;---
			object?		get/any 'err ; survives unset! on entry
			
			;---
			; these must have values
			;---
			integer?	get in err 'code
			word?		get in err 'type
			word?		get in err 'id
			
			;---
			; these may be unspecified
			;---
			in err 'arg1
			in err 'arg2
			in err 'arg3
			in err 'near
			in err 'where
		]
		;vout
	]
	
	
	;--------------------------
	;-     is-valid-exception?()
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
	is-valid-exception?: funcl [
		ex [any-type!]
	][
		;vin "is-valid-exception?()"
		
		all [
			;---
			; inspect input
			;---
			object?		get/any 'ex ; survives unset! on entry
			#[true]	=	get in ex 'exception?
			
			;---
			; these must have values
			;---
			word?		get in ex 'name
			integer?	get in ex 'code
			string?		get in ex 'message
			
			;---
			; these may be unspecified
			;---
			in ex 'description
		]
		; vout
	]
		

	;--------------------------
	;-     fling()
	;--------------------------
	; purpose:  using a simpler spec, generate a throw call with a name and builds the !exception object!
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	fling: funcl [
		exception [block! word! string! error! object!]
	][
		vin "fling()"
		
		exc: make !exception [  ]
		data: none
		string-count: 0
		
		switch/default type?/word :exception [
			object! [
				case [
					is-disarmed-error? exception [
						exception: reduce [ exception/id  exception/code to-string "Execution error"]
					]
				
					is-valid-exception? exception [
						exception: reduce [ exception ]
					]
				]
			]
			
			error! [
				exception: disarm exception
				
			]
			block! [] ; do nothing
		][
			exception: compose [(exception)]
		]
		v?? exception
		parse exception [
			some [
				  set data word!   ( vprint ["name: " data] exc/name: data )
				| set data string! (
					; we keep tabs on how many strings were given.
					string-count: string-count + 1
					switch string-count [
						1 [
							 vprint ["message: " data]
							 exc/message: data 
						]
						2 [
							 vprint ["description: " data]
							 exc/description: data 
						]
					]
				)
				| set data object! ( vprint ["base exception: " data] exc: data)
				| skip
			]
		]
		
		vprobe exc
		
		vout
		throw/name exc exc/name
	]
	
			
	
	;--------------------------
	;-     trap()
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
	trap: funcl [
		code [block!]
		
	][
		vin "trap()"
		
		comment [
			trap/default [
				storig
				eoginse
				seoirgusen
				eoprgier
			][
				'll [
					
				]
			
				'zero-divide [
					
				]
				
				'missing-name [
					
				]
				
			][
				case/all [
					exception? [
					
					]
					
					error? [
					
					]
					
					nominal? [
				
					]
				]
			]
		] ; comment
	
		vout
	]
	
	
]
	

			

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

