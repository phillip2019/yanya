-- 商品域_细分品类款式到店销售情况
select level1
,level2
,level3
,spu_code
,spu_name
,sku_num
,rank
,sale_price
,gmv
,sale_qty
,stock_amt
,stock_qty
,gmv / stock_amt stock_sale_rate
,arrival_shop_days
from (
     select t1.level1
    ,t1.level2
    ,t1.level3
    ,t1.spu_code
    ,t1.spu_name
    ,t1.gmv
    ,t1.gmv_3d
    ,t1.sale_qty
    ,t1.stock_amt
    ,t1.stock_qty
    ,t1.sku_num
    ,arrival_shop_days
    ,if(t1.sale_qty = 0, 0, t1.gmv / t1.sale_qty) sale_price
    ,if(@g=concat(t1.level1, '>', t1.level2, '>', t1.level3), @rank:=@rank + 1, @rank:=1) as rank
    ,@g:=concat(t1.level1, '>', t1.level2, '>', t1.level3) as 'group'
    from (
          select siv.level1
          ,siv.level2
          ,siv.level3
          ,siv.spu_code
          ,max(siv.spu_name) spu_name
          ,sum(coalesce(o3iv.gmv, 0)) gmv
          ,sum(coalesce(o3iv.gmv_3d, 0)) gmv_3d
          ,sum(coalesce(o3iv.sale_qty, 0)) sale_qty
          ,sum(coalesce(skiv.stock_amt, 0)) stock_amt
          ,sum(coalesce(skiv.stock_qty, 0)) stock_qty
          ,max(TIMESTAMPDIFF(DAY ,coalesce(skiv.shop_first_created_at, now()), now())) arrival_shop_days
          ,count(distinct siv.product_code) sku_num
          from sku_info_view siv
          left join stock_info_view skiv on siv.product_id = skiv.product_id
          left join order_202203_info_view o3iv on o3iv.product_id = siv.product_id
          where 1 = 1
          and (
            coalesce (o3iv.gmv, 0) > 0
            or coalesce(skiv.stock_amt, 0) > 0
          )
          group by siv.level1
          ,siv.level2
          ,siv.level3
          ,siv.spu_code
          order by siv.level1
          ,siv.level2
          ,siv.level3
          ,gmv desc
    ) t1
    ,(
        select @rank:=0
        ,@g:=NULL
        ) t2
    where 1 = 1
) spu_3d_sale_tbl
where 1 = 1
and level1 not in ('淘汰')
and level2 not in ('淘汰')
and level3 not in ('淘汰')
