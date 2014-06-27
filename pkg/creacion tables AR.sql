


select sum(dt.QUANTITY) QUANTITY
        ,sum(dt.AMOUNT) AMOUNT
        , sum(dt.AMOUNT)/sum(dt.QUANTITY) UNIT_SELLING_PRICE 
        --,decode( :p_group_by_customer,'Y',LAST_INTERFACE_LINE_ATTRIBUTE1, INTERFACE_LINE_ATTRIBUTE1) INTERFACE_LINE_ATTRIBUTE1
--       ,RANK() OVER (PARTITION BY
--                         ORIG_SYSTEM_BILL_CUSTOMER_REF
--                       ,dt.CUST_TRX_TYPE_NAME
--                       ,dt.MEMO_LINE_NAME
--                       ,INTERFACE_LINE_ATTRIBUTE1 
--                       ORDER BY  ORIG_SYSTEM_BILL_CUSTOMER_REF ,dt.CUST_TRX_TYPE_NAME , dt.INTERFACE_LINE_ATTRIBUTE1 
--                       ) LINE_NUMBER
       ,ORIG_SYSTEM_BILL_CUSTOMER_REF
       ,CONVERSION_RATE
       ,CONVERSION_TYPE
       ,CURRENCY_CODE
       ,max(GL_DATE) GL_DATE
       ,max(TRX_DATE) TRX_DATE
       ,max(TERM_NAME) TERM_NAME
       ,PRINTING_OPTION
       ,INTERFACE_LINE_CONTEXT
       ,UOM_CODE
       ,BATCH_SOURCE_NAME
       ,CUST_TRX_TYPE_NAME
       ,LINK_TO_LINE_CONTEXT
       ,TAX_CODE
       ,PRIMARY_SALESREP_ID
       ,MEMO_LINE_NAME
       ,ORIG_SYSTEM_BILL_ADDRESS_REF
       ,DESCRIPTION
       ,LINE_TYPE
       ,SET_OF_BOOKS_ID
from (
SELECT   AR.QUANTITY
        ,ar.AMOUNT
        ,AR. UNIT_SELLING_PRICE 
        ,ORIG_SYSTEM_BILL_CUSTOMER_REF
        ,AR.INTERFACE_LINE_ATTRIBUTE1
        ,LAST_VALUE(AR.INTERFACE_LINE_ATTRIBUTE1)
          OVER ( PARTITION BY 
                  ORIG_SYSTEM_BILL_CUSTOMER_REF
                   ,ar.CUST_TRX_TYPE_NAME
                ORDER BY  ORIG_SYSTEM_BILL_CUSTOMER_REF ,ar.CUST_TRX_TYPE_NAME , ar.INTERFACE_LINE_ATTRIBUTE1 ROWS BETWEEN UNBOUNDED PRECEDING AND   UNBOUNDED FOLLOWING   ) AS LAST_INTERFACE_LINE_ATTRIBUTE1
        ,ar.CUST_TRX_TYPE_NAME   INTERFACE_LINE_ATTRIBUTE2
         ,decode( :p_group_by_customer,'Y', 1, LINE_NUMBER ) LINE_NUMBER
        ,AR.CONVERSION_RATE
        ,AR.CONVERSION_TYPE
        ,AR.CURRENCY_CODE
        ,decode( :p_group_by_customer,'Y', :g_gl_date, AR.GL_DATE)  GL_DATE
        ,decode( :p_group_by_customer,'Y', :g_trx_date, AR.TRX_DATE) TRX_DATE
        ,AR.TERM_NAME
        ,AR.PRINTING_OPTION
        ,AR.INTERFACE_LINE_CONTEXT
        ,AR.UOM_CODE
        ,AR.BATCH_SOURCE_NAME
        ,AR.CUST_TRX_TYPE_NAME
        ,AR.LINK_TO_LINE_CONTEXT
        ,AR.TAX_CODE
        ,AR.PRIMARY_SALESREP_ID
        ,AR.MEMO_LINE_NAME
        ,AR.ORIG_SYSTEM_BILL_ADDRESS_REF
        ,AR.DESCRIPTION
        ,AR.LINE_TYPE
        ,AR.SET_OF_BOOKS_ID
   FROM XXSV_CARGA_ARINVOICES_CONVIVA AR
  WHERE NVL(STATUS,'C') in ('C', 'N') 
    AND ORG_ID                  = :p_ORG_ID
    and BATCH_SOURCE_NAME       = :P_BATCH_SOURCE
    and INTERFACE_LINE_CONTEXT  = :P_INTERFACE_LINE_CONTEXT
    )  dt
  GROUP BY  ORIG_SYSTEM_BILL_CUSTOMER_REF
           ,dt.CUST_TRX_TYPE_NAME
           ,decode( :p_group_by_customer,'Y',LAST_INTERFACE_LINE_ATTRIBUTE1, INTERFACE_LINE_ATTRIBUTE1)
           ,dt.CONVERSION_RATE
           ,dt.CONVERSION_TYPE
           ,dt.CURRENCY_CODE
           ,dt.PRINTING_OPTION
           ,dt.INTERFACE_LINE_CONTEXT
           ,dt.UOM_CODE
           ,dt.BATCH_SOURCE_NAME
           ,dt.CUST_TRX_TYPE_NAME
           ,dt.INTERFACE_LINE_ATTRIBUTE1
           ,dt.LINK_TO_LINE_CONTEXT
           ,dt.TAX_CODE
           ,dt.PRIMARY_SALESREP_ID
           ,dt.MEMO_LINE_NAME
           ,dt.PRIMARY_SALESREP_ID
           ,dt.ORIG_SYSTEM_BILL_ADDRESS_REF
           ,dt.DESCRIPTION
           ,dt.LINE_TYPE
           ,dt.SET_OF_BOOKS_ID
           order by 14, 13;
           
           
           
           select *
              FROM XXSV_CARGA_ARINVOICES_CONVIVA AR
  WHERE NVL(STATUS,'C') in ('C', 'N') 
    AND ORG_ID                  = :p_ORG_ID
    and BATCH_SOURCE_NAME       = :p_Batch_Source
    and INTERFACE_LINE_CONTEXT  = :p_interface_line_context
