REBOL [
    ; -- Core Header attributes --
    title: "Parsing tools and utilities"
    file: %utils-parse.r
    version: 1.0.0
    date: 2013-9-12
    author: "Maxim Olivier-Adlhoch"
    purpose: "Basic rules and parsing helpers."
    web: http://www.revault.org/modules/utils-parse.rmrk
    source-encoding: "Windows-1252"
    note: {slim Library Manager is Required to use this module.}

    ; -- slim - Library Manager --
    slim-name: 'utils-parse
    slim-version: 1.2.1
    slim-prefix: none
    slim-update: http://www.revault.org/downloads/modules/utils-parse.r

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
        v0.0.1 - 2013-01-07
            -creation of file.
    
        v1.0.0 - 2013-09-12
            -license changed to Apache v2
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
; test-enter-slim 'utils-parse
;
;--------------------------------------


slim/register [


    ;-   generic core parse rules
    ;core-rules: context [
    
        =digit=: charset "0123456789"
        =alpha=: charset [#"a" - #"z" #"A" - #"Z"]
        =digits=: [some =digit=]
        =newline=: [ crlf | newline ]
        
		=space=: charset " ^-"
		=spaces=: [ SOME =space= ]
        =whitespace=: charset " ^-^/"
        =whitespaces=: [some =whitespace=] ; optional space (often after newline or between known delimiter)
        
        =colon=: charset ":"
        =lbl-char=: union (union =alpha= =digit=) charset "-_"
        =token-word=: [=alpha= any =api-lbl-char=]
        =lbl=: :=token-word= ;[=alpha= any =api-lbl-char=]

		=comment=: [";" [ [to "^/"] | [ to end]]]


    
    ;]
    
    
    

    ;------------------------------------------------------------------------------
    ;
    ;-    parse-flow control
    ;
    ;------------------------------------------------------------------------------
    !fail-rule!: [to end skip]
    ?head?: 
    
    ?continue?: none  ; yes by default... use CONTINUE-IF()  function
    
    
    ;--------------------------
    ;-     continue-if()
    ;--------------------------
    continue-if: funcl [
        condition [logic! none!]
        /extern ?continue?
    ][
        either condition [
            ?continue?: none 
        ][
            ?continue?: !fail-rule!
        ]
    ]
    

    ;-    applied rules
    .line-count: 0
    =line-counter=:  [
        ; (.line-count: 0) we do not reset by default. !!!!
        any [
            [ crlf | newline ] (.line-count: .line-count + 1) 
            | skip
        ]
    ]



    
    
    ;--------------------------
    ;-     bind-rule()
    ;--------------------------
    ; purpose:  given a block of code, bind any of OUR rules within it.
    ;
    ; inputs:   a block of parse rules to bind our rules to.
    ;
    ; returns:  the input rules, but bound.
    ;--------------------------
    bind-rule: funcl [
        rule [block!]
    ][
        vin "bind-rules()"
        bind rule self
        vout
        
        rule
    ]
    
    

]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

