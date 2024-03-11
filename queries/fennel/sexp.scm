[
 (_ "(" @sexp.open (_)? @sexp.elem ")" @sexp.close)
 (sequence "[" @sexp.open (_)? @sexp.elem "]" @sexp.close)
 (table "{" @sexp.open (_)? @sexp.elem "}" @sexp.close)
 ] @sexp.form
(program (_) @sexp.elem)
