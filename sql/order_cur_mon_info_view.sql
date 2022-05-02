-- 本月月份销售订单
drop view if exists order_cur_mon_info_view;
create view order_cur_mon_info_view as
select ppb.product_id
,sum(ppb.qty) sale_qty
,sum(ppb.amt) gmv
,sum(if(pbi.date_created >= date_sub(now(), interval 3 day), ppb.amt, 0)) gmv_3d
from erp.pos_bill_index pbi
left join erp.pos_product_bill ppb on ppb.pos_bill_id = pbi.id
where 1 = 1
and pbi.date_created >= date_add(curdate(), interval - day(curdate()) + 1 day)
and pbi.date_created <  date_add(curdate() - day(curdate()) + 1, interval 1 month);
group by ppb.product_id
;

