{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = 'hash',
    )
}}

SELECT
    hash,
    block_number,
    date,
    from_address,
    to_address,
    value,
    receipt_contract_address,
    input

FROM {{ source('eth', 'transactions')}}

{% if is_incremental() %}
  WHERE date >= (select max(date) from {{ this }})
{% endif %}