USING: peg.ebnf peg multiline regexp tools.continuations strings sequences sequences.deep vectors kernel prettyprint ;

IN: parser.private

! Define the grammar for the specification language
EBNF: spec-parser [=[
    id = [A-Za-z-][A-Za-z0-9-]* => [[ flatten >string ]]
    type = [A-Za-z-][A-Za-z0-9-]* => [[ flatten >string ]] "[]"?
    version = "version" ":"~ ("1.0" | "2.0" | "1" | "2")
    declaration = type-declaration | method-declaration
    type-declaration = "type" id "{"~ param-list "}"~
    method-declaration = nested-declaration | inline-declaration
    inline-declaration = id ":"~ (params row params) ";"~
    params = "("~ (param-list?) => [[ dup [ drop V{ } ] unless ]] ")"~
    param-decl = (id "?"? ":"~ type) => [[ flatten ]]
    param-list = ((param-decl)((","~ param-decl)* => [[ dup empty? [ drop ignore ] [ flatten1 ] if ]]))
    row = ("-->" | "<--") => [[ "-->" = [ "cts" ] [ "stc" ] if]]
    nested-declaration = id "{"~ nested-decl-entries+ "}"~
    nested-decl-entries = separator-decl | method-declaration
    separator-decl = "separator" ":"~ ((!(";") .)+ => [[ >string ]]) ";"~
    start = version declaration+

]=]

: remove-comments ( spec -- clean-spec ) R/ \/\/.*\n?/ "" re-replace ; 
: remove-unneeded-whitespace ( spec -- clean-spec ) R/ [\t\r\n ]+/ "" re-replace ;
: clean-spec ( spec -- cleaned-spec ) remove-comments remove-unneeded-whitespace ;

IN: parser
: parse ( spec -- ast ) clean-spec spec-parser ;
