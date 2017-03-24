REBOL [
	; -- Core Header attributes --
	title: "file and path related utility functions"
	file: %utils-fileops-linux.r
	version: 1.0.0
	date: 2016-02-29
	author: "Maxim Olivier-Adlhoch"
	purpose: {Collection of generic, re-useable path and file handling functions.}
	web: http://www.revault.org/modules/utils-files.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-fileops-linux
	slim-version: 1.2.7
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-files.r

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
		v1.0.0 - 2016-02-29
			-creation

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
; test-enter-slim 'utils-files
;
;--------------------------------------


slim/register [

	; declarations to preserve word locality 
	;CopyFile: none
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     LIBS
	;
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-         fop-copy()
	;--------------------------
	; purpose:  system level file copy, uses paths sent through TO-LOCAL-FILE
	;
	; inputs:   
	;
	; returns:  0 on error, 1 or more on success.
	;
	; notes:    there is NO copy() system call in linux, so we must build our own.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	fop-copy: funcl [
		[catch]
		src [string!]
		dst [string!]
	][
		vin "fop-copy()"
		throw-on-error [
			if any [
				find src "//"
				find dst "//"
			][
				to-error "// found in path, we do not support UNC paths, these may be unsupported by OS and map to root '/' or split path in two. "
			]
				
			;
			; linux returns 0 when command is executed without error.
			; we add single quotes to preserve any space in src and dst
			cmd: rejoin [{cp --preserve=all '} src {'  '} dst {'} ]
			rval: call/wait cmd
			
			;---
			; swap meaning of 0 return value
			rval: either rval = 0 [1][0]
		]			
		vout
		rval
	]
	
	
	;--------------------------
	;-         CopyFile()
	;
	; stub for backwards compatibility (deprecated name)
	;--------------------------
	CopyFile: :fop-copy
	
]

