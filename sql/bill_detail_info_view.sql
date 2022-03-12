drop view if exists bill_detail_info_view;
create view bill_detail_info_view as
select id bill_detail_id
,bill_index_id bill_id
,product_id
,product_code
,product_name
,cast(qty as decimal(9, 0)) qty
,coalesce(amount, 0) amt
,coalesce(amount_disc, 0) distinct_amt
,coalesce(net_amount, 0) tax_amt
,cost_amount cost_amt
,date_created created_at
from product_bill
;