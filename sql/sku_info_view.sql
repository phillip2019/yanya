-- 创建sku信息表视图
drop view if exists sku_info_view;
create view sku_info_view as
select pt1.p_name level1
,pt1.p_code level1_id
,coalesce(pt2.p_name, pt1.p_name) level2
,coalesce(pt2.p_code, pt1.p_code) level2_id
,coalesce(pt3.p_name, pt2.p_name, pt1.p_name) level3
,coalesce(pt3.p_code, pt2.p_code, pt1.p_code) level3_id
,t.id product_id
,t.spu_code
,t.spu_name
,t.code product_code
,t.name product_name
,coalesce(pp.cost_price, 0) cost_price
,coalesce(pp.sale_price, 0) sale_price
,coalesce(pp.wholesale_price, 0) wholesale_price
,t.created_at
,date_format(t.created_at, '%Y-%m-%d') dt
,t.site_id
from (
        -- 3月启用新spu-sku方案，按照新spu-sku方案加工, 查询18位的商品sku对应spu名称
        select coalesce(pt.p_code, source_t.code) spu_code
            ,pt.p_name spu_name
            ,source_t.id
            ,source_t.code
            ,source_t.name
            ,source_t.created_at
            ,source_t.site_id
            ,substring(source_t.p_paths, 1, 4) p1_paths
            ,substring(source_t.p_paths, 1, 8) p2_paths
            ,substring(source_t.p_paths, 1, 12) p3_paths
            ,substring(source_t.p_paths, 1, 16) p4_paths
        from (
                select id
                ,code
                ,name
                ,create_date created_at
                ,paths
                ,substring(paths, 1, length(paths) - 4) p_paths
                ,site_id
                from erp.product
                where 1 = 1
                and length(code) in (12, 16, 18, 19)
                and has_child = false
                and create_date >= str_to_date('2022-02-28', '%Y-%m-%d %H:%i:%s')
            ) source_t left join (
                select code p_code
                ,name p_name
                ,paths p_paths
                from erp.product
                where has_child = true
            ) pt on pt.p_paths = source_t.p_paths
        where 1 = 1
        union all
        -- 2022年2月28号采用新spu-sku方案，但是只有单sku成spu情况
        select  code spu_code
                ,name spu_name
                ,id
                ,code
                ,name
                ,create_date created_at
                ,site_id
                ,substring(paths, 1, 4) p1_paths
                ,substring(paths, 1, 8) p2_paths
                ,substring(paths, 1, 12) p3_paths
                ,substring(paths, 1, 16) p4_paths
                from erp.product
                where 1 = 1
                and length(code) not in (12, 16, 18, 19)
                and has_child = false
                and create_date >= str_to_date('2022-02-28', '%Y-%m-%d %H:%i:%s')
        union all
        select case
                when char_length(substring_index(source_t2.name, '/', 1)) < 4 then substring_index(substring_index(source_t2.name, '/', 2), '/', -1)
                when substring(source_t2.name, 1, 6) in (
                    '73144/'
                    ) then substring_index(source_t2.name, '/', 2)
    #             when length(t.code) = 14 and substring(t.name, -1, 2) in ('/宽', '/细') then substring_index(t.name, '/', -1)
                when source_t2.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s') and char_length(substring_index(source_t2.name, '/', -1)) < 5 then substring_index(substring_index(source_t2.name, '/', -2), '/', 1)
                when source_t2.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s') then substring_index(source_t2.name, '/', -1)
                else substring_index(source_t2.name, '/', 1)
            end spu_code
            ,case
                when char_length(substring_index(source_t2.name, '/', 1)) < 4 then substring_index(substring_index(source_t2.name, '/', 2), '/', -1)
                when substring(source_t2.name, 1, 6) in (
                    '73144/'
                    ) then substring_index(source_t2.name, '/', 2)
    #             when length(t.code) = 14 and substring(t.name, -1, 2) in ('/宽', '/细') then substring_index(t.name, '/', -1)
                when source_t2.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s') and char_length(substring_index(source_t2.name, '/', -1)) < 5 then substring_index(substring_index(source_t2.name, '/', -2), '/', 1)
                when source_t2.created_at >= str_to_date('2021-01-01', '%Y-%m-%d %H:%i:%s') then substring_index(source_t2.name, '/', -1)
                else substring_index(source_t2.name, '/', 1)
            end spu_name
            ,source_t2.id
            ,source_t2.code
            ,source_t2.full_name name
            ,source_t2.created_at
            ,source_t2.site_id
            ,substring(paths, 1, 4) p1_paths
            ,substring(paths, 1, 8) p2_paths
            ,substring(paths, 1, 12) p3_paths
            ,substring(paths, 1, 16) p4_paths
        from (
                select id
                ,code
                ,replace(replace(replace(name, '3对装/', ''), '2对装/', ''), '1对装/', '') name
                ,name full_name
                ,create_date created_at
                ,site_id
                ,paths
                from erp.product
                where has_child = false
                and create_date < str_to_date('2022-02-28', '%Y-%m-%d %H:%i:%s')
        ) source_t2
        where 1 = 1
    ) t
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
   ,price1 wholesale_price
   from erp.product_price
   where site_id = 1251
) pp on pp.product_id = t.id
    and pp.site_id = t.site_id
where 1 = 1
;