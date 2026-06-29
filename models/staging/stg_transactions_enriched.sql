{{
    config(
        materialized="incremental",
        incremental_strategy="append",
        on_schema_change="sync_all_columns",
    )
}}

with
    token_transfer_aggs as (
        select transaction_hash, count(*) as token_transfer_count,
        from {{ ref("stg_token_transfers") }}
        group by transaction_hash
    ),
    transactions_enriched as (

        select
            t.hash,
            t.block_number,
            t.date,
            t.from_address,
            t.to_address,
            t.value,
            t.receipt_contract_address,
            t.input,
            tt.token_transfer_count,
            1 as new_field,

            case
                when t.receipt_contract_address != ''
                then 'contract_creation'
                when tt.transaction_hash is not null
                then 'token_transfer'
                when t.input = '0x' and t.value > 0
                then 'plain_eth_transfer'
                else 'other'
            end as transaction_category

        from {{ ref("stg_transactions") }} t
        left join token_transfer_aggs tt on t.hash = tt.transaction_hash

        {% if is_incremental() %}
            where date >= (select max(date) from {{ this }})
        {% endif %}
    )

SELECT * FROM transactions_enriched