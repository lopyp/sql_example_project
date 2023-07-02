
--insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29');
--insert into currency values (100, 'EUR', 0.79, '2022-01-08 13:29');

with before_balance as (
    select user_id, currency_id, balance.updated, max(currency.updated) as nearest from balance
    join currency ON currency.id = balance.currency_id and currency.updated <= balance.updated
    group by balance.updated, currency_id, user_id
),

after_balance as (
    select user_id, currency_id, balance.updated, min(currency.updated) as nearest from balance
    join currency ON currency.id = balance.currency_id and currency.updated > balance.updated
    where balance.currency_id not in (select currency_id from before_balance)
    group by balance.updated, currency_id, user_id
)

,nearest_balance as (

  select * from before_balance union select * from after_balance
)

select coalesce("user".name, 'not defined') name,  coalesce(lastname, 'not defined') lastname, currency.name as currency_name, (money * currency.rate_to_usd) as currency_in_usd from "user"

full join nearest_balance on "user".id = nearest_balance.user_id
join balance on nearest_balance.updated = balance.updated and balance.user_id = nearest_balance.user_id and balance.currency_id = nearest_balance.currency_id
join currency on nearest_balance.currency_id = currency.id and nearest_balance.nearest = currency.updated
where currency.name is not null
order by 1 desc, 2, 3;
