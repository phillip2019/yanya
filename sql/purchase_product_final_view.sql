-- 计算商品和供应商唯一视图，此视图中某一商品只归属于某一供应商
drop view if exists purchase_product_final_view;
create view purchase_product_final_view as
select piv.supplier_id
,piv.supplier_code
,piv.supplier_name
,piv.product_id
from purchase_product_info_view piv
inner join (
    select max(supplier_id) supplier_id
    ,product_id
    from purchase_product_info_view piv
    where piv.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s')
    group by product_id
) product_supplier_tbl on product_supplier_tbl.product_id = piv.product_id
                        and product_supplier_tbl.supplier_id = piv.supplier_id
where piv.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s')
group by piv.supplier_id
,piv.supplier_code
,piv.supplier_name
,piv.product_id
;