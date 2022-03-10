# 61948
# 61306

-- 一级淘汰下商品
select p.code
,p.name
,fp.name level1
from (
    select code
           ,name
           ,paths
           ,substring(paths, 1, 4) f_paths
    from erp.product p
    where length(paths) = 8
    and has_child = 0
) p
left join (
    select code
           ,name
           ,paths
    from erp.product p
    where length(paths) = 4
    and has_child = 1
) fp on fp.paths = p.f_paths
where fp.name != '淘汰'
;

-- 119款商品

-- 2级商品详情
-- 全部 36206
-- 废弃 36206
select
       p.code
,p.name
,f1p.name level1
,f2p.name level2
# count(1) num
from (
    select code
           ,name
           ,paths
           ,substring(paths, 1, 8) level2_paths
           ,substring(paths, 1, 4) level1_paths
    from erp.product p
    where length(paths) = 12
    and has_child = 0
) p
left join (
    select code
           ,name
           ,paths
    from erp.product p
    where length(paths) = 4
    and has_child = 1
) f1p on f1p.paths = p.level1_paths
left join (
    select code
           ,name
           ,paths
    from erp.product p
    where length(paths) = 8
    and has_child = 1
) f2p on f2p.paths = p.level2_paths
where f2p.name != '淘汰类'
and f2p.name != '淘汰'
and f2p.name != '淘汰款'
;

-- 分类数量
select length(paths) len
,count(1) num
from erp.product p
group by length(paths)
order by len desc
;

-- 4级商品
select
       p.code
,p.name
,f1p.name level1
,f2p.name level2
,f3p.name level3
,f4p.code spu_code
,f4p.name level4
# count(1) num
from (
    select code
           ,name
           ,paths
           ,substring(paths, 1, 16) level4_paths
           ,substring(paths, 1, 12) level3_paths
           ,substring(paths, 1, 8) level2_paths
           ,substring(paths, 1, 4) level1_paths
    from erp.product p
    where length(paths) = 20
    and has_child = 0
) p
left join (
    select code
           ,name
           ,paths
    from erp.product p
    where length(paths) = 4
    and has_child = 1
) f1p on f1p.paths = p.level1_paths
left join (
    select code
           ,name
           ,paths
    from erp.product p
    where length(paths) = 8
    and has_child = 1
) f2p on f2p.paths = p.level2_paths
left join (
    select code
           ,name
           ,paths
    from erp.product p
    where length(paths) = 12
    and has_child = 1
) f3p on f3p.paths = p.level3_paths
left join (
    select code
           ,name
           ,paths
    from erp.product p
    where length(paths) = 16
    and has_child = 1
) f4p on f4p.paths = p.level4_paths
where f2p.name != '淘汰类'
and f2p.name != '淘汰'
and f2p.name != '淘汰款';
-- 20 5级
-- 16 4级
-- 12 3级
-- 8 2级
-- 4 1级
show create table erp.product;
show variables like '%colla%';
show variables like '%char%';

-- 累计sku数量
select count(1)
,dt
from (
     select pt1.p_name level1
    ,pt1.p_code level1_id
    ,coalesce(pt2.p_name, pt1.p_name) level2
    ,coalesce(pt2.p_code, pt1.p_code) level2_id
    ,coalesce(pt3.p_name, pt2.p_name, pt1.p_name) level3
    ,coalesce(pt3.p_code, pt2.p_code, pt1.p_code) level3_id
    ,coalesce(pt4.p_name, pt3.p_name, pt2.p_name, pt1.p_name) level4
    ,coalesce(pt4.p_code, pt3.p_code, pt2.p_code, pt1.p_code) level4_id
    ,t.id product_id
    ,t.code product_code
    ,t.name product_name
    ,pp.cost_price
    ,pp.sale_price
    ,t.created_at
    ,date_format(t.created_at, '%Y-%m-%d') dt
    ,t.site_id
    from (
            select id
            ,code
            ,name
            ,create_date created_at
            ,substring(paths, 1, 4) p1_paths
            ,substring(paths, 1, 8) p2_paths
            ,substring(paths, 1, 12) p3_paths
            ,substring(paths, 1, 16) p4_paths
            ,site_id
            from erp.product
            where has_child = false
            and site_id = 1251
        ) t left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt4 on pt4.p_paths = t.p4_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt3 on pt3.p_paths = t.p3_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt2 on pt2.p_paths = t.p2_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt1 on pt1.p_paths = t.p1_paths
       left join (
           select product_id
           ,site_id
           ,buy_price cost_price
           ,price0 sale_price
           from erp.product_price
           where site_id = 1251
        ) pp on pp.product_id = t.id
            and pp.site_id = t.site_id
    where 1 = 1
) sku_tbl
where 1 = 1
and level1 not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
and level2 not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
and level3 not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
and level4 not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
and level1 not in ('批发辅材', '优惠券', '特价区', '淘汰')
group by dt
;

