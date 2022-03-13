-- 2021年订单销售表
drop view if exists order_info_td_view;
create view order_info_td_view as
select siv.supplier_name
,siv.supplier_code
,ppb.product_id
,date_format(pbi.date_created, '%Y-%m-%d') dt
,sum(ppb.qty) sale_qty
,sum(ppb.amt) gmv
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
left join sku_info_view siv on siv.product_id = ppb.product_id
where 1 = 1
and pbi.date_created >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s')
group by siv.supplier_name
,siv.supplier_code
,ppb.product_id
,date_format(pbi.date_created, '%Y-%m-%d')
;