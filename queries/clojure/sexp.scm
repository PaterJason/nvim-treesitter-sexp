([
  ; atom-ish
  (num_lit)
  (kwd_lit)
  (str_lit)
  (char_lit)
  (nil_lit)
  (bool_lit)
  (sym_lit)
  ; basic collection-ish
  (list_lit)
  (map_lit)
  (vec_lit)
  ; dispatch reader macros
  (set_lit)
  (anon_fn_lit)
  (regex_lit)
  (read_cond_lit)
  (splicing_read_cond_lit)
  (ns_map_lit)
  (var_quoting_lit)
  (sym_val_lit)
  (evaling_lit)
  (tagged_or_ctor_lit)
  ; some other reader macros
  (derefing_lit)
  (quoting_lit)
  (syn_quoting_lit)
  (unquote_splicing_lit)
  (unquoting_lit)
  ] @sexp.elem)

[
 (anon_fn_lit open: _ @sexp.open close: _ @sexp.close)
 (list_lit open: _ @sexp.open close: _ @sexp.close)
 (map_lit open: _ @sexp.open close: _ @sexp.close)
 (ns_map_lit open: _ @sexp.open close: _ @sexp.close)
 (read_cond_lit open: _ @sexp.open close: _ @sexp.close)
 (set_lit open: _ @sexp.open close: _ @sexp.close)
 (splicing_read_cond_lit open: _ @sexp.open close: _ @sexp.close)
 (vec_lit open: _ @sexp.open close: _ @sexp.close)
 ] @sexp.form
