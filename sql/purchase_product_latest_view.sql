-- 采购商品最新详情信息视图、商品id、商品名称、商品最后采购入库时间
drop view if exists purchase_product_latest_view;
create view purchase_product_latest_view as
select product_id
,max(product_name) product_name
,max(created_at) purchase_latest_at
from erp.purchase_product_info_view
group by product_id
;
