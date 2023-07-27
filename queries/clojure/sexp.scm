([
  ; atom-ish
  (num_lit)
  (kwd_lit)
  (str_lit)
  (char_lit)
  (nil_lit)
  (bool_lit)
  (sym_lit)
  ; dispatch reader macros
  (regex_lit)
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
  ] @sexp.outer)

(anon_fn_lit            open: _ @sexp.open . (_)* . close: _ @sexp.close) @sexp.outer
(list_lit               open: _ @sexp.open . (_)* . close: _ @sexp.close) @sexp.outer
(map_lit                open: _ @sexp.open . (_)* . close: _ @sexp.close) @sexp.outer
(ns_map_lit             open: _ @sexp.open . (_)* . close: _ @sexp.close) @sexp.outer
(read_cond_lit          open: _ @sexp.open . (_)* . close: _ @sexp.close) @sexp.outer
(set_lit                open: _ @sexp.open . (_)* . close: _ @sexp.close) @sexp.outer
(splicing_read_cond_lit open: _ @sexp.open . (_)* . close: _ @sexp.close) @sexp.outer
(vec_lit                open: _ @sexp.open . (_)* . close: _ @sexp.close) @sexp.outer
