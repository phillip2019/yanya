-- 最近3天订单销售额视图
drop view if exists order_3d_info_view;
create view order_3d_info_view as
select ppb.product_id
,sum(ppb.qty) sale_qty
,sum(ppb.amt) gmv
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
where 1 = 1
and pbi.date_created >= date_sub(now(), interval 3 day)
and pbi.date_created < now()
group by ppb.product_id
;