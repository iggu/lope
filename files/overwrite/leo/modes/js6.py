# Leo colorizer control file for javascript mode.
# This file is in the public domain.


# Properties for javascript mode.

properties = {
    "commentEnd": "*/",
    "commentStart": "/*",
    "doubleBracketIndent": "false",
    "indentCloseBrackets": "}",
    "indentNextLine": "\\s*(((if|while)\\s*\\(|else\\s*|else\\s+if\\s*\\(|for\\s*\\(.*\\))[^{;]*)",
    "indentOpenBrackets": "{",
    "lineComment": "//",
    "lineUpClosingBracket": "true",
    "wordBreakChars": ",+-=<>/?^&*",
}


# Keywords dict for js6_lang ruleset.
js6_main_keywords_dict = {
    "__comment1": "comment1",
    "__comment2": "comment2",
    "__comment3": "comment3",
    "__comment4": "comment4",
    "__doc-part": "doc-part",
    "__function": "function",
    "__keyword1": "keyword1",
    "__keyword2": "keyword2",
    "__keyword3": "keyword3",
    "__keyword4": "keyword4",
    "__keyword5": "keyword5",
    "__label": "label",
    "__leo-keyword": "leo-keyword",
    "__link": "link",
    "__literal1": "literal1",
    "__literal2": "literal2",
    "__literal3": "literal3",
    "__literal4": "literal4",
    "__markup": "markup",
    "__name": "name",
    "__name-brackets": "name-brackets",
    "__null": "null",
    "__operator": "operator",
    "__show-invisibles-space": "show-invisibles-space",
    "__tab": "tab",
    "__trailing-whitespace": "trailing-whitespace",
    "__url": "url",

    "Array": "keyword4",
    "Boolean": "keyword4",
    "Date": "keyword4",
    "Function": "keyword4",
    "Global": "keyword4",
    "Math": "keyword4",
    "NaN": "keyword4",
    "Number": "keyword4",
    "Object": "keyword4",
    "RegExp": "keyword4",
    "String": "keyword4",
    "Error": "keyword4",
    "Promise": "keyword4",

    "class": "keyword2",
    "extends": "keyword2",
    "static": "keyword2",
    "function": "keyword2",
    "get": "keyword2",
    "set": "keyword2",
    "constructor": "keyword2",
    "async": "keyword2",
    "await": "keyword2",

    "let": "keyword5",
    "var": "keyword5",
    "const": "keyword5",
    "new": "keyword5",
    "instanceof": "keyword5",
    "typeof": "keyword5",
    "delete": "keyword5",

    "try": "keyword1",
    "throw": "keyword1",
    "catch": "keyword1",
    "then": "keyword1",
    "finally": "keyword1",
    "for": "keyword1",
    "of": "keyword1",
    "in": "keyword1",
    "while": "keyword1",
    "switch": "keyword1",
    "case": "keyword1",
    "default": "keyword1",
    "if": "keyword1",
    "else": "keyword1",
    "do": "keyword1",

    "break": "keyword2",
    "continue": "keyword2",
    "return": "keyword2",
    "yield": "keyword2",
    "debugger": "keyword2",

    "this": "keyword4",
    "that": "keyword4",
    "self": "keyword4",
    "super": "keyword5",

    "export": "keyword4",
    "import": "keyword4",
    "package": "keyword4",
    "as": "keyword4",
    "from": "keyword4",

    "void": "null",
    "null": "null",
    "undefined": "null",
    "false": "null",
    "true": "null",
    "NaN": "null",
    "Infinity": "null",

    "console": "keyword4",
    "window": "keyword4",
    "document": "keyword4",
    "global": "keyword4",
    "globalThis": "keyword4",
    "eval": "literal4",
    "isFinite": "literal4",
    "isNaN": "literal4",
}

def js6_main_match_keywords_rule(colorer, s, i):
    return colorer.match_keywords(s, i)



def js6_jsdoc_comment_rule(colorer, s, i):
    return colorer.match_span(s, i, kind="comment3", begin="/**", end="*/",
        at_line_start=False, at_whitespace_end=False, at_word_start=False,
        delegate="js6::jsdocs",exclude_match=False,
        no_escape=False, no_line_break=False, no_word_break=False)

