if exists("b:current_syntax")
finish
endif
runtime! syntax/cpp.vim
unlet b:current_syntax
runtime! syntax/objc.vim
syn keyword objCppNonStructure    class template namespace transparent contained
syn keyword objCppNonStatement    new delete friend using transparent contained
let b:current_syntax = "objcpp"