--        and ORIG_SYSTEM_BILL_CUSTOMER_REF = 'SV-TM31'
--    and  MEMO_LINE_NAME = 'SV-COMISION POR SERVICIO COLECTURIA'
    order by INTERFACE_LINE_ATTRIBUTE1;
    
     
 select sum(dt.QUANTITY) QUANTITY
        ,sum(dt.AMOUNT) AMOUNT
        , sum(dt.AMOUNT)/sum(dt.QUANTITY) UNIT_SELLING_PRICE 
        ,ORIG_SYSTEM_BILL_CUSTOMER_REF
        ,CUST_TRX_TYPE_NAME
        ,decode( :p_group_by_customer,'Y',  dt.LAST_INTERFACE_LINE_ATTRIBUTE1 , dt.INTERFACE_LINE_ATTRIBUTE1)  INTERFACE_LINE_ATTRIBUTE1
        ,decode( :p_group_by_customer,'Y',  dt.LINE_NUMBER_RANK , dt.line_number )  line_number
        ,MEMO_LINE_NAME
        ,decode( :p_group_by_customer,'Y', :g_gl_date , dt.GL_DATE)  GL_DATE
        ,decode( :p_group_by_customer,'Y', :g_trx_date, dt.TRX_DATE) TRX_DATE
        ,DT.CONVERSION_RATE
        ,DT.CONVERSION_TYPE
        ,DT.CURRENCY_CODE
        ,dt.TERM_NAME
        ,dt.PRINTING_OPTION
        ,dt.INTERFACE_LINE_CONTEXT
        ,dt.UOM_CODE
        ,dt.BATCH_SOURCE_NAME
        ,dt.LINK_TO_LINE_CONTEXT
        ,dt.TAX_CODE
        ,dt.PRIMARY_SALESREP_ID
        ,dt.ORIG_SYSTEM_BILL_ADDRESS_REF
        ,dt.DESCRIPTION
        ,dt.LINE_TYPE
        ,dt.SET_OF_BOOKS_ID
   from 
    (
 SELECT  AR.QUANTITY
        ,ar.AMOUNT
        ,AR. UNIT_SELLING_PRICE 
        ,ORIG_SYSTEM_BILL_CUSTOMER_REF
        ,AR.INTERFACE_LINE_ATTRIBUTE1
        ,LAST_VALUE(AR.INTERFACE_LINE_ATTRIBUTE1)  OVER ( 
            PARTITION BY  ORIG_SYSTEM_BILL_CUSTOMER_REF ,ar.CUST_TRX_TYPE_NAME
                ORDER BY  ORIG_SYSTEM_BILL_CUSTOMER_REF ,ar.CUST_TRX_TYPE_NAME , ar.INTERFACE_LINE_ATTRIBUTE1
                 ROWS BETWEEN UNBOUNDED PRECEDING AND  UNBOUNDED FOLLOWING   ) AS LAST_INTERFACE_LINE_ATTRIBUTE1
        ,ar.CUST_TRX_TYPE_NAME   CUST_TRX_TYPE_NAME
        ,AR.MEMO_LINE_NAME
        ,LINE_NUMBER
       ,DENSE_RANK() OVER (
        PARTITION BY ORIG_SYSTEM_BILL_CUSTOMER_REF  ,ar.CUST_TRX_TYPE_NAME 
            ORDER BY ORIG_SYSTEM_BILL_CUSTOMER_REF  ,ar.CUST_TRX_TYPE_NAME ,AR.MEMO_LINE_NAME  ) LINE_NUMBER_RANK
        ,AR.CONVERSION_RATE
        ,AR.CONVERSION_TYPE
        ,AR.CURRENCY_CODE
          ,ar.GL_DATE
          ,ar.trx_date
        ,AR.TERM_NAME
        ,AR.PRINTING_OPTION
        ,AR.INTERFACE_LINE_CONTEXT
        ,AR.UOM_CODE
        ,AR.BATCH_SOURCE_NAME
        ,AR.LINK_TO_LINE_CONTEXT
        ,AR.TAX_CODE
        ,AR.PRIMARY_SALESREP_ID
        ,AR.ORIG_SYSTEM_BILL_ADDRESS_REF
        ,AR.DESCRIPTION
        ,AR.LINE_TYPE
        ,AR.SET_OF_BOOKS_ID
   FROM XXSV_CARGA_ARINVOICES_CONVIVA AR
  WHERE NVL(STATUS,'C') in ( :P_STATUS ) 
--    and ORIG_SYSTEM_BILL_CUSTOMER_REF = 'SV-TM29'
--    and  MEMO_LINE_NAME = 'SV-COMISION POR SERVICIO COLECTURIA'
    AND ORG_ID                  = :p_ORG_ID
    and BATCH_SOURCE_NAME       = :P_BATCH_SOURCE
    and INTERFACE_LINE_CONTEXT  = :P_INTERFACE_LINE_CONTEXT
   ) dt
   group by 
        dt.ORIG_SYSTEM_BILL_CUSTOMER_REF
        ,dt.CUST_TRX_TYPE_NAME
        ,decode( :p_group_by_customer,'Y',  dt.LAST_INTERFACE_LINE_ATTRIBUTE1 , dt.INTERFACE_LINE_ATTRIBUTE1)
        ,decode( :p_group_by_customer,'Y',  dt.LINE_NUMBER_RANK , dt.line_number )
        ,MEMO_LINE_NAME 
        ,DT.CONVERSION_RATE
        ,DT.CONVERSION_TYPE
        ,DT.CURRENCY_CODE
        ,decode( :p_group_by_customer,'Y', :g_gl_date , dt.GL_DATE)
        ,decode( :p_group_by_customer,'Y', :g_trx_date, dt.TRX_DATE)
        ,dt.TERM_NAME
        ,dt.PRINTING_OPTION
        ,dt.INTERFACE_LINE_CONTEXT
        ,dt.UOM_CODE
        ,dt.BATCH_SOURCE_NAME
        ,dt.LINK_TO_LINE_CONTEXT
        ,dt.TAX_CODE
        ,dt.PRIMARY_SALESREP_ID
        ,dt.ORIG_SYSTEM_BILL_ADDRESS_REF
        ,dt.DESCRIPTION
        ,dt.LINE_TYPE
        ,dt.SET_OF_BOOKS_ID
        ;
        
        