-- 2022年3月1日累计至今sku数量
select count(1) sku_num
,dt
from (
     select coalesce(pt.p_code, t.code) spu_code
    ,coalesce(pt.p_code, t.code) p_code
    ,pt.p_name
    ,t.code
    ,t.name
    ,t.created_at
    ,date_format(t.created_at, '%Y-%m-%d') dt
    from (
            select code
            ,name
            ,create_date created_at
            ,substring(paths, 1, length(paths) - 4) p_paths
            from erp.product
            where has_child = false
        ) t left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt on pt.p_paths = t.p_paths
    where 1 = 1
    and (
        pt.p_name not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
        or pt.p_name is null
    )
    and created_at >= str_to_date('2022-03-01', '%Y-%m-%d %H:%i:%s')
) sku_tbl
group by dt
;


-- 2022年3月1号累计至今SPU
select coalesce(pt.p_code, t.code) spu_code
    ,coalesce(pt.p_code, t.code) p_code
    ,pt.p_name
    ,t.code
    ,t.name
    ,t.created_at
    ,date_format(t.created_at, '%Y-%m-%d') dt
from (
        select code
        ,name
        ,create_date created_at
        ,substring(paths, 1, length(paths) - 4) p_paths
        from erp.product
        where has_child = false
    ) t left join (
        select code p_code
        ,name p_name
        ,paths p_paths
        from erp.product
        where has_child = true
    ) pt on pt.p_paths = t.p_paths
where 1 = 1
and (
    pt.p_name not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
    or pt.p_name is null
)
and created_at >= str_to_date('2022-03-01', '%Y-%m-%d %H:%i:%s')
;

-- 累计至今spu数量
select count(distinct spu_code) spu_num
,dt
from (
    select coalesce(pt.p_code, t.code) spu_code
        ,coalesce(pt.p_code, t.code) p_code
        ,pt.p_name
        ,t.code
        ,t.name
        ,t.created_at
        ,date_format(t.created_at, '%Y-%m-%d') dt
    from (
            select code
            ,name
            ,create_date created_at
            ,substring(paths, 1, length(paths) - 4) p_paths
            from erp.product
            where has_child = false
        ) t left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt on pt.p_paths = t.p_paths
    where 1 = 1
    and (
        pt.p_name not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
        or pt.p_name is null
    )
    and created_at >= str_to_date('2022-03-01', '%Y-%m-%d %H:%i:%s')
    union all
    select case
            when char_length(substring_index(t.name, '/', 1)) < 4 then substring_index(substring_index(t.name, '/', 2), '/', -1)
            when substring(t.name, 1, 6) in (
                '73144/'
                ) then substring_index(t.name, '/', 2)
#             when length(t.code) = 14 and substring(t.name, -1, 2) in ('/宽', '/细') then substring_index(t.name, '/', -1)
            when t.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s') and char_length(substring_index(t.name, '/', -1)) < 5 then substring_index(substring_index(t.name, '/', -2), '/', 1)
            when t.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s') then substring_index(t.name, '/', -1)
            else substring_index(t.name, '/', 1)
        end spu_code
        ,pt.p_code
        ,pt.p_name
        ,t.code
        ,t.full_name name
        ,t.created_at
        ,date_format(t.created_at, '%Y-%m-%d') dt
    from (
            select code
            ,replace(replace(replace(name, '3对装/', ''), '2对装/', ''), '1对装/', '') name
            ,name full_name
            ,create_date created_at
            ,substring(paths, 1, length(paths) - 4) p_paths
            from erp.product
            where has_child = false
        ) t left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt on pt.p_paths = t.p_paths
    where 1 = 1
    and (
        pt.p_name not in ('淘汰', '淘汰类', '淘汰分类', '废弃', '废弃类', '淘汰款')
        or pt.p_name is null
    )
    and created_at < str_to_date('2022-03-01', '%Y-%m-%d %H:%i:%s')

) spu_tbl
group by dt
;


