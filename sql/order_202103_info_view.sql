-- 2022年3月份销售订单
drop view if exists order_202103_info_view;
create view order_202103_info_view as
select ppb.product_id
,sum(ppb.qty) sale_qty
,sum(ppb.amt) gmv
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
where 1 = 1
and pbi.date_created >= str_to_date('2021-03-01', '%Y-%m-%d %H:%i:%s')
and pbi.date_created < str_to_date('2021-04-01', '%Y-%m-%d %H:%i:%s')
group by ppb.product_id
;