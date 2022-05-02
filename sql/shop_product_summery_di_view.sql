-- 2022年日商铺商品款式spu到店销量、销售额
drop view if exists shop_product_summery_di_view;
create view shop_product_summery_di_view as
select pbi.shop_id
,pbi.shop_name
,p.spu_code
,p.spu_name
,p.stop_buy
,p.purchase_latest_at
,sum(ppb.qty) product_qty
,sum(pbi.amt) gmv
,date_format(pbi.date_created, '%Y-%m-%d') dt
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
inner join sku_info_view p on p.product_id = ppb.product_id
where 1 = 1
and pbi.date_created >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
-- 最后采购时间为两年前的过滤
and p.purchase_latest_at >= date_sub(now(), INTERVAL 2 YEAR)
group by pbi.shop_id
,pbi.shop_name
,p.spu_code
,p.spu_name
,p.stop_buy
,p.purchase_latest_at
,date_format(pbi.date_created, '%Y-%m-%d')
