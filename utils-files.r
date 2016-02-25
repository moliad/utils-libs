REBOL [
	; -- Core Header attributes --
	title: "file and path related utility functions"
	file: %utils-files.r
	version: 1.0.5
	date: 2013-10-03
	author: "Maxim Olivier-Adlhoch"
	purpose: {Collection of generic, re-useable path and file handling functions.}
	web: http://www.revault.org/modules/utils-files.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-files
	slim-version: 1.2.1
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
		v1.0.0 - 2012-02-21
			-creation
			-compiling previous code from other libraries
			
		v1.0.1 - 2013-01-09
			-renamed file to %utils-files.r  (S at the end) to make it more consistent with other utils libs.
			-renamed dir-part, file-part, ext-part  using newer R3 notation which adds *-of suffixe when extracting data.
			 so we now have path-of, filename-of, extension-of, old functions where COMMENTED and deprecated. 
			 only left the old names in comments for documentation purposes.

		v1.0.2 - 2013-09-12
			-license changed to Apache v2
			
		v1.0.3 - 2013-09-25
			-fixed DIR-TREE 
				*/ABSOLUTE now also works for folder paths,  
				*/IGNORE block now works on root-relative paths, 
				*fixed typo which crashed functions
		v1.0.4 - 2013-10-01
			-changed 'DIR-PART  to  'DIRECTORY-OF
			-deprecated 'DIR-PART
			
		v1.0.5 - 2013-10-03
			- 'DIRECTORY-OF  'EXTENSION-OF  &  'FILENAME-OF  are now  NONE! transparent and overhauled.
			- added tests
			- changed spaced indentation to make it tabbed.
			- 'SUBSTITUTE-FILE is now none transparent (on both inputs!) and re-implemented using 'DIRECTORY-OF  &  'FILENAME-OF
			- *many* odd case bugs fixed with overhauls of above functons.
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
	CopyFile: none
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	if platform-name = 'win32 [
		slim/open/expose 'win32-kernel none [CopyFile: win32-Copyfile]
	]
	
	

	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------
	copy*: :copy  ; needed for /copy refinement
	
	
	
	;-------------------
	;-     as-file()
	;--------------------------
	;
	; (prototype, might be a bit unstable with weird paths)
	;
	; universal path fixup method, allows any combination of file! string! types written as 
	; rebol or os filepaths.
	;
	; also cleans up // path items (doesnt fix /// though).
	;
	; NOTE: this function cannot fully support url-encoded strings, since there
	;   is a bug in path notation which doesn't properly convert string! to/from path!.
	; 
	;   for example the space (%20), when it is the first character of the string, will stick as "%20" 
	;   (and become impossible to decipher when probing the path)
	;   instead of becoming a space character.
	; 
	;   We take for granted that the first '%' prefix (when given a string!), is a path prefix and simply remove it.
	;
	;   Be careful if providing UNC paths, as handling of these is not specifically managed.
	;   furthermore, handling of these within Rebol, may change from one version to the next.
	;-----
	as-file: func  [
		path [ string! file! ]
	][
		path: switch type/word path [
			string! [
				to-rebol-file replace/all any [
					all [
						path/1 = #"%"
						next path
					]
					path
				] "//" "/"
				
			]
			
			file! [
				path
			]
		]   
		
		path
	]
	

		
	;--------------------------
	;-     directory-of()
	;--------------------------
	; purpose:  get the directory (folder) part of a path, if any.
	;
	; inputs:   a file! datatype
	;
	; tests:
	;	test-group [file! directory-of utils-files.r] []
	;		[ %/root/path/ = directory-of %/root/path/ ]
	;		[ %/root/path/ = directory-of %/root/path/file ]
	;		[ %/           = directory-of %/root ]
	;		[ %./          = directory-of %./ ]
	;		[ %./          = directory-of %./file.ext ]
	;		[ none         = directory-of %file.ext ]
	;		[ none         = directory-of %.ext ]
	;		[ none         = directory-of none ]
	;		[ %./          = directory-of %./file.ext ]
	;		[ error? try [ filename-of "test" ]]
	;	end-group
	;
	; deprecated names:
		dir-part: 
	;-----------------
	directory-of: funcl [
		path [file! string! none!]
	][
		all [
			path
			any [
				file: find/tail/last path "\"
				file: find/tail/last path "/"
			]
			copy/part path file
		]
	]



	;--------------------------
	;-     filename-of()
	;--------------------------
	; purpose:  get the filename part of a path, if any.
	;
	; inputs:   a file! datatype
	;
	; returns:  a filename of file! type or none!
	;
	; notes:    returns none when there is no file in the path.
	;           if the filename is only an extension, that is returned.
	;
	;           now none transparent (as of v1.0.5)
	;
	; tests:
	;	test-group [file! filename-of utils-files.r] []
	;		[ none       = filename-of %/root/path/ ]
	;		[ %file      = filename-of %/root/path/file ]
	;		[ %root      = filename-of %/root ]
	;		[ none       = filename-of %./ ]
	;		[ %.         = filename-of %/. ]
	;		[ %file.ext  = filename-of %./file.ext ]
	;		[ %file.ext  = filename-of %file.ext ]
	;		[ %.ext      = filename-of %.ext ]
	;		[ none       = filename-of none ]
	;		[ error? try [ filename-of "test" ]]
	;	end-group
	;
	; deprecated names:
		file-part:
	;--------------------------
	filename-of: funcl [
		path [file! string! none!]
	][
		all [
			path
			file: any [
				find/tail/last path "/"
				find/tail/last path "\"
				path
			]
			not empty? file
			copy file
		]
	]
	

	;--------------------------
	;-     prefix-of()
	;--------------------------
	; purpose:  returns the filename without file extension
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    returns none if the given path has no filename
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	prefix-of: funcl [
		path [file! string! none!]
	][
		all [
			path
			file: filename-of path
			ext: find/last file "."
			file: copy/part file ext
			not empty? file
			file
		]
	]

	
	;--------------------------
	;-     extension-of()
	;-     suffix-of()
	;--------------------------
	; purpose:  returns the extension part of a file path
	;
	; inputs:   a file path
	;
	; returns:  -the extension of the file, or none, if its a directory (even if it contains a "." in the path)
	;           -we silently ignore none inputs by returning none
	;
	; notes:    -we don't return the "." as part of the extension.
	;           -we rely only on the file path given, not its actual type on disk to verify if the input is indeed a directory.
	;           -we return an offset from the filename of the given path.
	;
	; tests:   
	;	test-group [file! extension-of utils-files.r] []
	;		[ none       = extension-of %/root/path/ ]
	;		[ none       = extension-of %/root/path/file ]
	;		[ none       = extension-of %/root ]
	;		[ none       = extension-of %./ ]
	;		[ %r         = extension-of %./file.r ]
	;		[ %r         = extension-of %file.r ]
	;		[ %r         = extension-of %.r ]
	;		[ none       = extension-of none ]
	;		[ %longext   = extension-of %/root/path/file.longext ]
	;		[ error? try [ extension-of "test" ]]
	;	end-group
	; 
	; deprecated names:
		ext-part: 
	;--------------------------
	extension-of: 
	suffix-of: funcl [
		path [string! file! none!]
	][
		all [
			path
			file: filename-of path  ; 'FILENAME-OF does a copy, so we don't have to.
			find/last/tail file "." ; returns none when not found.
		]
			
	]
	

	
	
	;--------------------------
	;-     substitute-file()
	;--------------------------
	; purpose:  given two files, will take the filename from the second and put in the first, in place.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    modifies first file
	;
	; tests:    
	;	test-group [file! substitute-file utils-files.r] []
	;		;---
	;		; simple tests
	;		;---
	;		[ %/root/path/b       = substitute-file %/root/path/a  %/root/path/b ]
	;		[ %/root/path/b       = substitute-file %/root/path/ %b]
	;		[ %/b                 = substitute-file %/ %b]
	;		[ %b                  = substitute-file %a %b]
	;		[ %/                  = substitute-file %/ %/test/]
	;		[ %/a/                = substitute-file %/a/ %/b/]
	;
	;		;---
	;		; none-transparency tests
	;		;---
	;		[ %/root/path/        = substitute-file %/root/path/a  none ]
	;		[ %/root/path/        = substitute-file %/root/path/   none ]
	;		[ %b                  = substitute-file none %/path/to/b ]
	;		[ %b                  = substitute-file none %b ]
	;		[ none                = substitute-file none none ]
	;
	;		;---
	;		; test /copy refinement
	;		;---
	;		[ a: %/path/to/a  b: %/root/to/b    c: substitute-file a b  all [ ( same? a c )   ( c = %/path/to/b ) ]  ]
	;		[ a: %/path/to/a  b: %/path/to/b    c: substitute-file/copy a b  not same? a c]
	;
	;		;---
	;		; negative tests
	;		;---
	;		[ error? try [ substitute-file "test" "ddd" ]]
	;	end-group
	;--------------------------
	substitute-file: funcl [
		file-a [ file! none! ]
		file-b [ file! none! ]
		/copy "Returns a new version of file-a, instead of modifying it."
	][
		dir: directory-of file-a
		file: filename-of file-b
	
		;---
		; if copy is required, we simply copy the dir within file-a, we also set dir as a reference to the file-a data
		all [
			dir 
			not copy 
			dir: append clear file-a dir
		]
		
		any [
			all [
				dir file 
				append dir file
			]
			
			dir
			file
		]
		
	]
	
	
	
	;-------------------
	;-     is-dir?()
	;-----
	is-dir?: func [
		path [string! file!]
	][
		any [
			#"/" = last path
			#"\" = last path
		]
	]
	

	;-------------------
	;-     is-file?()
	;-----
	is-file?: func [
		path [string! file!]
	][
		not is-dir? path
	]
	
	
	;-----------------
	;-     dir-tree()
	;-----------------
	dir-tree: funcl [
		path [file!]
		/root rootpath [file! none!]
		/absolute "returns absolute paths"
		/ignore i-blk [block! file!] "if the path is within the ignore paths block, we reply an empty block, paths must be given as a complete path including %./ or else is ignored."
		;/local list item data subpath dirpath rval
	][
		rval: copy []
		
		i-blk: any [i-blk []]
		i-blk: compose [(i-blk)]
		
		
		either root [
			unless exists? rootpath [
				to-error rejoin [ "compiler/dir-tree()" path " does not exist" ]
			]
		][
			either is-dir? path [
				rootpath: path
				path: %./
			][
				to-error rejoin [ "compiler/dir-tree()" path " MUST be a directory." ]
			]
		]
		
		dirpath: clean-path append copy rootpath path
		
		unless find i-blk path [
			either is-dir? dirpath [
				; list directory content
				list: read dirpath
				
				; append that path to the file list
				either absolute [
					append rval clean-path join rootpath path
				][
					append rval path
				]
				;append rval path
				
				foreach item list [
					subpath: join path item
					
					; list content of this new path item (files are returned directly)
					either absolute [
						data: dir-tree/root/absolute/ignore subpath rootpath i-blk
					][
						data: dir-tree/root/ignore subpath rootpath i-blk
					]
					;if (length? data) > 0 [
						insert tail rval data
					;]
				]
			][
				if absolute [
					path: clean-path join rootpath path
				]
				; when the path is a file, just return it, it will be compiled with the rest.
				rval: path
			]
		]
		
		if block? rval [
			rval: new-line/all  head sort rval true
		]
		
		rval
	]
	
	
	
	;--------------------------
	;-     newer?()
	;--------------------------
	; purpose:  given one or more sets of files (possibly trees) 
	;
	; inputs:   pairs of source + reference files
	;
	; returns:  block of all files which are more recent (in content or date) (note we only return the source files)
	;           none, when block would be empty
	;
	; notes:    if destination doesn't yet exist, then we return true.
	;
	; tests:    
	;--------------------------
	newer?: funcl [
		paths [block!] "pairs of source + reference files"
	][
		vin "newer?()"
		vprobe what-dir
		paths: remove-each [src dest] copy paths [
			vprint "--"
			v?? src
			v?? dest
			src: clean-path src
			dest: clean-path dest
			v?? src
			v?? dest
			vprobe info? src
			vprobe info? dest
			unless exists? src [
				probe clean-path src
				to-error "'NEWER? :: source file doesn't exist (yet?)"
			]
			all [
				; new file
				exists? dest
				
				; updated-file
				( modified? src ) <= ( modified? dest )
			]
		]
		vout
		
		;----
		; return none when nothing is newer
		; return only source files (we ignore reference files in return)
		first reduce [
			all [
				not empty? paths
				extract paths 2
			]
			paths: none
		]   
	]
	
	
	
	;--------------------------
	;-     root?()
	;--------------------------
	; purpose:  is the given path a root path?
	;
	; inputs:   any file path
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	root?: funcl [
		path [file!]
	][
		path = %/
	]
	
	
	;--------------------------
	;-     itemize-path()
	;--------------------------
	; purpose:  given a path, separates into each of its part.
	;
	; inputs:   any file path
	;
	; returns:  a block of strings with 
	;
	; notes:    -a trailing or begining slash will be inserted in the result if it was
	;            a root path and/or a directory path.
	;
	;           -for the sake of simplicity, head and trailing slashes are also strings.
	;
	; tests:    
	;	test-group [file! itemize-path utils-files.r] []
	;		[        [ "/" "root" "dir" "/" ] = itemize-path  %/root/dir/ ]
	;		[            [ "root" "dir" "/" ] = itemize-path  %root/dir/ ]
	;		[               [ "root" "dir"  ] = itemize-path  %root/dir ]
	;		[ [ "/" "root" "dir" "file.ext" ] = itemize-path  %/root/dir/file.ext ]
	;		[     [ "root" "dir" "file.ext" ] = itemize-path  %root/dir/file.ext ]
	;		[                         [ "/" ] = itemize-path  %/ ]
	;		[                  [ "/" "." "/"] = itemize-path  %/./ ]
	;		[                 [ "/" ".." "/"] = itemize-path  %/../ ]
	;		[                      [ "." "/"] = itemize-path  %./ ]
	;		[                     [ ".." "/"] = itemize-path  %../ ]
	;		[                      error? try [ itemize-path "test" ]]
	;	end-group
	;--------------------------
	itemize-path: func [
		path [file!]
		/local dir? abs?
	][
		dir?: is-dir? path
		abs?: absolute-path?/quiet path
		path: parse/all path "/"
		
		remove-each item path [item = ""]
		
		all [
			dir? 
			path <> []
			append path "/"
		]
		if abs? [insert path "/" ]
		
		path  
	]
	
	
	;--------------------------
	;-     absolute-path?()
	;--------------------------
	; purpose:  quick check to see if a path is relative or aboslute
	;
	; inputs:   any file path
	;
	; returns:  the input path if true, none! otherwise
	;
	; tests:    
	;	test-group [file! absolute-path? utils-files.r] []
	;		[ absolute-path?  %/root/path/ ]
	;		[ absolute-path?  %/root/path/file.ext ]
	;		[ absolute-path? %/ ]
	;		[ none? absolute-path? %./ ]
	;		[ none? absolute-path? %rel/path/file.ext ]
	;		[ error? try [ absolute-path? "test" ]]
	;		[ error? try [ absolute-path? %/../invalid/path ] ]
	;	end-group
	;--------------------------
	absolute-path?: funcl [
		[catch]
		path [file!]
		/quiet "do not raise error if given invalid %/../  path"
	][
		all [ 
			#"/" = first path
			
			; root paths cannot start with  "/../"
			not all [
				not quiet
				#"." = pick path 3
				#"." = pick path 2
				throw make error! "invalid path given to absolute-path?()"
			]
			path 
		]
	]

	
	
	;--------------------------
	;-     volume?()
	;--------------------------
	; purpose:  detect if a path is a disk volume (logical system partition)
	;
	; inputs:   any file path 
	;
	; returns:  the input path if true, none! otherwise
	;
	; notes:    -each platform may have different ways to determine if a path is a volume.
	;           -volume paths are special, we cannot create volumes, they usually act like 'named' root paths.
	;
	;           -some OSes don't really have the concept of volumes, as they are symlinked within the rest of the
	;            filesystem.  if your OS is like so but you have a way of telling if it really is a volume, then
	;            you may extend the function here.
	;
	;           -only absolute paths may be considered volumes.
	;
	;           -on posix filesystems we fake it by assuming apps shouldn't manipulate paths in the root.
	;            so we also assume volumes are single-depth paths directly in the root.
	;
	; tests:    
	;	test-group [file! volume? utils-files.r] []
	;		[              volume?  %/c/ ]
	;		[              volume?  %/c ]
	;		[              volume?  %/volume/ ]
	;		[        none? volume?  %c/ ]
	;		[        none? volume?  %volume/ ]
	;		[        none? volume?  %/root/path/file.ext ]
	;		[        none? volume?  %/ ]
	;		[        none? volume?  %./ ]
	;		[        none? volume?  %/. ]
	;		[        none? volume?  %/./ ]
	;		[        none? volume?  %/../ ]
	;		[        none? volume?  %rel/path/file.ext ]
	;		[ error? try [ volume?  "test" ]]
	;	end-group
	;--------------------------
	volume?: funcl [
		path [file!]
	][
		all [
			paths: itemize-path path
			paths/1 = "/"
			string? paths/2
			paths/2 <> "."
			paths/2 <> ".."
			any [
				paths/3 = "/"
				none? paths/3
			]
			none? paths/4
			path
		]
	]
	
	
	
	;--------------------------
	;-     fileize()
	;--------------------------
	; purpose:  the logical complement to dirize
	;
	; inputs:   a path, from which we remove the trailing /
	;
	; returns:  a COPY of the input path. 
	;
	; notes:    -cannot use this on a root path, it raises an error.
	;
	;           -always returns a copy of the original path, just like 'DIRIZE
	;
	; tests:    
	;	test-group [file! fileize utils-files.r] []
	;		[ %/root/path      = fileize %/root/path/ ]
	;		[ %/root/path/file = fileize %/root/path/file ]
	;		[ %/root           = fileize %/root ]
	;		[ %.               = fileize %./ ]
	;		[ %/.              = fileize %/. ]
	;		[ %..              = fileize %../ ]
	;		[ %/..             = fileize %/.. ]
	;		[ %./file.ext      = fileize %./file.ext ]
	;		[ %file.ext        = fileize %file.ext ]
	;		[ error?       try [ fileize none ]]
	;		[ error?       try [ fileize "test" ]]
	;	end-group 
	;--------------------------
	fileize: funcl [
		[catch]
		path [file!]
	][
		if any [
			root? path
		][
			throw make error! "cannot turn path into a file"
		]
		
		either is-dir? path [
			path head remove back tail copy path
		][
			copy path
		]
		
	]
	

	;--------------------------
	;-         UNC-host-of()
	;--------------------------
	; purpose:  get the UNC host name of a path, if any.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    using /extract converts the given path to a local path on the returned host.
	;
	; to do:    explicitely test on linux and other platforms.
	;
	; tests:    
	;--------------------------
	UNC-host-of: funcl [
		path [  file! string!  ]
		/extract "remove the hostname from the path.  any DRIVE map is replaced by a local file path"
	][
		;vin "UNC-host-of()"
		if file? path [
			path: to-local-file path
		]
		
		.host:  none
		.drive: none
		.path:  none
		
		=slash=:   charset "/\"
		=content=: complement =slash=
		=letter=:  charset [#"a" - #"z"  #"A" - #"Z"]
		
		;----
		; win32 specific implementation.
		parse/all path [
			2 =slash=
			copy .host some =content=
			=slash=
			copy .drive =letter= 
			[
				"$"
				| .backup: =slash= :.backup
			]
			
			.here: [
				;=slash=
				to end
			]
		]
		
		if all [
			extract
			.here
		][
			;print "REMOVING"
			remove/part path .here
			insert path join .drive ":"
		]
		
		;?? .host
		;?? .drive
		;?? path
	
		;vout
		.host
	]
	
	



	;--------------------------
	;-     file-info()
	;--------------------------
	; purpose:  get extended file information, using get-modes and finfo
	;--------------------------
	file-info: funcl [
		[catch]
		path [file!]
	][
		throw-on-error [
			all [
				target: make port! path
				( 
					query target 
					target/status 
				)
				target/status
				info: get-modes target [ 
					creation-date 
					access-date 
					modification-date 
					hidden 
					system
				]
				append info compose [
					size: (target/size) 
					path: (path)
					directory:  (directory-of path)
					filename: (filename-of  path)
					extension: (extension-of  path)
					metrics-checksum: none
				]
				info: context info
			]
			info/metrics-checksum: ( checksum rejoin [ "" info/modification-date info/size path ] )
			info 
		]
	]



	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FILE / FOLDER MANIPULATION FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-     delete-tree()
	;--------------------------
	; purpose:  do a recursive folder delete.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    uses only REBOL native functions and our own dir-tree above.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	delete-tree: funcl [
		path [file!]
	][
		vin "delete-tree()"
	
		list: dir-tree/absolute path
		
		list: sort/reverse list
		foreach path list [
			delete path
		]
	
		vout
	]


	
	;--------------------------
	;-     os-copy()
	;--------------------------
	; purpose:  Creates a copy of a file, using standard OS routines..
	;
	; inputs:   
	;
	; returns:  destination on success, raises error on input or OS error.
	;
	; notes:    -Source and destination can be different volumes
	;
	;           -if destination is a dir path, we use the source filename
	;
	;           -Replaces destination if it already exists.
	;
	;           -preserves file attributes
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	os-copy: funcl [
		[catch]
		source [file!]
		destination [file!]
	][
		throw-on-error [
			if is-dir? destination [
				unless f: filename-of source [
					to-error "win32-copy() needs a source path with filename."
				]
				destination: join destination f
			]
			
			result: (Copyfile to-local-file source   to-local-file destination )
			either (0 = result) [
				
				to-error rejoin ["os-copy() OS returned failure on copy.^/" to-local-file source]
			][
				destination
			]
		]
	]
	

		
	;--------------------------
	;-     mv()
	;--------------------------
	; purpose:  moves a directory or file, using system call move 
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    - if the to path is a folder, it will attempt to put it within that folder.
	;           - if it's a file path, it will rename the from path to the given path.
	;           
	;           - we do not verify if the from path is a folder or a file, you should be aware.
	;
	;               ex: 
	;                   mv %/a/b/c  %/d/e      renames c folder as   %/d/e/     ; note that /d/e/  MUST NOT exist or an overwire error occurs.
	;                   mv %/a/b/c  %/d/e/     puts content into     %/d/e/c/
	;
	;           - this function is setup to fail if we attempt to move a directory into a path which already exists.
	;
	;           - note that we deep create the destination folder in all cases.
	;
	; to do:    -replace the CALL command with some routines so we don't need to show a DOS console 
	;
	; tests:    
	;--------------------------
	mv: funcl [
		[catch]
		source [file!]
		destination [file!]
		/admin "Allow moving root and volumes (only applies to directory type sources)"
	][
		vin "mv()"
		
		if platform-name <> 'win32 [
			throw make error! "utils-fils.r/MV() only win32 supported. "
		]
		
		in-buffer:  make string! 10000
		out-buffer: make string! 10000
		err-buffer: make string! 10000
		
		v?? source
		source: clean-path source 
		
		if dir? source [
			vprint "source is actually a directory on disk!"
			source: dirize source
		]
		v?? source

		unless exists? source [
			throw make error! "Source path doesn't exist"
		]

		v?? destination
		destination: clean-path destination
		v?? destination
		
		either is-file? source [
			;---
			; found a FILE path
			;         ----
			vprint "dumping source FILE INTO destination"
			d-items: itemize-path destination
			v?? d-items
			
			dest-dir: dirize destination

			fname: filename-of source
			v?? fname

			destination: join dest-dir fname
			v?? destination

			if exists? destination [
				throw make error!  "cannot overwrite file that already exists" 
			]
			
			unless exists? dest-dir [
				vprint "CREATING destination folder"
				v?? dest-dir
				make-dir/deep dest-dir
			]

			sys-source: to-local-file source
			sys-destination:   to-local-file destination
			v?? sys-source
			v?? sys-destination
			
			cmd: rejoin [ {move "} sys-source {"  "} sys-destination {"} ]
			
			v?? cmd
			
			;call/wait/output/error cmd   out-buffer  err-buffer
			call/show/wait/output/error cmd   out-buffer  err-buffer
			

			v?? out-buffer
			unless empty? err-buffer [
				v?? err-buffer
				throw make error! rejoin ["SYSTEM ERROR while moving file: " err-buffer ]
			]
			
		][	
			;---
			; found a DIRECTORY path
			;         ---------
			
			;---
			; by default, we do not allow copying from volumes or the root! (just a safety precaution)
			if all [
				not admin 
				any [
					volume? source
					root? source
				]
			][
				throw make error! "Invalid source, cannot move root or volume."
			]
			
			either is-dir? destination  [
				;-------------------
				; attempt to copy INTO path
				;--- 
				vprint "INTO path"
				destination: dirize destination
				dest-dir: copy destination
				
				d-items: itemize-path source
				v?? d-items
				
				last-dir-item: last head remove back tail d-items
				v?? last-dir-item
				if any [
					last-dir-item = "."
					last-dir-item = ".."
					last-dir-item = "/"
				][
					throw make error!  "Invalid source folder specification." 
				]
				v?? dest-dir
				
				destination: join destination last-dir-item
				if exists? destination [
					throw make error!  "cannot overwrite folder which already exists"
				]
				
				v?? destination
				if exists? destination [
					throw make error!  "cannot MOVE source folder, it already exists in destination folder." 
				]
				
				if not exists? dest-dir [
					vprint "creating destination folder"
					make-dir/deep dest-dir
				]
				
				sys-source: to-local-file source
				sys-destination:   to-local-file destination
				v?? sys-source
				v?? sys-destination
				
				cmd: rejoin [ {move "} sys-source {"  "} sys-destination {"} ]
				
				v?? cmd
				
				;call/wait/output/error cmd   out-buffer  err-buffer
				call/show/wait/output/error cmd   out-buffer  err-buffer
	
				v?? out-buffer
				unless empty? err-buffer [
					v?? err-buffer
					throw make error! rejoin ["SYSTEM ERROR while moving folder: " err-buffer ]
				]
			][
				;-------------------
				; attempt to move AS EXACT, GIVEN path 
				;--- 
				vprint "AS PATH"
				
				if exists? destination [
					throw make error!  "cannot MOVE source folder AS a folder that already exists" 
				]
				
				sys-source: to-local-file source
				sys-destination:   to-local-file destination
				v?? sys-source
				v?? sys-destination
				
				cmd: rejoin [ {move "} sys-source {"  "} sys-destination {"} ]
				v?? cmd
				
				;call/wait/output/error cmd   out-buffer  err-buffer
				call/show/wait/output/error cmd   out-buffer  err-buffer
	
				v?? out-buffer
				unless empty? err-buffer [
					v?? err-buffer
					throw make error! rejoin ["SYSTEM ERROR while moving folder: " err-buffer ]
				]
			]
		]
		
		vout
	]

	
	
	
	
]

