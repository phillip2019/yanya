-- 1.全品类现有款式情况（款式数控、库存金额、销售）
-- 一级品类、SPU数量、库存金额、库存数量、销售金额、销售数量、销售占比
drop view if exists erp.level1_summery_view;
create view erp.level1_summery_view as
select spu_tbl.level1
,coalesce(spu_num, 0) spu_num
,coalesce(sku_num, 0) sku_num
,coalesce(stock_amt, 0) stock_amt
,coalesce(stock_qty, 0) stock_qty
,coalesce(order_2021_tbl.gmv, 0) gmv_2021
,coalesce(order_2021_tbl.sale_qty, 0) sale_qty_2021
,coalesce(order_2022_tbl.gmv, 0) gmv_2022
,coalesce(order_2022_tbl.sale_qty, 0) sale_qty_2022
,coalesce(order_202201_tbl.gmv, 0) gmv_2022_1
,coalesce(order_202201_tbl.sale_qty, 0) sale_qty_2022_1
,coalesce(order_202202_tbl.gmv, 0) gmv_2022_2
,coalesce(order_202202_tbl.sale_qty, 0) sale_qty_2022_2
,coalesce(order_202102_tbl.gmv, 0) gmv_2021_2
,coalesce(order_202102_tbl.sale_qty, 0) sale_qty_2021_2
,coalesce(order_202203_tbl.gmv, 0) gmv_2022_3
,coalesce(order_202203_tbl.sale_qty, 0) sale_qty_2022_3
,coalesce(order_202103_tbl.gmv, 0) gmv_2021_3
,coalesce(order_202103_tbl.sale_qty, 0) sale_qty_2021_3
,coalesce(order_202204_tbl.gmv, 0) gmv_2022_4
,coalesce(order_202204_tbl.sale_qty, 0) sale_qty_2022_4
,coalesce(order_202104_tbl.gmv, 0) gmv_2021_4
,coalesce(order_202104_tbl.sale_qty, 0) sale_qty_2021_4
from (
  select level1
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
  group by level1
) spu_tbl
-- 1级分类库存
left join (
  select level1
  ,sum(stock_qty) stock_qty
  ,sum(stock_amt) stock_amt
  from sku_info_view suiv
  inner join stock_info_view skiv on skiv.product_id = suiv.product_id
  group by suiv.level1
) stock_tbl on stock_tbl.level1 = spu_tbl.level1
-- 2021年销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_2021_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_2021_tbl on order_2021_tbl.level1 = spu_tbl.level1
-- 2022年销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_2022_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_2022_tbl on order_2022_tbl.level1 = spu_tbl.level1
-- 2022年01月销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202201_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_202201_tbl on order_202201_tbl.level1 = spu_tbl.level1
-- 2022年02月销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202202_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_202202_tbl on order_202202_tbl.level1 = spu_tbl.level1
-- 2021年02月销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202102_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_202102_tbl on order_202102_tbl.level1 = spu_tbl.level1
-- 2022年03月销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202203_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_202203_tbl on order_202203_tbl.level1 = spu_tbl.level1
-- 2021年03月销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202103_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_202103_tbl on order_202103_tbl.level1 = spu_tbl.level1
-- 2022年04月销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202204_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_202204_tbl on order_202204_tbl.level1 = spu_tbl.level1
-- 2021年04月销售情况
left join (
    select level1
    ,sum(sale_qty) sale_qty
    ,sum(gmv) gmv
    from sku_info_view suiv
    inner join order_202104_info_view oiv on oiv.product_id = suiv.product_id
    group by level1
) order_202104_tbl on order_202104_tbl.level1 = spu_tbl.level1
;