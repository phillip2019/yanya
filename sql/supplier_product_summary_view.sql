-- 供应商产品销售概况（产品款式数量、销售金额、进货金额、滞销占比)
-- 供应商名称、SPU数量、1-3月进货金额、4-6月进货金额、7-9月进货金额、10-12月进货金额、销售金额、1-3月退货金额、4-6月退货金额、7-9月退货金额、库存金额、存销比
drop view if exists supplier_product_summary_view;
create view supplier_product_summary_view as
select supplier_purchase_tbl.level1
,supplier_purchase_tbl.supplier_id
,supplier_purchase_tbl.supplier_code
,supplier_purchase_tbl.supplier_name
,supplier_purchase_tbl.spu_2021_num
,supplier_purchase_tbl.sku_2021_num
,supplier_purchase_tbl.spu_2022_num
,supplier_purchase_tbl.sku_2022_num
,supplier_purchase_tbl.purchase_2021_amt
,supplier_purchase_tbl.purchase_2022_amt
,supplier_purchase_tbl.purchase_2021_01_03_amt
,supplier_purchase_tbl.purchase_2021_04_06_amt
,supplier_purchase_tbl.purchase_2021_07_09_amt
,supplier_purchase_tbl.purchase_2021_10_12_amt
,supplier_purchase_tbl.purchase_2022_01_03_amt
,coalesce(supplier_order_tbl.gmv_2021, 0) gmv_2021
,coalesce(supplier_order_tbl.gmv_2022, 0) gmv_2022
,coalesce(supplier_order_tbl.gmv_2021_01_03, 0) gmv_2021_01_03
,coalesce(supplier_order_tbl.gmv_2021_04_06, 0) gmv_2021_04_06
,coalesce(supplier_order_tbl.gmv_2021_07_09, 0) gmv_2021_07_09
,coalesce(supplier_order_tbl.gmv_2021_10_12, 0) gmv_2021_10_12
,coalesce(supplier_order_tbl.gmv_2022_01_03, 0) gmv_2022_01_03
,coalesce(supplier_order_tbl.gmv_2022_03, 0) gmv_2022_03
,coalesce(supplier_refund_tbl.refund_amt_2021, 0) refund_amt_2021
,coalesce(supplier_refund_tbl.refund_amt_2022, 0) refund_amt_2022
,coalesce(supplier_refund_tbl.refund_amt_2021_01_03, 0) refund_amt_2021_01_03
,coalesce(supplier_refund_tbl.refund_amt_2021_04_06, 0) refund_amt_2021_04_06
,coalesce(supplier_refund_tbl.refund_amt_2021_07_09, 0) refund_amt_2021_07_09
,coalesce(supplier_refund_tbl.refund_amt_2021_10_12, 0) refund_amt_2021_10_12
,coalesce(supplier_refund_tbl.refund_amt_2022_01_03, 0) refund_amt_2022_01_03
,coalesce(supplier_stock_tbl.stock_amt, 0) stock_amt
,coalesce(supplier_stock_tbl.stock_qty, 0) stock_qty
from (
     -- 进货金额表
    select siv.level1
#     ,siv.level2
#     ,siv.level3
    ,piv.supplier_id
    ,piv.supplier_code
    ,piv.supplier_name
    ,count(distinct if(siv.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s')
                       and siv.created_at < str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s'), siv.spu_code, null)) spu_2021_num
    ,count(distinct if(siv.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s')
                       and siv.created_at < str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s'), piv.product_id, null)) sku_2021_num
    ,count(distinct if(siv.created_at >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
                       and siv.created_at < str_to_date('2023-01-01', '%Y-%m-%d %H:%i:%s'), siv.spu_code, null)) spu_2022_num
    ,count(distinct if(siv.created_at >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
                       and siv.created_at < str_to_date('2023-01-01', '%Y-%m-%d %H:%i:%s'), piv.product_id, null)) sku_2022_num
    ,sum(if(dt >= '2021-01-01' and dt < '2022-01-01', amt, 0)) purchase_2021_amt
    ,sum(if(dt >= '2022-01-01' and dt < '2023-01-01', amt, 0)) purchase_2022_amt
    ,sum(if(dt >= '2021-01-01' and dt < '2021-04-01', amt, 0)) purchase_2021_01_03_amt
    ,sum(if(dt >= '2021-04-01' and dt < '2021-07-01', amt, 0)) purchase_2021_04_06_amt
    ,sum(if(dt >= '2021-07-01' and dt < '2021-10-01', amt, 0)) purchase_2021_07_09_amt
    ,sum(if(dt >= '2021-10-01' and dt < '2022-01-01', amt, 0)) purchase_2021_10_12_amt
    ,sum(if(dt >= '2022-01-01' and dt < '2022-04-01', amt, 0)) purchase_2022_01_03_amt
    from purchase_product_info_view piv
    left join sku_info_view siv on siv.product_id = piv.product_id
                                   and siv.supplier_code = piv.supplier_code

    where 1 = 1
    and dt >= '2021-01-01'
    group by siv.level1
#     ,siv.level2
#     ,siv.level3
    ,piv.supplier_id
    ,piv.supplier_code
    ,piv.supplier_name
) supplier_purchase_tbl
left join (
    select oiv.level1
#     ,oiv.level2
#     ,oiv.level3
    ,supplier_product_tbl.supplier_id
    ,supplier_product_tbl.supplier_code
    ,supplier_product_tbl.supplier_name
    ,sum(if(dt >= '2021-01-01' and dt < '2022-01-01', gmv, 0)) gmv_2021
    ,sum(if(dt >= '2022-01-01' and dt < '2023-01-01', gmv, 0)) gmv_2022
    ,sum(if(dt >= '2021-01-01' and dt < '2021-04-01', gmv, 0)) gmv_2021_01_03
    ,sum(if(dt >= '2021-04-01' and dt < '2021-07-01', gmv, 0)) gmv_2021_04_06
    ,sum(if(dt >= '2021-07-01' and dt < '2021-10-01', gmv, 0)) gmv_2021_07_09
    ,sum(if(dt >= '2021-10-01' and dt < '2022-01-01', gmv, 0)) gmv_2021_10_12
    ,sum(if(dt >= '2022-01-01' and dt < '2022-04-01', gmv, 0)) gmv_2022_01_03
    ,sum(if(dt >= '2022-03-01' and dt < '2022-04-01', gmv, 0)) gmv_2022_03
    from (
        select supplier_id
        ,supplier_code
        ,supplier_name
        ,product_id
        from purchase_product_final_view
    ) supplier_product_tbl
    left join order_info_td_view oiv on oiv.product_id = supplier_product_tbl.product_id
                                    and oiv.supplier_code = supplier_product_tbl.supplier_code
    where 1 = 1
    group by oiv.level1
#     ,oiv.level2
#     ,oiv.level3
    ,supplier_product_tbl.supplier_id
    ,supplier_product_tbl.supplier_code
    ,supplier_product_tbl.supplier_name
) supplier_order_tbl on supplier_order_tbl.supplier_id = supplier_purchase_tbl.supplier_id
                    and supplier_order_tbl.level1 = supplier_purchase_tbl.level1
                    and supplier_order_tbl.supplier_code = supplier_purchase_tbl.supplier_code
#                     and supplier_order_tbl.level2 = supplier_purchase_tbl.level2
#                     and supplier_order_tbl.level3 = supplier_purchase_tbl.level3
left join (
    -- 供应商退货金额
    select siv.level1
#     ,siv.level2
#     ,siv.level3
    ,supplier_product_tbl.supplier_id
    ,supplier_product_tbl.supplier_code
    ,supplier_product_tbl.supplier_name
    ,sum(if(itv.dt >= '2021-01-01' and itv.dt < '2022-01-01', refund_amt, 0)) refund_amt_2021
    ,sum(if(itv.dt >= '2022-01-01' and itv.dt < '2023-01-01', refund_amt, 0)) refund_amt_2022
    ,sum(if(itv.dt >= '2021-01-01' and itv.dt < '2021-04-01', refund_amt, 0)) refund_amt_2021_01_03
    ,sum(if(itv.dt >= '2021-04-01' and itv.dt < '2021-07-01', refund_amt, 0)) refund_amt_2021_04_06
    ,sum(if(itv.dt >= '2021-07-01' and itv.dt < '2021-10-01', refund_amt, 0)) refund_amt_2021_07_09
    ,sum(if(itv.dt >= '2021-10-01' and itv.dt < '2022-01-01', refund_amt, 0)) refund_amt_2021_10_12
    ,sum(if(itv.dt >= '2022-01-01' and itv.dt < '2022-04-01', refund_amt, 0)) refund_amt_2022_01_03
    from (
        select supplier_id
        ,supplier_code
        ,supplier_name
        ,product_id
        from purchase_product_final_view
    ) supplier_product_tbl
    left join refund_order_info_td_view itv on itv.product_id = supplier_product_tbl.product_id
    left join sku_info_view siv on siv.product_id = supplier_product_tbl.product_id
    where 1 = 1
    group by siv.level1
#     ,siv.level2
#     ,siv.level3
    ,supplier_product_tbl.supplier_id
    ,supplier_product_tbl.supplier_code
    ,supplier_product_tbl.supplier_name
) supplier_refund_tbl on supplier_refund_tbl.supplier_id = supplier_purchase_tbl.supplier_id
                         and supplier_refund_tbl.supplier_code = supplier_purchase_tbl.supplier_code
                         and supplier_refund_tbl.level1 = supplier_purchase_tbl.level1
#                          and supplier_refund_tbl.level2 = supplier_purchase_tbl.level2
#                          and supplier_refund_tbl.level3 = supplier_purchase_tbl.level3
left join (
    -- 库存金额
    select skiv.level1
#     ,skiv.level2
#     ,skiv.level3
    ,supplier_product_tbl.supplier_id
    ,supplier_product_tbl.supplier_code
    ,supplier_product_tbl.supplier_name
    ,sum(stock_amt) stock_amt
    ,sum(stock_qty) stock_qty
    from (
        select supplier_id
        ,supplier_code
        ,supplier_name
        ,product_id
        from purchase_product_final_view
    ) supplier_product_tbl
    left join stock_info_view siv on siv.product_id = supplier_product_tbl.product_id
    left join sku_info_view skiv on skiv.product_id = supplier_product_tbl.product_id
    where 1 = 1
    group by skiv.level1
#     ,skiv.level2
#     ,skiv.level3
    ,supplier_product_tbl.supplier_id
    ,supplier_product_tbl.supplier_code
    ,supplier_product_tbl.supplier_name
) supplier_stock_tbl on supplier_stock_tbl.supplier_id = supplier_purchase_tbl.supplier_id
                     and supplier_stock_tbl.level1 = supplier_purchase_tbl.level1
                     and supplier_stock_tbl.supplier_code = supplier_purchase_tbl.supplier_code
#                      and supplier_refund_tbl.level2 = supplier_purchase_tbl.level2
#                      and supplier_refund_tbl.level3 = supplier_purchase_tbl.level3
where 1 = 1
;