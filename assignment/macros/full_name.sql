{#
  A reusable Jinja function (macro). Abstracts the "stitch first + last name"
  logic so no model repeats the concatenation by hand.
  Call it with:  {{ full_name('first_name', 'last_name') }}
#}
{% macro full_name(first_col, last_col) -%}
    {{ first_col }} || ' ' || {{ last_col }}
{%- endmacro %}