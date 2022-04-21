-- 2.细分品类款式情况到店销售情况（款式数量、库存金额、配货门店数量，销售比例sku售罄率，价格段）
-- 一级品类、二级品类、三级品类、SPU数量、SKU数量、最多销售价格、销售占比、21年销售金额、22年销售金额、22年本月增长率[22年本月销售金额 - 21年本月销售金额） / 21年本月销售金额]
drop view if exists erp.level3_summery_view;
create view erp.level3_summery_view as
select spu_tbl.level1
     ,spu_tbl.level2
     ,spu_tbl.level3
,coalesce(spu_num, 0) spu_num
,coalesce(sku_num, 0) sku_num
,coalesce(level3_multi_price_tbl.sale_price, 0) sale_price
,coalesce(order_2021_tbl.gmv, 0) gmv_2021
,coalesce(order_2021_tbl.sale_qty, 0) sale_qty_2021
,coalesce(order_2022_tbl.gmv, 0) gmv_2022
,coalesce(order_2022_tbl.sale_qty, 0) sale_qty_2022
,coalesce(order_202202_tbl.gmv, 0) gmv_2022_2
,coalesce(order_202202_tbl.sale_qty, 0) sale_qty_2022_2
,coalesce(order_202102_tbl.gmv, 0) gmv_2021_2
,coalesce(order_202102_tbl.sale_qty, 0) sale_qty_2021_2
,coalesce(order_202203_tbl.gmv, 0) gmv_2022_3
,coalesce(order_202203_tbl.sale_qty, 0) sale_qty_2022_3
,coalesce(order_202103_tbl.gmv, 0) gmv_2021_3
,coalesce(order_202103_tbl.sale_qty, 0) sale_qty_2021_3
from (
  select level1
  ,level2
  ,level3
  -- 有销量或有库存的才算SPU数量
  ,count(distinct if(level3 not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
                         and level1 not in ('批发辅材', '优惠券', '特价区', '淘汰')
                         and (
                             oiv.gmv > 0
                             or skiv.stock_qty > 0
                         ), spu_code, null)) spu_num
  -- 有销量或有库存的才算SKU数量
  ,sum(if(level3 not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
                         and level1 not in ('批发辅材', '优惠券', '特价区', '淘汰')
                         and (
                             oiv.gmv > 0
                             or skiv.stock_qty > 0
                         ), 1, 0)) sku_num
  from sku_info_view suiv
  left join stock_info_view skiv on skiv.product_id = suiv.product_id
  left join order_3d_info_view oiv on oiv.product_id = suiv.product_id
  where 1 = 1
  and level1 not in ('优惠券类')
  -- 排除停止采购的，只包含最后采购日期为最近2年的
  and suiv.stop_buy = false
  and suiv.purchase_latest_at >= date_sub(now(), INTERVAL 2 YEAR)
  group by level1
    ,level2
    ,level3
) spu_tbl
left join (
    select t1.level1
    ,t1.level2
    ,t1.level3
    ,t2.sale_price
    from (
        select level1
        ,level2
        ,level3
        ,max(num) max_price_num
        from (
            select level1
            ,level2
            ,level3
            ,sale_price
            ,count(1) num
            from sku_info_view
            where 1 = 1
            group by level1
            ,level2
            ,level3
        ) sku_sale_price_max_num_tbl
        group by level1
        ,level2
        ,level3
    ) t1 inner join (
        select level1
        ,level2
        ,level3
        ,sale_price
        ,count(1) num
        from sku_info_view
        where 1 = 1
        group by level1
        ,level2
        ,level3
    ) t2 on t1.level1 = t2.level1
        and t1.level2 = t2.level2
        and t1.level3 = t2.level3
        and t1.max_price_num = t2.num
    where 1 = 1
) level3_multi_price_tbl on level3_multi_price_tbl.level1 = spu_tbl.level1
                        and level3_multi_price_tbl.level2 = spu_tbl.level2
                        and level3_multi_price_tbl.level3 = spu_tbl.level3
-- 2021年销售情况
left join (
    select level1
         ,level2
         ,level3
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_2021_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
         ,level2
         ,level3
) order_2021_tbl on order_2021_tbl.level1 = spu_tbl.level1
                and order_2021_tbl.level2 = spu_tbl.level2
                and order_2021_tbl.level3 = spu_tbl.level3
-- 2022年销售情况
left join (
    select level1
         ,level2
         ,level3
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_2022_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
          ,level2
          ,level3
) order_2022_tbl on order_2022_tbl.level1 = spu_tbl.level1
                and order_2022_tbl.level2 = spu_tbl.level2
                and order_2022_tbl.level3 = spu_tbl.level3
-- 2022年02月销售情况
left join (
    select level1
         ,level2
         ,level3
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202202_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
          ,level2
          ,level3
) order_202202_tbl on order_202202_tbl.level1 = spu_tbl.level1
                  and order_202202_tbl.level2 = spu_tbl.level2
                  and order_202202_tbl.level3 = spu_tbl.level3
-- 2021年02月销售情况
left join (
    select level1
         ,level2
         ,level3
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202102_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
          ,level2
          ,level3
) order_202102_tbl on order_202102_tbl.level1 = spu_tbl.level1
                  and order_202102_tbl.level2 = spu_tbl.level2
                  and order_202102_tbl.level3 = spu_tbl.level3
-- 2022年03月销售情况
left join (
    select level1
         ,level2
         ,level3
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202203_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
          ,level2
          ,level3
) order_202203_tbl on order_202203_tbl.level1 = spu_tbl.level1
                  and order_202203_tbl.level2 = spu_tbl.level2
                  and order_202203_tbl.level3 = spu_tbl.level3
-- 2021年03月销售情况
left join (
    select level1
           ,level2
           ,level3
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202103_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
            ,level2
            ,level3
) order_202103_tbl on order_202103_tbl.level1 = spu_tbl.level1
                  and order_202103_tbl.level2 = spu_tbl.level2
                  and order_202103_tbl.level3 = spu_tbl.level3
;
