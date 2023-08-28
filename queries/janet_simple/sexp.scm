[
 (par_tup_lit "(" @sexp.open (_)? @sexp.elem ")" @sexp.close)
 (par_arr_lit "@(" @sexp.open (_)? @sexp.elem ")" @sexp.close)
 (sqr_tup_lit "[" @sexp.open (_)? @sexp.elem "]" @sexp.close)
 (sqr_arr_lit "@[" @sexp.open (_)? @sexp.elem "]" @sexp.close)
 (struct_lit "{" @sexp.open (_)? @sexp.elem "}" @sexp.close)
 (tbl_lit "@{" @sexp.open (_)? @sexp.elem "}" @sexp.close)
 ] @sexp.form
