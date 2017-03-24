REBOL [
	title:      "String handling tools."
	file:       %utils-strings.r
	version:    1.0.1
	date:       2013-01-09
	
	author:     "Maxim Oliver-Adlhoch"
	purpose:    "Collection of generic, re-useable string! handling functions"
	web:        http://www.revault.org/modules/utils-strings.rmrk
	
	source-encoding: "Windows-1252"
	note:		"slim Library Manager is Required to use this module."

	; SLiM - Steel Library Manager, minimal requirements
	slim-name:    'utils-strings
	slim-version: 1.0.5
	slim-prefix:  none
	slim-update:  http://www.revault.org/downloads/modules/utils-strings.r


	;-- Licensing details --
	copyright:  "Copyright © 2013 Maxim Oliver-Adlhoch"
	license-type: "Apache License v2.0"
	license:      {Copyright © 2013 Maxim Olivier-Adlhoch

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
		2012-02-21 - v1.0.0
			-creation
			-compiling previous code from other libraries
			
		2013-01-09 - v1.0.1
			-Adding slut.r tests.
	}
	;-  \ history 
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-strings
;
;--------------------------------------



slim/register [


	parse-utils: slim/open 'utils-parse none

	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- STRING
	;- 
	;-----------------------------------------------------------------------------------------------------------
	;--------------------
	;-    zfill()
	;
	;		test-group [  zfill  string  utils-strings.r  ] [  ]
	;			[  "0000003" = zfill 3 7     ]
	;			[  "0000666" = zfill 666 7   ]
	;			[  "0000055" = probe zfill "55" 7  ]
	;		end-group
	;
	;--------------------
	zfill: func [
		"left fills the supplied string with zeros to amount size."
		data [string! integer! decimal!]
		length [integer!]
		/local string
	][
		string: either string? data [
			data
		][
			to-string data
		]
		
		if (length? string) < length [
			head insert/dup string "0" (length - length? string)
		]
		head string
	]



	;--------------------
	;-    fill()
	;--------------------
	fill: func [
		"Fills a series to a fixed length"
		data "series to fill, any non series is converted to string!"
		len [integer!] "length of resulting string"
		/with val "replace default space char"
		/right "right justify fill"
		/truncate "will truncate input data if its larger than len"
		/local buffer
	][
		unless series? data [
			data: to-string data
		]
		val: any [
			val " " ; default value
		]
		buffer: head insert/dup make type? data none val len
		either right [
			reverse data
			change buffer data
			reverse buffer
		][
			change buffer data
		]
		if truncate [
			clear next at buffer len
		]
		buffer
	]
	
	
	
	;--------------------------
	;-    coerce-string()
	;--------------------------
	; purpose:  a merge of to-string and as-string, the most memory efficient.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	coerce-string: funcl [
		data
	][
		vin "coerce-string()"
		data: either any-string? data [
			as-string data
		][
			to-string data
		]
		vout
		data
	]
			
				
	;--------------------------
	;-    make-mem-buffer()
	;--------------------------
	; purpose:  Create a mem cleared memory buffer for use with system functions
	;
	; inputs:   when a string is given on input, its length is used.
	;
	; returns:  a 0 filled sting of length bytes.
	;--------------------------
	make-mem-buffer: funcl [
		length [integer! string!]
	][
		;vin "make-mem-buffer()"
		if string? length [
			length: length? string
		]
		;vout/return
		str: head insert/dup make string! length to-char 0 length
	]
	
	
	
	;-----------------
	;-     text-to-lines()
	;-----------------
	text-to-lines: func [
		str [string!]
	][
		either empty? str [
			copy []
		][
			parse/all str "^/"
		]
	]
	
	

	;-----------------
	;-     count-lines()
	;
	; given any string of text, returns at what line that text character
	; is at within the text. (minimum is 1)
	;
	; used to report errors in general.  
	;
	; note that this function is meant to be fast, not memory efficient.
	;-----------------
	count-lines: func [
		string [string!]
	][
		vin [{count-lines()}]
		parse-utils/.line-count: 1
		
		parse/all copy/part head string string parse-utils/=line-counter=
		vout
		parse-utils/.line-count
	]




	;--------------------------
	;-         integer-label()
	;--------------------------
	; purpose:  takes an integer and returns a human readable version of it.
	;
	; inputs:   integer!
	;--------------------------
	integer-label: funcl [
		value [integer!]
		/of type "a string to append to the label"
		/default deftype "string to use when no multiplier is given."
	][
		;vin "integer-label()"
		type:    any [type ""]
		deftype: any [ deftype type ]
		case [
			value > 1'000'000'000 [
				value: value / 1'000'000'000
				value: round/to value 0.01
				rejoin ["" value "G" type]
			]
			value > 1'000'000 [
				value: value / 1'000'000
				value: round/to value 0.1
				rejoin ["" value "M" type]
			]
			value > 1000 [
				value: value / 1000
				value: round/to value 0.1
				rejoin ["" value "K" type]
			]
			'default [
				rejoin ["" value deftype]
			]
		]
		;vout
	]

	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- DATES
	;- 
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-         international-datestring()
	;--------------------------
	; purpose:  just a quick setup to return the prefered international date format in string! format
	;--------------------------
	international-datestring: funcl [
		date [date!]
	][
		rejoin [date/year "-" zfill date/month 2 "-" zfill date/day 2]
	]
	
	
	
	
	;--------------------
	;-    date-time()
	;--------------------
	; use this to prevent having to supply a spec all the time.
	; the /default option of date-time sets this.
	default-date-time-spec: "YYYY-MM-DDThh:mm:ssITZ"
	
	;---
	date-time: func [
		""
		/with spec ; specify
		/using thedate [string! date! time!] ; specify an explicit date instead of now()
		/UTC "removes the timezone from the date being used (given or now)"
		/default ; set the default to /with spec
		/local str date-rules thetime tz-string itz-string
	][
		;vin ["date-time()"]
		
		str: copy ""
		
		
		either spec [
			if default [
				default-date-time-spec: spec
			]
		][
			spec: default-date-time-spec
		]
		
		unless thedate [
			thedate: now/precise
		]
		
		unless thedate/time [
			thedate/time: 0:00 ; specify midnight if time isn't given (TZ unspecified).
		]
		
		;------------------
		; UTC time required, bake any tz into time directly
		;------------------
		if UTC [
			if thedate/zone [
				thedate: thedate - thedate/zone
				thedate/zone: none
			]
		]
		
		
		;------------------
		; set timezone strings
		;------------------
		case [
			(any [
				none? thedate/zone
				thedate/zone = 0:00
			]) [
				tz-string: "+0:00"
				itz-string: "Z"
			]
			
			
			(thedate/zone < 0:00) [
				tz-string: itz-string: mold thedate/zone
			]
			
			'default [
				tz-string: itz-string: rejoin ["+" thedate/zone]
			
			]
		]

		
		;------------------
		; extract time from date information.
		;------------------
		either time? thedate [
			thetime: thedate
			thedate: none
		][
			if thedate/time [
				thetime: thedate/time
				thedate/time: none
			]
		]		
		
		
		;------------------

		;process spec
		;------------------
		filler: complement charset "YMDHhmspPS"
		;error: spec
		itime: true
		
		
		unless parse/case spec [
			some [
				here:
				(error: here)
				; padded dates
				["YYYY" (append str zfill thedate/year 4)] | 
				["YY" (append str copy/part at (zfill (to-string thedate/year) 4) 3 2)] | 
				["MM" (append str zfill thedate/month 2)] |
				["DD" (append str zfill thedate/day 2)] |
				["M" (append str thedate/month)] |
				["D" (append str thedate/day)] |
				
				; padded time
				["hh" (append str zfill thetime/hour 2)] |
				["mm" (append str zfill thetime/minute 2)] |
				["ss" (append str zfill to-integer thetime/second 2)] |
				["SS" (append str zfill (round/to thetime/second 0.001) 6)] | ;precise
				
				; am/pm indicator
				["P" (append str "#@#@#@#")] | 
				["p" (append str "-@-@-@-")] |
				
				; time zone
				["TZ" (append str tz-string)] |  ; LOCAL TZ
				["ITZ" (append str itz-string)] | ; internet TZ - like TZ but prints "Z" when the tz is 0:00 (UTC time)
				
				; american/english style 12hour format
				["H" (
					itime: remainder thetime/hour 12
					if 0 = itime [ itime: 12]
					append str itime
					itime: either thetime/hour >= 12 ["PM"]["AM"]
					)
				] |
				
				; non padded time
				["h" (append str thetime/hour)] |
				["m" (append str thetime/minute)] |
				["s" (append str to-integer thetime/second)] |
				
				; escape a character (skip next)
				["^^" copy val skip (append str val)] |
				
				; copy input
				[copy val some filler (append str val)]
				
			]
			(replace str "#@#@#@#" any [to-string itime ""])
			(replace str "-@-@-@-" lowercase any [to-string itime ""])
		][
			to-error rejoin [
				"date-time() DATE FORMAT ERROR: " spec newline
				"  starting at: "  error newline
				"  valid so far: " str newline
			]
		]
		;vout 
		str
	]
	





]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim  
;
;------------------------------------




