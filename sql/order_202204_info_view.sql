-- 2022年4月份销售订单
drop view if exists order_202204_info_view;
create view order_202204_info_view as
select ppb.product_id
,sum(ppb.qty) sale_qty
,sum(ppb.amt) gmv
,sum(if(pbi.date_created >= date_sub(now(), interval 3 day), ppb.amt, 0)) gmv_3d
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
where 1 = 1
and pbi.date_created >= str_to_date('2022-04-01', '%Y-%m-%d %H:%i:%s')
and pbi.date_created < str_to_date('2022-05-01', '%Y-%m-%d %H:%i:%s')
group by ppb.product_id
;