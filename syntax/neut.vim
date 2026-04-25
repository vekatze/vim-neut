if exists('b:current_syntax')
  finish
endif

syntax case match
syntax iskeyword @,48-57,_,192-255,-,.

syntax keyword neutKeyword bind box case default else else-if exact external foreign if import introspect let letbox letbox-T lift match nominal on pack-type pin promote quote tie try unbox unpack-type unquote when with
syntax keyword neutConstant this
syntax keyword neutBuiltin _ assert magic static text-file
syntax keyword neutType pointer rune type void

syntax keyword neutAdmit admit

syntax keyword neutDefinition alias alias-opaque constant data define define-meta inline inline-meta memoize resource rule-left rule-right nextgroup=neutFunction skipwhite
syntax keyword neutStatement foreign import nominal
syntax match neutFunction #[^[:space:]=()`"':;,<>\[\]{}/*+|&?!]\+# display contained

syntax match neutBuiltin /=>>\|=>\|->>\|->\|=/
syntax match neutOperator /[\\*|!,:+&@?;'"$^#~]/
syntax match neutComment /\/\/.*/

syntax match neutDoubleQuoteEscape /\\[\\"$\n]/ contained
syntax match neutBacktickEscape /\\[\\`$\n]/ contained

syntax region neutString start=/"/ skip=/\v(\\{2})|(\\)"/ end=/"/ contains=neutDoubleQuoteEscape
syntax region neutBacktickString start=/`/ skip=/\v(\\{2})|(\\)`/ end=/`/ contains=neutBacktickEscape

syntax match neutConstructor /\v(^|[^-A-Za-z0-9_.])\zs_?\.?[A-Z][-A-Za-z0-9_]*/

highlight default link neutComment Comment
highlight default link neutKeyword Keyword
highlight default link neutDefinition Keyword
highlight default link neutStatement Keyword
highlight default link neutFunction Function
highlight default link neutOperator Special
highlight default link neutString String
highlight default link neutBacktickString String
highlight default link neutAdmit WarningMsg
highlight default link neutType Type
highlight default link neutConstructor Type
highlight default link neutConstant Constant
highlight default link neutBuiltin Special

let b:current_syntax = 'neut'
