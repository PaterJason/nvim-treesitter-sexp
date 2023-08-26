(par_tup_lit "(" @sexp.open (_)? @sexp.elem ")" @sexp.close) @sexp.form
(par_arr_lit "@(" @sexp.open (_)? @sexp.elem ")" @sexp.close) @sexp.form
(sqr_tup_lit "[" @sexp.open (_)? @sexp.elem "]" @sexp.close) @sexp.form
(sqr_arr_lit "@[" @sexp.open (_)? @sexp.elem "]" @sexp.close) @sexp.form
(struct_lit "{" @sexp.open (_)? @sexp.elem "}" @sexp.close) @sexp.form
(tbl_lit "@{" @sexp.open (_)? @sexp.elem "}" @sexp.close) @sexp.form
