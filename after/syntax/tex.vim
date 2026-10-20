syntax match texE3KeyProperty "\.\%([A-Za-z_][A-Za-z_]*\)\%(:[A-Za-z]*\)\?" contained containedin=@texClusterE3

highlight! link texE3Cmd Function
highlight! link texE3Function Function
highlight! link texE3Type Identifier
highlight! link texE3Variable Identifier
highlight! link texE3Constant Constant
highlight! link texE3Delim Delimiter
highlight! link texE3Parm Delimiter
highlight! link texE3Keyword Statement
highlight! link texE3KeyProperty Identifier
highlight! link texMathSymbol Operator
highlight! link texMathOper Operator
highlight! link texMathDelim Delimiter
highlight! link texMathDelimMod Delimiter
highlight! link texMathEnvArgName Type
