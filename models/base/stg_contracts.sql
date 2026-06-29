{{ config(materialized = 'view') }}

SELECT
    address,
    block_number,
    bytecode,
    date,
    last_modified

FROM {{ source('eth', 'contracts') }}
