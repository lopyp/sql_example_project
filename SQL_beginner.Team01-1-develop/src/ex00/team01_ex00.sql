--delete from currency values  where rate_to_usd = 0.85;
--delete from currency values  where rate_to_usd = 0.79;

with current_course AS (
  select id, name, max(updated) as last from currency
  group by id, name
)
select coalesce("user".name, 'not defined') name,  coalesce(lastname, 'not defined') lastname, balance.type,
       SUM(balance.money) volume, coalesce(current_course.name, 'not defined') currency_name,
       coalesce(currency.rate_to_usd, 1) last_rate_to_usd,
       (coalesce(currency.rate_to_usd, 1) * SUM(balance.money)) total_volume_in_usd from "user"
  full join balance on balance.user_id = public."user".id
  full join current_course on balance.currency_id = current_course.id
  full join currency on current_course.id = currency.id and current_course.name = currency.name and current_course.last = currency.updated
group by "user".name, "user".lastname, balance.type, currency_name, currency.rate_to_usd
having balance.type is not null
order by 1 desc , 2, 3;