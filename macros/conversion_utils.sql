{% macro ethereum_conversion(column_name) %}
  sum( {{column_name}}) / 1e18
{% endmacro %}

{% macro stablecoin_conversion(args) %}
  sum( {{args}} ) / 1e6
{% endmacro %}

{% macro conversion(column, factor) %}
  sum( {{column}}  / power(10, {{factor}}))
{% endmacro %}