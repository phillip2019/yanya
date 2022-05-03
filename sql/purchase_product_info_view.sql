-- 采购商品详情信息视图
drop view if exists purchase_product_info_view;
create view purchase_product_info_view as
select piv.purchase_id
,piv.site_id
,piv.site_name
,piv.supplier_id
,coalesce(siv.supplier_name, 'unknown') supplier_name
,coalesce(piv.supplier_code, siv.supplier_code, 'unknown') supplier_code
,siv.region
,siv.provice
,siv.city
,siv.area
,piv.wh_id
,piv.wh_code
,piv.wh_name
,piv.purchase_code
,piv.subject
,bdiv.bill_detail_id
,bdiv.product_id
,bdiv.product_name
,bdiv.product_code
,qty
,amt
,piv.created_at
from purchase_info_view piv
left join bill_detail_info_View bdiv on bdiv.bill_id = piv.purchase_id
left join supplier_info_view siv on siv.supplier_id = piv.supplier_id
;



select sum(amt) total_amt
from purchase_product_info_view
where supplier_code = '030791'
and created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s')
and created_at < str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')