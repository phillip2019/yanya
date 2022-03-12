drop view if exists supplier_info_view;
create view supplier_info_view as
 select source_supplier_tbl.supplier_id
,source_supplier_tbl.supplier_code
,source_supplier_tbl.supplier_name
,source_supplier_tbl.supplier_type
,coalesce(if(source_supplier_tbl.contact_name = '', null, source_supplier_tbl.contact_name), 'unknown')   contact_name
,coalesce(if(source_supplier_tbl.contact_mobile = '', null, source_supplier_tbl.contact_mobile), 'unknown') contact_mobile
,coalesce(if(source_supplier_tbl.contact_phone = '', null, source_supplier_tbl.contact_phone), 'unknown')  contact_phone
,coalesce(if(source_supplier_tbl.contact_address = '', null, source_supplier_tbl.contact_address), 'unknown') contact_address
,coalesce(source_supplier_tbl.price_tracking, 'unknown') price_tracking
,coalesce(source_supplier_tbl.business_agent, 'unknown') business_agent
,coalesce(region_tbl.region_code, 'unknown')             region_code
,coalesce(region_tbl.region, 'unknown')                  region
,coalesce(source_supplier_tbl.provice, 'unknown')        provice
,coalesce(source_supplier_tbl.city, 'unknown')           city
,coalesce(if(source_supplier_tbl.area = '', null, source_supplier_tbl.area), 'unknown') area
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