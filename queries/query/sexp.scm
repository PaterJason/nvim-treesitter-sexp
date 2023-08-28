[
 (named_node)
 (anonymous_node)
 (grouping)
 (predicate)
 (list)
 (field_definition)
 ] @sexp.elem
(parameters (_) @sexp.elem)

[
 (named_node "(" @sexp.open ")" @sexp.close)
 (grouping "(" @sexp.open ")" @sexp.close)
 (predicate "(" @sexp.open ")" @sexp.close)
 (list "[" @sexp.open "]" @sexp.close)
 ] @sexp.form