--        
--        delete    FROM XXSV_CARGA_ARINVOICES_CONVIVA AR
--  WHERE NVL(STATUS,'C') in ('C', 'N') 


update     XXSV_CARGA_ARINVOICES_CONVIVA AR
set STATUS = 'P'
  WHERE NVL(STATUS,'C') in ('C', 'N') 
  ;
  
  
  select MEANING from FND_LOOKUPS WHERE LOOKUP_TYPE='YES_NO' and lookup_code = 'Y'
  
  
  select 
  DESCRIPTIVE_FLEX_CONTEXT_CODE
  from
  (SELECT distinct DESCRIPTIVE_FLEX_CONTEXT_CODE, DESCRIPTIVE_FLEXFIELD_NAME, ENABLED_FLAG FROM fnd_descr_flex_column_usages)
   WHERE DESCRIPTIVE_FLEXFIELD_NAME = 'RA_INTERFACE_LINES'
   AND ENABLED_FLAG = 'Y'
 ORDER BY DESCRIPTIVE_FLEX_CONTEXT_CODE ASC
 
 
 select RA.NAME
 from RA_BATCH_SOURCES_ALL RA
 WHERE RA.ORG_ID = 346
 ;
 
 
 select * from XXSV_CARGA_ARINVOICES_CONVIVA;
 
 
FND_REQUEST.ADD_LAYOUT (
        ,template_appl_name  => 'XBOL'
        ,template_code       => 'XX'
        ,template_language   => 'en'
        ,template_territory  => 'US'
        ,output_format       => 'EXCEL'
        );
        
        
        
select ou.name operating_unit
      ,sp.segment1
      ,sp.vendor_name
      ,ss.vendor_site_code
  from ap.ap_suppliers sp
      ,ap.ap_supplier_sites_all ss
      ,hr_operating_units ou
  where ss.org_id = ou.organization_id
    and sp.vendor_id = ss.vendor_id
    and ou.name like 'SV%'
    ;