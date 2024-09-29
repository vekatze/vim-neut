if exists('b:current_syntax')
  finish
endif

syntax case match

syntax keyword neutKeyword attach bind box case catch constant data default define detach do else else-if exact external function if in inline introspect let letbox letbox-T match of on pin quote resource tie try use when with
syntax keyword neutConstant this
syntax keyword neutBuiltin assert magic include-text static _
syntax keyword neutType type thread meta rune

syntax keyword neutAdmit admit

syntax keyword neutDefinition define inline constant data nextgroup=neutFunction skipwhite
syntax keyword neutStatement foreign import nominal
syntax match neutFunction /\<[^,() {}:;]*\>/ display contained

syntax match neutOperator '[=*&|<>!\?\|+\.,:;]'
syntax match neutComment /\/\/.*/

syntax match neutDoubleQuoteEscape /\\[\\"$\n]/ contained
syntax match neutBacktickEscape /\\[\\`$\n]/ contained

syntax region neutString start=/"/ skip=/\v(\\{2})|(\\)"/ end=/"/ contains=neutDoubleQuoteEscape
syntax region neutBacktickString start=/`/ skip=/\v(\\{2})|(\\)`/ end=/`/ contains=neutBacktickEscape

syntax match neutConstructor /\<_*[A-Z][^,() {}:;]*\>/

highlight default link neutComment Comment
highlight default link neutKeyword Keyword
highlight default link neutDefinition Statement
highlight default link neutStatement Statement
highlight default link neutFunction Function
highlight default link neutOperator Operator
highlight default link neutString String
highlight default link neutBacktickString String
highlight default link neutAdmit Debug
highlight default link neutType Type
highlight default link neutConstructor Type
highlight default link neutConstant Constant
highlight default link neutBuiltin Constant

let b:current_syntax = 'neut'
