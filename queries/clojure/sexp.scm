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

((_ open: _ @sexp.open close: _ @sexp.close) @sexp.form
 (#not-has-parent? @sexp.form
  derefing_lit
  quoting_lit
  syn_quoting_lit
  unquote_splicing_lit
  unquoting_lit))

((_ (_ open: _ @sexp.open close: _ @sexp.close)) @sexp.form
 (#has-type? @sexp.form
  derefing_lit
  quoting_lit
  syn_quoting_lit
  unquote_splicing_lit
  unquoting_lit))
