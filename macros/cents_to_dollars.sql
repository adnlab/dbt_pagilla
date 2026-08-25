{#
  A reusable Jinja function (macro). Abstracts the "cents -> dollars"
  math so no model has to repeat  amount / 100.0  by hand.
  Call it with:  {{ cents_to_dollars('amount_cents') }}
#}
{% macro cents_to_dollars(column_name, decimal_places=2) -%}
    round({{ column_name }} / 100.0, {{ decimal_places }})
{%- endmacro %}
