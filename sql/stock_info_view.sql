-- 创建库存表，排除加盟商库存信息
drop view stock_info_view;
create view stock_info_view as
select s.product_id
,s.product_name
,sum(qty + lock_qty + coalesce(move_qty, 0)) stock_qty
,sum(round(coalesce(pp.wholesale_price * (qty + lock_qty + coalesce(move_qty, 0)), s.amt), 2)) stock_amt
,min(if(warehouse_code in ('总部仓库', '总部调货仓库', '总部运营'), null, date_created)) shop_first_created_at
from erp.stock s
left join (
    select product_id
    ,max(buy_price) cost_price
    ,max(price0) sale_price
    ,max(price1) wholesale_price
    from erp.product_price
    where  1 = 1
    group by product_id
) pp on pp.product_id = s.product_id
where 1 = 1
and (
    s.qty > 0
)
# 排除加盟商库存
and s.warehouse_code not in (
                        '6052',
                        '6061',
                        '6078',
                        '6079',
                        '6080',
                        '6082',
                        '6087',
                        '6089',
                        '6090',
                        '6091',
                        '6092',
                        '6093',
                        '6096',
                        '6095',
                        '6094',
                        '6097',
                        '6098',
                        '6099',
                        '6100'
)
group by s.product_id
,s.product_name
;