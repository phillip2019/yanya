-- 款式在店铺中库存数量、库存金额、销售比例sku售罄率、价格段
drop view if exists shop_product_sku_detail_view;
create view shop_product_sku_detail_view as
select sku_tbl.level1
,sku_tbl.level2
,sku_tbl.level3
,sku_tbl.stop_buy
,sku_tbl.purchase_latest_at
,sku_tbl.product_id
,sku_tbl.product_code
,sku_tbl.product_name
,sku_tbl.cost_price
,sku_tbl.sale_price
,sku_tbl.created_at
,coalesce(order_tbl.shop_id, 'unknown')                        shop_id
,coalesce(order_tbl.shop_name, stock_tbl.shop_name, 'unknown') shop_name
,coalesce(order_tbl.sale_qty, 0)                               sale_qty
,coalesce(order_tbl.gmv, 0)                                    gmv
,coalesce(stock_tbl.stock_qty, 0)                              stock_qty
,coalesce(stock_tbl.amt, 0)                                    stock_amt
,if((coalesce(stock_tbl.stock_qty, 0) +  coalesce(order_tbl.sale_qty, 0)) = 0, 100, coalesce(order_tbl.sale_qty, 0) / (coalesce(stock_tbl.stock_qty, 0) +  coalesce(order_tbl.sale_qty, 0)))  sell_through_rate
from sku_info_view sku_tbl
-- 2022年01月01日产品店铺销售情况
left join (
    select pbi.shop_id
    ,pbi.shop_name
    ,ppb.product_id
    ,sum(ppb.qty) sale_qty
    ,sum(pbi.amt) gmv
    ,date_format(pbi.date_created, '%Y-%m-%d') dt
    from erp.pos_bill_index pbi
    left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
    where pbi.date_created >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
    group by pbi.shop_id
    ,pbi.shop_name
    ,ppb.product_id
    ,date_format(pbi.date_created, '%Y-%m-%d')
) order_tbl on order_tbl.product_id = sku_tbl.product_id
-- 库存表
left join (
    select product_id
    ,product_name
    ,qty + lock_qty + coalesce(move_qty, 0) stock_qty
    ,amt
    ,warehouse_name shop_name
    from erp.stock
    where 1 = 1
    and site_id = 1251
    and (
        qty > 0
    )
    and warehouse_code not in (
                        '6006',
                        '6021',
                        '6068',
                        '6067',
                        '6073',
                        '6063',
                        '6024',
                        '6050',
                        '6008'
    )
    group by product_id
    ,product_name
    ,warehouse_name
) stock_tbl on stock_tbl.product_id = sku_tbl.product_id
             and (stock_tbl.shop_name = order_tbl.shop_name
                 or order_tbl.shop_name is null
             )
where 1 = 1
-- 最后采购时间为两年前的过滤
and sku_tbl.purchase_latest_at >= date_sub(now(), INTERVAL 2 YEAR)
;