def js6_comment_multiline_rule(colorer, s, i):
    return colorer.match_span(s, i, kind="comment1", begin="/*", end="*/",
        at_line_start=False, at_whitespace_end=False, at_word_start=False,
        delegate="",exclude_match=False,
        no_escape=False, no_line_break=False, no_word_break=False)

def js6_comment_singleline_rule(colorer, s, i):
    return colorer.match_eol_span(s, i, kind="comment2", seq="//",
        at_line_start=False, at_whitespace_end=False, at_word_start=False,
        delegate="", exclude_match=False)

def js6_main_doublequote_rule(colorer, s, i):
    return colorer.match_span(s, i, kind="literal1", begin="\"", end="\"",
        at_line_start=False, at_whitespace_end=False, at_word_start=False,
        delegate="",exclude_match=False,
        no_escape=False, no_line_break=True, no_word_break=False)

def js6_main_singlequote_rule(colorer, s, i):
    return colorer.match_span(s, i, kind="literal2", begin="'", end="'",
        at_line_start=False, at_whitespace_end=False, at_word_start=False,
        delegate="",exclude_match=False,
        no_escape=False, no_line_break=True, no_word_break=False)

def js6_main_backquote_rule(colorer, s, i):
    return colorer.match_span(s, i, kind="literal3", begin="`", end="`",
        at_line_start=False, at_whitespace_end=False, at_word_start=False,
        delegate="js6::template_literals",exclude_match=False,
        no_escape=False, no_line_break=False, no_word_break=False)