select *
from erp.stock
where 1 = 1
and site_id = 1251
and qty != 0
and warehouse_code in (
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
group by site_name
;

-- 库存数量、金额
-- 总部仓库存(含锁定库存数量) + 调拨在途库存（供应商到总部仓库 + 总部仓库到门店）+ 门店库存(含锁定库存数量, 排除加盟商库存)
-- 义乌散货是外商拿货，可不计算库存，部分库存店铺已经关店，不计入库存内
select cast(sum(stock_qty) as decimal(20, 0)) stock_qty
,sum(amt) stock_amt
,now() stat_at
,warehouse_name
from (
     select product_id
    ,product_code
    ,product_name
    ,qty + lock_qty + coalesce(move_qty, 0) stock_qty
    ,amt
    ,date_created created_at
    ,warehouse_name
    ,warehouse_code
    from erp.stock
    where 1 = 1
    and site_id = 1251
    and (
        qty > 0
    )
    and warehouse_name not like '%加盟%'
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
) stock_tbl
group by warehouse_name
;

-- 累计销售金额
 select
#     warehouse_name
#     ,site_id
#     ,site_name
     shop_id
    ,shop_name
#     ,code order_no
#     ,off_amt
     ,sum(amt) gmv
#     ,card_id
#     ,card_code
#     ,point
#     ,coalesce(handle_staff_id, staff_id) staff_id
#     ,date_created created_at
    ,date_format(date_created, '%Y-12-31') dt
    from erp.pos_bill_index
    where 1 = 1
    -- 2022年以前计算按照年计算
    and date_created < str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
    group by shop_id
    ,shop_name
    ,date_format(date_created, '%Y-12-31')
    union all
    select shop_id
    ,shop_name
    ,sum(amt) gmv
    ,date_format(date_created, '%Y-%m-%d') dt
    from erp.pos_bill_index
    where 1 = 1
    -- 2022年以后的计算按照天计算
    and date_created >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
    group by shop_id
    ,shop_name
    ,date_format(date_created, '%Y-%m-%d')
;

-- 2021年全年销售金额
 select shop_id
,shop_name
,sum(amt) gmv
,date_format(date_created, '%Y-%m-%d') dt
from erp.pos_bill_index
where 1 = 1
-- 2022年以后的计算按照天计算
and date_created >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s')
and date_created <= str_to_date('2021-12-31', '%Y-%m-%d %H:%i:%s')
group by shop_id
,shop_name
,date_format(date_created, '%Y-%m-%d')
;


-- 2022年1月1号累计至今销售金额
 select shop_id
,shop_name
,sum(amt) gmv
,date_format(date_created, '%Y-%m-%d') dt
from erp.pos_bill_index
where 1 = 1
-- 2022年以后的计算按照天计算
and date_created >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
group by shop_id
,shop_name
,date_format(date_created, '%Y-%m-%d')
;

-- 累计至今销售数量
select
pbi.shop_id
,pbi.shop_name
,sum(ppb.qty) product_qty
,date_format(pbi.date_created, '%Y-12-31') dt
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
where 1 = 1
-- 2022年以前计算按照年计算
and pbi.date_created < str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
group by pbi.shop_id
,pbi.shop_name
,date_format(pbi.date_created, '%Y-12-31')
union all
select
pbi.shop_id
,pbi.shop_name
,sum(ppb.qty) product_qty
,date_format(pbi.date_created, '%Y-%m-%d') dt
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
where 1 = 1
-- 2022年以前计算按照年计算
and pbi.date_created >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
group by pbi.shop_id
,pbi.shop_name
,date_format(pbi.date_created, '%Y-%m-%d')
;


-- 2021全年销售数量
 select pbi.shop_id
,pbi.shop_name
,sum(ppb.qty) product_qty
,date_format(pbi.date_created, '%Y-%m-%d') dt
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
where 1 = 1
and pbi.date_created >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s')
and pbi.date_created <= str_to_date('2021-12-31', '%Y-%m-%d %H:%i:%s')
group by pbi.shop_id
,pbi.shop_name
,date_format(pbi.date_created, '%Y-%m-%d')
;

-- 2022全年销售数量
 select pbi.shop_id
,pbi.shop_name
,sum(ppb.qty) product_qty
,date_format(pbi.date_created, '%Y-%m-%d') dt
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
where 1 = 1
and pbi.date_created >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
group by pbi.shop_id
,pbi.shop_name
,date_format(pbi.date_created, '%Y-%m-%d')
;

-- 2022年日商品款式spu到店销量、销售额
 select pbi.shop_id
,pbi.shop_name
,p.level1
,p.level2
,p.level3
,p.level4
,p.name
,p.code
,sum(ppb.qty) product_qty
,sum(pbi.amt) gmv
,date_format(pbi.date_created, '%Y-%m-%d') dt
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
left join (
    select pt1.p_name level1
    ,pt1.p_code level1_id
    ,coalesce(pt2.p_name, pt1.p_name) level2
    ,coalesce(pt2.p_code, pt1.p_code) level2_id
    ,coalesce(pt3.p_name, pt2.p_name, pt1.p_name) level3
    ,coalesce(pt3.p_code, pt2.p_code, pt1.p_code) level3_id
    ,coalesce(pt4.p_name, pt3.p_name, pt2.p_name, pt1.p_name) level4
    ,coalesce(pt4.p_code, pt3.p_code, pt2.p_code, pt1.p_code) level4_id
    ,t.id
    ,t.code
    ,t.name
    ,t.created_at
    ,date_format(t.created_at, '%Y-%m-%d') dt
    from (
            select id
            ,code
            ,name
            ,create_date created_at
            ,substring(paths, 1, 4) p1_paths
            ,substring(paths, 1, 8) p2_paths
            ,substring(paths, 1, 12) p3_paths
            ,substring(paths, 1, 16) p4_paths
            from erp.product
            where has_child = false
        ) t left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt4 on pt4.p_paths = t.p4_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt3 on pt3.p_paths = t.p3_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt2 on pt2.p_paths = t.p2_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt1 on pt1.p_paths = t.p1_paths
    where 1 = 1
) p on p.id = ppb.product_id
where 1 = 1
and pbi.date_created >= str_to_date('2022-01-01', '%Y-%m-%d %H:%i:%s')
group by pbi.shop_id
,pbi.shop_name
,p.level1
,p.level2
,p.level3
,p.level4
,p.code
,p.name
,date_format(pbi.date_created, '%Y-%m-%d')
;


-- 款式在店铺中库存数量、库存金额、销售比例sku售罄率、价格段
select sku_tbl.level1
,sku_tbl.level2
,sku_tbl.level3
,sku_tbl.level4
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
from (
     select pt1.p_name level1
    ,pt1.p_code level1_id
    ,coalesce(pt2.p_name, pt1.p_name) level2
    ,coalesce(pt2.p_code, pt1.p_code) level2_id
    ,coalesce(pt3.p_name, pt2.p_name, pt1.p_name) level3
    ,coalesce(pt3.p_code, pt2.p_code, pt1.p_code) level3_id
    ,coalesce(pt4.p_name, pt3.p_name, pt2.p_name, pt1.p_name) level4
    ,coalesce(pt4.p_code, pt3.p_code, pt2.p_code, pt1.p_code) level4_id
    ,t.id product_id
    ,t.code product_code
    ,t.name product_name
    ,pp.cost_price
    ,pp.sale_price
    ,t.created_at
    ,date_format(t.created_at, '%Y-%m-%d') dt
    ,t.site_id
    from (
            select id
            ,code
            ,name
            ,create_date created_at
            ,substring(paths, 1, 4) p1_paths
            ,substring(paths, 1, 8) p2_paths
            ,substring(paths, 1, 12) p3_paths
            ,substring(paths, 1, 16) p4_paths
            ,site_id
            from erp.product
            where has_child = false
            and site_id = 1251
        ) t left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt4 on pt4.p_paths = t.p4_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt3 on pt3.p_paths = t.p3_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt2 on pt2.p_paths = t.p2_paths
       left join (
            select code p_code
            ,name p_name
            ,paths p_paths
            from erp.product
            where has_child = true
        ) pt1 on pt1.p_paths = t.p1_paths
       left join (
           select product_id
           ,site_id
           ,buy_price cost_price
           ,price0 sale_price
           from erp.product_price
           where site_id = 1251
        ) pp on pp.product_id = t.id
            and pp.site_id = t.site_id
    where 1 = 1
) sku_tbl
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
;

-- 供应商表 1658
select *
from (
     select source_supplier_tbl.supplier_id
    ,source_supplier_tbl.supplier_code
    ,source_supplier_tbl.supplier_name
    ,source_supplier_tbl.supplier_type
    ,source_supplier_tbl.contact_name
    ,source_supplier_tbl.contact_mobile
    ,source_supplier_tbl.contact_phone
    ,source_supplier_tbl.contact_address
    ,source_supplier_tbl.price_tracking
    ,source_supplier_tbl.business_agent
    ,region_tbl.region_code
    ,coalesce(region_tbl.region, 'unknown') region
    ,source_supplier_tbl.provice
    ,source_supplier_tbl.city
    ,source_supplier_tbl.area
    from (
         select id supplier_id
        ,code supplier_code
        ,name supplier_name
        ,type supplier_type
        ,if(char_length(contact_person) in (11, 12), '', contact_person) contact_name
        ,case
            when char_length(contact_person) = 11 then contact_person
            when char_length(contact_person) = 12 then contact_person
            when contact_mobile = '' then replace(contact_phone, '-', '')
            when instr(contact_mobile, '/') > 0 then substring_index(replace(contact_mobile, '-', ''), '/', -1)
            else substring_index(replace(contact_mobile, '-', ''), '\\', -1)
         end contact_mobile
        ,case
            when instr(contact_phone, '/') > -1 then substring_index(replace(contact_phone, '-', ''), '/', 1)
            when contact_phone = '' then substring_index(replace(contact_mobile, '-', ''), '\\', 1)
            else substring_index(replace(contact_phone, '-', ''), '\\', 1)
         end contact_phone
        ,contact_address
        ,price_track_auto price_tracking
        ,substring(paths, 1, length(paths) - 4) p_paths
        ,site_name
        ,rep_staff business_agent
        ,area1 provice
        ,area2 city
        ,area3 area
        ,date_created created_at
        from erp.cust_supplier
        where has_child = false
        and (
            type in ('S') or
            (
              (sub_site_id <= 0
              or sub_site_id is null
            )
            and type = 'A'
            )
        )
        and crm_ok = true
        and enabled = true
        and id not in (
             '2267',
             '2285',
             '2286',
             '2288',
             '2289',
             '72290',
             '72291',
             '72292',
             '72293',
             '72294',
             '72295',
             '72448',
             '72450',
             '747598',
             '959888',
             '1021487',
             '1076994',
             '72267',
             '72285',
             '72286',
             '72288',
             '72289'
        )
    ) source_supplier_tbl left join (
        select code region_code
        ,name region
        ,paths p_paths
        from erp.cust_supplier
        where has_child = true
        and type in ('A', 'S')
        and enabled = true
    ) region_tbl on region_tbl.p_paths = source_supplier_tbl.p_paths
) supplier_tbl
;

select level1
,spu_num
,stock_amt
,stock_qty
,gmv_2021
,sale_qty_2021
,gmv_2022
,sale_qty_2022
,gmv_2022_1
,sale_qty_2022_1
,gmv_2022_2
,sale_qty_2022_2
,gmv_2022_3
,sale_qty_2022_3
,gmv_2021 / total_gmv_2021 * 100 gmv_2021_rate
,gmv_2022 / total_gmv_2022 * 100 gmv_2022_rate
from level1_summery_view
,(
  select sum(gmv_2021) total_gmv_2021
    ,sum(gmv_2022) total_gmv_2022
  from level1_summery_view plv
) st
where 1 = 1
;


-- 细分品类款式到店销售情况
select *
from (
     select t1.level1
    ,t1.level2
    ,t1.level3
    ,t1.spu_code
    ,t1.spu_name
    ,t1.gmv
    ,t1.sale_qty
    ,t1.stock_amt
    ,if(t1.sale_qty = 0, 0, t1.gmv / t1.sale_qty) sale_price
    ,if(@g=concat(t1.level1, '>', t1.level2, '>', t1.level3), @rank:=@rank + 1, @rank:=1) as rank
    ,@g:=concat(t1.level1, '>', t1.level2, '>', t1.level3) as 'group'
    from (
          select siv.level1
          ,siv.level2
          ,siv.level3
          ,siv.spu_code
          ,max(siv.spu_name) siv.spu_name
          ,sum(o3iv.gmv) gmv
          ,sum(o3iv.sale_qty) sale_qty
          ,sum(coalesce(siv.stock_amt, 0)) stock_amt
          ,sum(coalesce(siv.stock_qty, 0)) stock_qty
          from order_3d_info_view o3iv
          inner join sku_info_view siv on siv.product_id = o3iv.product_id
          left join stock_info_view skiv on skiv.product_id = siv.product_id
          group by siv.level1
          ,siv.level2
          ,siv.level3
          ,siv.spu_code
          ,siv.spu_name
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
left join (
    select suiv.level1
    ,suiv.level2
    ,suiv.level3
    ,suiv.spu_code
    ,max(suiv.spu_name) spu_name
    ,sum(coalesce(siv.stock_amt, 0)) stock_amt
    from sku_info_view suiv
    inner join order_3d_info_view o3iv on suiv.product_id = o3iv.product_id
    left join stock_info_view siv on suiv.product_id = siv.product_id
    group by suiv.level1
    ,suiv.level2
    ,suiv.level3
    ,suiv.spu_code
)
