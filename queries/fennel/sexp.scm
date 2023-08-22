(_ "(" @sexp.open (_)? @sexp.elem ")" @sexp.close) @sexp.form
(sequential_table "[" @sexp.open (_)? @sexp.elem "]" @sexp.close) @sexp.form
(table "{" @sexp.open (_)? @sexp.elem "}" @sexp.close) @sexp.form
(program (_) @sexp.elem)
