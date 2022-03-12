-- 采购入库单
-- 单据明细
drop view if exists purchase_info_view;
create view purchase_info_view as
select id purchase_id
,site_id
,site_name
,site2_id
,bill_type
,bill_name
,code purchase_code
,state
,date_format(bill_date, '%Y-%m-%d') dt
,handle_staff_id handle_by
,dept_id
,cust_supplier_id supplier_id
,cust_code supplier_code
,settle_cust_supplier_id
,in_warehouse_id wh_id
,in_wh_code wh_code
,in_wh_name wh_name
,subject
,create_staff_id
,occur_amt
,if(change_amount is null, 0, change_amount) discount_amt
,total total_amt
,comment remark
,date_created created_at
,staff_id created_by
,staff_code created_code
,pass_date pass_at
from bill_index
where 1 = 1
and bill_type = 'RUKU'
;