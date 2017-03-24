REBOL [
	; -- Core Header attributes --
	title: "file and path related utility functions"
	file: %utils-fileops-win32.r
	version: 1.0.0
	date: 2016-02-29
	author: "Maxim Olivier-Adlhoch"
	purpose: {Collection of generic, re-useable path and file handling functions.}
	web: http://www.revault.org/modules/utils-files.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-fileops-win32
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
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         fop-copy()
	;
	; this function does a system-friendly copy of a file into another, 
	; it also copies files attributes and security info, when appropriate.
	;--------------------------
	slim/open/expose 'win32-kernel none [fop-copy: win32-Copyfile]
	

	;--------------------------
	;-         CopyFile()
	;
	; stub for backwards compatibility (deprecated name)
	;--------------------------
	CopyFile: :fop-copy
	
]