def js6_openparen_rule(colorer, s, i):
    return colorer.match_seq(s, i, kind="label", seq="(",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_closeparen_rule(colorer, s, i):
    return colorer.match_seq(s, i, kind="label", seq=")",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule3(colorer, s, i):
    return colorer.match_mark_previous(s, i, kind="function", pattern="(",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, exclude_match=True)

def js6_rule6(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="=",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule7(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="!",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule8(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq=">=",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule9(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="<=",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule10(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="+",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule11(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="-",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule12(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="/",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule13(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="*",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule14(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq=">",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule15(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="<",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule16(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="%",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule17(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="&",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule18(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="|",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule19(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="^",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule20(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="~",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule21(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq=".",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule22(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="}",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule23(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="{",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule24(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq=",",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule25(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq=";",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule26(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="]",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule27(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="[",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule28(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq="?",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")

def js6_rule29(colorer, s, i):
    return colorer.match_mark_previous(s, i, kind="label", pattern=":",
        at_line_start=False, at_whitespace_end=True, at_word_start=False, exclude_match=True)

def js6_rule30(colorer, s, i):
    return colorer.match_seq(s, i, kind="operator", seq=":",
        at_line_start=False, at_whitespace_end=False, at_word_start=False, delegate="")


# Rules dict for js6_lang ruleset.
js6_main_rules_dict = {
    "!": [js6_rule7,],
    '"': [js6_main_doublequote_rule,],
    "'": [js6_main_singlequote_rule,],
    "`": [js6_main_backquote_rule,],
    "%": [js6_rule16,],
    "&": [js6_rule17,],
    "(": [js6_openparen_rule,],
    ")": [js6_closeparen_rule,],
    "*": [js6_rule13,],
    "+": [js6_rule10,],
    ",": [js6_rule24,],
    "-": [js6_rule11,],
    ".": [js6_rule21,],
    "/": [js6_jsdoc_comment_rule,js6_comment_multiline_rule,js6_comment_singleline_rule,js6_rule12,],
    "_": [js6_main_match_keywords_rule,],
    "0": [js6_main_match_keywords_rule,],
    "1": [js6_main_match_keywords_rule,],
    "2": [js6_main_match_keywords_rule,],
    "3": [js6_main_match_keywords_rule,],
    "4": [js6_main_match_keywords_rule,],
    "5": [js6_main_match_keywords_rule,],
    "6": [js6_main_match_keywords_rule,],
    "7": [js6_main_match_keywords_rule,],
    "8": [js6_main_match_keywords_rule,],
    "9": [js6_main_match_keywords_rule,],
    ":": [js6_rule29,js6_rule30,],
    ";": [js6_rule25,],
    "<": [js6_rule9,js6_rule15,],
    "=": [js6_rule6,],
    ">": [js6_rule8,js6_rule14,],
    "?": [js6_rule28,],
    "@": [js6_main_match_keywords_rule,],
    "A": [js6_main_match_keywords_rule,],
    "B": [js6_main_match_keywords_rule,],
    "C": [js6_main_match_keywords_rule,],
    "D": [js6_main_match_keywords_rule,],
    "E": [js6_main_match_keywords_rule,],
    "F": [js6_main_match_keywords_rule,],
    "G": [js6_main_match_keywords_rule,],
    "H": [js6_main_match_keywords_rule,],
    "I": [js6_main_match_keywords_rule,],
    "J": [js6_main_match_keywords_rule,],
    "K": [js6_main_match_keywords_rule,],
    "L": [js6_main_match_keywords_rule,],
    "M": [js6_main_match_keywords_rule,],
    "N": [js6_main_match_keywords_rule,],
    "O": [js6_main_match_keywords_rule,],
    "P": [js6_main_match_keywords_rule,],
    "Q": [js6_main_match_keywords_rule,],
    "R": [js6_main_match_keywords_rule,],
    "S": [js6_main_match_keywords_rule,],
    "T": [js6_main_match_keywords_rule,],
    "U": [js6_main_match_keywords_rule,],
    "V": [js6_main_match_keywords_rule,],
    "W": [js6_main_match_keywords_rule,],
    "X": [js6_main_match_keywords_rule,],
    "Y": [js6_main_match_keywords_rule,],
    "Z": [js6_main_match_keywords_rule,],
    "[": [js6_rule27,],
    "]": [js6_rule26,],
    "^": [js6_rule19,],
    "a": [js6_main_match_keywords_rule,],
    "b": [js6_main_match_keywords_rule,],
    "c": [js6_main_match_keywords_rule,],
    "d": [js6_main_match_keywords_rule,],
    "e": [js6_main_match_keywords_rule,],
    "f": [js6_main_match_keywords_rule,],
    "g": [js6_main_match_keywords_rule,],
    "h": [js6_main_match_keywords_rule,],
    "i": [js6_main_match_keywords_rule,],
    "j": [js6_main_match_keywords_rule,],
    "k": [js6_main_match_keywords_rule,],
    "l": [js6_main_match_keywords_rule,],
    "m": [js6_main_match_keywords_rule,],
    "n": [js6_main_match_keywords_rule,],
    "o": [js6_main_match_keywords_rule,],
    "p": [js6_main_match_keywords_rule,],
    "q": [js6_main_match_keywords_rule,],
    "r": [js6_main_match_keywords_rule,],
    "s": [js6_main_match_keywords_rule,],
    "t": [js6_main_match_keywords_rule,],
    "u": [js6_main_match_keywords_rule,],
    "v": [js6_main_match_keywords_rule,],
    "w": [js6_main_match_keywords_rule,],
    "x": [js6_main_match_keywords_rule,],
    "y": [js6_main_match_keywords_rule,],
    "z": [js6_main_match_keywords_rule,],
    "{": [js6_rule23,],
    "|": [js6_rule18,],
    "}": [js6_rule22,],
    "~": [js6_rule20,],
}


 # Attributes dict for js6_main ruleset.
js6_main_attributes_dict = {
    "default": "null",
    "digit_re": "(0x[[:xdigit:]]+[lL]?|[[:digit:]]+(e[[:digit:]]*)?[lLdDfF]?)",
    "escape": "\\",
    "highlight_digits": "true",
    "ignore_case": "false",
    "no_word_sep": "",
}



def js6_tmplit_param_rule(colorer, s, i):
    return colorer.match_span(s, i, kind="literal4", begin="${", end="}",
        at_line_start=False, at_whitespace_end=False, at_word_start=False,
        delegate="",exclude_match=False,
        no_escape=False, no_line_break=False, no_word_break=False)

# Attributes dict for php_php_literal ruleset.
js6_template_literals_attributes_dict = {
    "default": "LITERAL3",
    "digit_re": "",
    "escape": "\\",
    "highlight_digits": "true",
    "ignore_case": "true",
    "no_word_sep": "",
}

js6_template_literals_keywords_dict = {
}

js6_template_literals_rules_dict = {
    "$": [js6_tmplit_param_rule,],
}



def js6_jsdoc_match_keywords_rule(colorer, s, i):
    r = colorer.match_keywords(s, i)
    print(">>>>", r, s[i:])
    return -r

def js6_jsdoc_instruction_rule(colorer, s, i):
    return colorer.match_span(s, i, kind="comment4", begin="@", end=" ",
        at_line_start=False, at_whitespace_end=False, at_word_start=False,
        delegate="",exclude_match=False,
        no_escape=False, no_line_break=False, no_word_break=False)

# Attributes dict for php_php_literal ruleset.
js6_jsdoc_attributes_dict = {
    "default": "COMMENT3",
    "digit_re": "",
    "escape": "\\",
    "highlight_digits": "true",
    "ignore_case": "true",
    "no_word_sep": "",
}

js6_jsdoc_keywords_dict = {
    "FIXME": "label",
    "TODO": "label",
}

js6_jsdoc_rules_dict = {
    "@": [js6_jsdoc_instruction_rule,],
    'T': [js6_jsdoc_match_keywords_rule,],
    "F": [js6_jsdoc_match_keywords_rule,],
}

# Dictionary of attributes dictionaries for javascript mode.
attributesDictDict = {
    "js6_main": js6_main_attributes_dict,
    "js6_template_literals": js6_template_literals_attributes_dict,
    "js6_docs": js6_jsdoc_attributes_dict,
}


# x.rulesDictDict for javascript mode.
rulesDictDict = {
    "js6_main": js6_main_rules_dict,
    "js6_template_literals": js6_template_literals_rules_dict,
    "js6_jsdocs": js6_jsdoc_rules_dict,
}


# Dictionary of keywords dictionaries for javascript mode.
keywordsDictDict = {
    "js6_main": js6_main_keywords_dict,
    "js6_template_literals": js6_template_literals_keywords_dict,
    "js6_jsdocs": js6_jsdoc_keywords_dict,
}


# Import dict for javascript mode.
importDict = {}

"""


debug cliopt: --trace=coloring

MODES

- main: keywords
- literal: + `${}`
- comment: + jsDoc


unknown:  doc-part function leo-keyword name-brackets show-invisibles-space tab trailing-whitespace

maybe useful: label link markup name url

operators: null operator


comment: comment1 comment2 comment3 comment4
    /**/
    //

keyword: keyword1 keyword2 keyword3 keyword4 keyword5
  
 debugger async await

literal: literal1 literal2 literal3 literal4
  

built_in:
  eval isFinite isNaN parseFloat parseInt decodeURI decodeURIComponent
  encodeURI encodeURIComponent escape unescape Object Function Boolean Error
  EvalError InternalError RangeError ReferenceError StopIteration SyntaxError
  TypeError URIError Number Math Date String RegExp Array Float32Array
  Float64Array Int16Array Int32Array Int8Array Uint16Array Uint32Array
  Uint8Array Uint8ClampedArray ArrayBuffer DataView JSON Intl arguments require
  module console window document Symbol Set Map WeakSet WeakMap Proxy Reflect
  Promise

[( - + < > ? )] "a" 'b' `c`

lambda

function

of
in

"aaa"
'bbb'
`ccc in &`

if ( [ +- ] ) else 

() => { sklcvmsklc }
console.log 

"aaa ${A} ${A+A-A} {}"
'bbb ${B} bbb ${B+B-B} bbb {B} bbb'
`ccc ${A} ccc ${A+A-A} ccc {cc} cc`
"olalal"

class undefined null 

__comment1
__comment2
__comment3
__comment4

__doc-part
__function
__label
__leo-keyword
__link
__markup
__name
__name-brackets
__show-invisibles-space
__tab
__trailing-whitespace
__url

__keyword1
__keyword2
__keyword3
__keyword4
__keyword5
__null
__operator

__literal1
__literal2
__literal3
__literal4

"""

