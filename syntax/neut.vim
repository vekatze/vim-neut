if exists('b:current_syntax')
  finish
endif

syntax case match

syntax keyword neutKeyword arrow attach bind case default detach else else-if elseIf exact external foreign function if import in inline introspect let match nominal of on resource tie try use when with
syntax keyword neutConstant this
syntax keyword neutBuiltin assert magic target-arch target-os target-platform _
syntax keyword neutType tau

syntax keyword neutAdmit admit

syntax keyword neutDefinition define inline constant data nextgroup=neutFunction skipwhite
syntax match neutFunction /\<[^,() {}:;]*\>/ display contained

syntax match neutOperator '[=*&|<>!\?\|+\.,:;]'
syntax match neutComment /\/\/.*/

syntax match neutDoubleQuoteEscape /\\[\\"$\n]/ contained

syntax region neutString start=/"/ skip=/\v(\\{2})|(\\)"/ end=/"/ contains=neutDoubleQuoteEscape

syntax match neutConstructor /\<_*[A-Z][^,() {}:;]*\>/

highlight default link neutComment Comment
highlight default link neutKeyword Keyword
highlight default link neutDefinition Keyword
highlight default link neutFunction Function
highlight default link neutOperator Operator
highlight default link neutString String
highlight default link neutAdmit Debug
highlight default link neutType Type
highlight default link neutConstructor Type
highlight default link neutConstant Constant
highlight default link neutBuiltin Special

let b:current_syntax = 'neut'
