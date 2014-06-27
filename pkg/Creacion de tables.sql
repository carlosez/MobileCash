 
drop table BOLINF.XXSV_COMVIVA_RA_INTERFACE ;

CREATE TABLE BOLINF.XXSV_COMVIVA_RA_INTERFACE
(
  status        VARCHAR2(20 BYTE),
    INTERFACE_LINE_ID              NUMBER(15),
  INTERFACE_LINE_CONTEXT         VARCHAR2(30 BYTE),
  INTERFACE_LINE_ATTRIBUTE1      VARCHAR2(150 BYTE),
  INTERFACE_LINE_ATTRIBUTE2      VARCHAR2(150 BYTE),
  INTERFACE_LINE_ATTRIBUTE3      VARCHAR2(150 BYTE),
  BATCH_SOURCE_NAME              VARCHAR2(50 BYTE) NOT NULL,
  SET_OF_BOOKS_ID                NUMBER(15),
  LINE_TYPE                      VARCHAR2(20 BYTE) NOT NULL,
  DESCRIPTION                    VARCHAR2(240 BYTE) NOT NULL,
  CURRENCY_CODE                  VARCHAR2(15 BYTE) NOT NULL,
  AMOUNT                         NUMBER,
  CUST_TRX_TYPE_NAME             VARCHAR2(20 BYTE),
  TERM_NAME                      VARCHAR2(15 BYTE),
  ORIG_SYSTEM_BILL_CUSTOMER_REF  VARCHAR2(240 BYTE),
  ORIG_SYSTEM_BILL_ADDRESS_REF   VARCHAR2(240 BYTE),
  LINK_TO_LINE_CONTEXT           VARCHAR2(30 BYTE),
  CONVERSION_TYPE                VARCHAR2(30 BYTE) NOT NULL,
  CONVERSION_RATE                NUMBER,
  TRX_DATE                       DATE,
  GL_DATE                        DATE,
  QUANTITY                       NUMBER,
  UNIT_SELLING_PRICE             NUMBER,
  PRINTING_OPTION                VARCHAR2(20 BYTE),
  TAX_CODE                       VARCHAR2(50 BYTE),
  MEMO_LINE_NAME                 VARCHAR2(50 BYTE),
  PRIMARY_SALESREP_ID            NUMBER(15),
  UOM_CODE                       VARCHAR2(3 BYTE),
  CREATED_BY                     NUMBER(15),
  CREATION_DATE                  DATE,
  ORG_ID                         NUMBER(15)
)
    
    
    select
    decode(   decode( :p_process_type, 'TRANSFER' , 'I' , 'DISCARD'  ,'D' , nvl(STATUS,'E')   ) ,'P','Pending Export','I','Sent to Interface','E','Error','D','Discarted') status
    , decode(nvl(STATUS,'E'),'P','Pending Export','I','Sent to Interface','E','Error','D','Discarted') status
    ,INTERFACE_LINE_ID
    ,INTERFACE_LINE_CONTEXT                                                
    ,INTERFACE_LINE_ATTRIBUTE1
    ,INTERFACE_LINE_ATTRIBUTE2
    ,INTERFACE_LINE_ATTRIBUTE3
    ,BATCH_SOURCE_NAME                                                
    ,SET_OF_BOOKS_ID
    ,LINE_TYPE                                                
    ,DESCRIPTION
    ,CURRENCY_CODE                                                
    ,AMOUNT
    ,CUST_TRX_TYPE_NAME
    ,TERM_NAME
    ,ORIG_SYSTEM_BILL_CUSTOMER_REF
    ,ORIG_SYSTEM_BILL_ADDRESS_REF
    ,LINK_TO_LINE_CONTEXT                                                
    ,CONVERSION_TYPE
    ,CONVERSION_RATE
    ,TRX_DATE                                                
    ,GL_DATE
    ,QUANTITY                                                
    ,UNIT_SELLING_PRICE
    ,PRINTING_OPTION
    ,TAX_CODE 
    ,MEMO_LINE_NAME
    ,PRIMARY_SALESREP_ID
    ,UOM_CODE                                                
    ,CREATED_BY
    ,CREATION_DATE                                                
    ,ORG_ID
    from  XXSV_COMVIVA_RA_INTERFACE
     WHERE ORG_ID                  = :p_ORG_ID
    and BATCH_SOURCE_NAME       = :P_BATCH_SOURCE
    and INTERFACE_LINE_CONTEXT  = :P_INTERFACE_LINE_CONTEXT
    and NVL( STATUS ,'E') in ( :P_STATUS ) 
    
    grant all on XXSV_COMVIVA_RA_INTERFACE to apps with grant option;
    
    create public synonym XXSV_COMVIVA_RA_INTERFACE for bolinf.XXSV_COMVIVA_RA_INTERFACE;
    
    
    delete from XXSV_COMVIVA_RA_INTERFACE;
    
    update XXSV_CARGA_ARINVOICES_CONVIVA set status = null;
    
    
    346, 10585, 51445, SV-TIGOCASH, SV-TIGOCASH, Y, 2014/06/24 00:00:00, 2014/06/24 00:00:00, Y
    
    
    select * from XXSV_CARGA_ARINVOICES_CONVIVA where status is null
    
    

 select
    STATUS,
    INTERFACE_LINE_ID
    ,INTERFACE_LINE_CONTEXT                                                
    ,INTERFACE_LINE_ATTRIBUTE1
    ,INTERFACE_LINE_ATTRIBUTE2
    ,INTERFACE_LINE_ATTRIBUTE3
    ,BATCH_SOURCE_NAME                                                
    ,SET_OF_BOOKS_ID
    ,LINE_TYPE                                                
    ,DESCRIPTION
    ,CURRENCY_CODE                                                
    ,AMOUNT
    ,CUST_TRX_TYPE_NAME
    ,TERM_NAME
    ,ORIG_SYSTEM_BILL_CUSTOMER_REF
    ,ORIG_SYSTEM_BILL_ADDRESS_REF
    ,LINK_TO_LINE_CONTEXT                                                
    ,CONVERSION_TYPE
    ,CONVERSION_RATE
    ,TRX_DATE                                                
    ,GL_DATE
    ,QUANTITY                                                
    ,UNIT_SELLING_PRICE
    ,PRINTING_OPTION
    ,TAX_CODE 
    ,MEMO_LINE_NAME
    ,PRIMARY_SALESREP_ID
    ,UOM_CODE                                                
    ,CREATED_BY
    ,CREATION_DATE                                                
    ,ORG_ID
    from  XXSV_COMVIVA_RA_INTERFACE tr
     WHERE ORG_ID               = :p_ORG_ID
    and BATCH_SOURCE_NAME       = :P_BATCH_SOURCE
    and INTERFACE_LINE_CONTEXT  = :P_INTERFACE_LINE_CONTEXT
    and tr.gl_date   between nvl(to_date(:P_GL_DATE_INI   , 'YYYY/MM/DD HH24:MI:SS'),tr.gl_date)
                         and nvl(to_date(:P_GL_DATE_FIN   , 'YYYY/MM/DD HH24:MI:SS'),tr.gl_date)
    and tr.trx_DATE  between nvl(to_date(:P_TRX_DATE_INI  , 'YYYY/MM/DD HH24:MI:SS'),tr.trx_DATE)
                         and nvl(to_date(:P_TRX_DATE_FIN  , 'YYYY/MM/DD HH24:MI:SS'),tr.trx_DATE)
   and tr.ORIG_SYSTEM_BILL_CUSTOMER_REF  = nvl(:P_CUSTOMER_ACCOUNT,tr.ORIG_SYSTEM_BILL_CUSTOMER_REF)
   and tr.INTERFACE_LINE_ATTRIBUTE1      = nvl(:P_TRX_NUMBER,tr.INTERFACE_LINE_ATTRIBUTE1)
   and (status = decode(  :P_PROCESS_TYPE ,'TRANSFER', 'I', 'DISCARD','D', 'DRAFT','P' )  or  :P_PROCESS_TYPE =  'REPORT'  )
   
   
   
   select initcap( LEGAL_ENTITY_NAME) LEGAL_ENTITY_NAME from apps.XLE_LE_OU_LEDGER_V
   where OPERATING_UNIT_ID = :p_org_id
   
   
   
    select * 
      from XXSV_COMVIVA_RA_INTERFACE tr
     where ( ((:P_PROCESS_TYPE = 'TRANSFER' )   and (nvl( STATUS,'N') in ('P') )  )
        or   ((:P_PROCESS_TYPE = 'DISCARD'  )   and (nvl( STATUS,'N') in ('D','N','P') ))
           )
       and tr.ORG_ID                    = :P_ORG_ID
       and tr.BATCH_SOURCE_NAME         = :P_BATCH_SOURCE
       and tr.INTERFACE_LINE_CONTEXT    = :P_INTERFACE_LINE_CONTEXT
       and tr.gl_date   between nvl(to_date(:P_GL_DATE_INI   , 'YYYY/MM/DD HH24:MI:SS'),tr.gl_date)
                            and nvl(to_date(:P_GL_DATE_FIN   , 'YYYY/MM/DD HH24:MI:SS'),tr.gl_date)
       and tr.trx_DATE  between nvl(to_date(:P_TRX_DATE_INI  , 'YYYY/MM/DD HH24:MI:SS'),tr.trx_DATE)
                            and nvl(to_date(:P_TRX_DATE_FIN  , 'YYYY/MM/DD HH24:MI:SS'),tr.trx_DATE)
       and tr.ORIG_SYSTEM_BILL_CUSTOMER_REF  = nvl(:P_CUSTOMER_ACCOUNT,tr.ORIG_SYSTEM_BILL_CUSTOMER_REF)
       and tr.INTERFACE_LINE_ATTRIBUTE1      = nvl(:P_TRX_NUMBER,tr.INTERFACE_LINE_ATTRIBUTE1)
       
       
          update
       XXSV_COMVIVA_RA_INTERFACE tr
     set status = null
      where INTERFACE_LINE_ID between 15811532 and 15811533
      ;
       

select
    decode(nvl(STATUS,'E'),'S','Pending Export','P','Pending Export','I','Sent to Interface','E','Error','D','Discarted') status
    ,INTERFACE_LINE_ID
    ,INTERFACE_LINE_CONTEXT                                                
    ,INTERFACE_LINE_ATTRIBUTE1
    ,INTERFACE_LINE_ATTRIBUTE2
    ,INTERFACE_LINE_ATTRIBUTE3
    ,BATCH_SOURCE_NAME                                                
    ,SET_OF_BOOKS_ID
    ,LINE_TYPE                                                
    ,DESCRIPTION
    ,CURRENCY_CODE                                                
    ,AMOUNT
    ,CUST_TRX_TYPE_NAME
    ,TERM_NAME
    ,ORIG_SYSTEM_BILL_CUSTOMER_REF
    ,ORIG_SYSTEM_BILL_ADDRESS_REF
    ,LINK_TO_LINE_CONTEXT                                                
    ,CONVERSION_TYPE
    ,CONVERSION_RATE
    ,TRX_DATE                                                
    ,GL_DATE
    ,QUANTITY                                                
    ,UNIT_SELLING_PRICE
    ,PRINTING_OPTION
    ,TAX_CODE 
    ,MEMO_LINE_NAME
    ,PRIMARY_SALESREP_ID
    ,UOM_CODE                                                
    ,CREATED_BY
    ,CREATION_DATE                                                
    ,ORG_ID
    from  XXSV_COMVIVA_RA_INTERFACE tr
     WHERE ORG_ID               = :p_ORG_ID
    and BATCH_SOURCE_NAME       = :P_BATCH_SOURCE
    and INTERFACE_LINE_CONTEXT  = :P_INTERFACE_LINE_CONTEXT
    and tr.gl_date   between nvl(to_date(:P_GL_DATE_INI   , 'YYYY/MM/DD HH24:MI:SS'),tr.gl_date)
                         and nvl(to_date(:P_GL_DATE_FIN   , 'YYYY/MM/DD HH24:MI:SS'),tr.gl_date)
    and tr.trx_DATE  between nvl(to_date(:P_TRX_DATE_INI  , 'YYYY/MM/DD HH24:MI:SS'),tr.trx_DATE)
                         and nvl(to_date(:P_TRX_DATE_FIN  , 'YYYY/MM/DD HH24:MI:SS'),tr.trx_DATE)
   and tr.ORIG_SYSTEM_BILL_CUSTOMER_REF  = nvl(:P_CUSTOMER_ACCOUNT,tr.ORIG_SYSTEM_BILL_CUSTOMER_REF)
   and tr.INTERFACE_LINE_ATTRIBUTE1      = nvl(:P_TRX_NUMBER,tr.INTERFACE_LINE_ATTRIBUTE1)
   and decode(:P_PROCESS_TYPE ,'DISCARD' ,  decode( STATUS, null, 'P', 'E' , 'P', STATUS  ) , nvl( STATUS,'N')  ) = 'P'
 
 
 update XXSV_COMVIVA_RA_INTERFACE
 set  STATUS = 'P'
 where STATUS = 'D'
 
         update
       XXSV_COMVIVA_RA_INTERFACE tr
     set status = ''
      where INTERFACE_LINE_ID between 15811569 and 15811571
      ;
      
      commit; 
 
  select max(INTERFACE_LINE_ID)
   from  XXSV_COMVIVA_RA_INTERFACE tr
   --+ 15811539
   
   select * from XXSV_COMVIVA_RA_INTERFACE
   order by INTERFACE_LINE_ID desc
   
   
   
   --+ 
   --+ 
   --+
   --+
   --+
   
   drop table xxsv_COMVIVA_AP_INV
   
   delete from XXSV_COMVIVA_AP_INVOICES_INT;
   
   create public synonym XXSV_COMVIVA_AP_INVOICES for bolinf.XXSV_COMVIVA_AP_INVOICES;
   
   grant all on XXSV_COMVIVA_AP_INVOICES to apps with grant option;
   
   create table XXSV_COMVIVA_AP_INVOICES as
   select 
       SOURCE                      --+ 1
       ,INVOICE_TYPE_LOOKUP_CODE    --+ 2
       ,INVOICE_NUM                 --+ 3
       ,INVOICE_DATE                --+ 4
       ,GL_DATE                     --+ 5
       ,VENDOR_ID                   --+ 6
       ,VENDOR_NAME                 --+ 7
       ,VENDOR_SITE_CODE            --+ 8
       ,INVOICE_AMOUNT              --+ 9
       ,INVOICE_CURRENCY_CODE       --+ 10
       ,EXCHANGE_RATE_TYPE          --+ 11
       ,EXCHANGE_RATE               --+ 12
       ,EXCHANGE_DATE               --+ 13
       ,DESCRIPTION                 --+ 14
       ,ORG_ID                      --+ 15
       ,INVOICE_ID                  --+ 16
       ,INVOICE_RECEIVED_DATE       --+ 17
       ,CALC_TAX_DURING_IMPORT_FLAG
       from AP_INVOICES_INTERFACE
       where invoice_id = 416486
       
       
       create table XXSV_COMVIVA_AP_INVOICE_LINES
        as select LINE_TYPE_LOOKUP_CODE     --+ 1
         ,AMOUNT                    --+ 2
         ,DESCRIPTION               --+ 3
         ,DIST_CODE_CONCATENATED    --+ 4
         ,LINE_NUMBER               --+ 5
         ,ACCOUNTING_DATE           --+ 6
         ,INVOICE_ID                --+ 7
         ,TAX_CODE                  --+ 8
         ,TAX
         from AP_INVOICE_LINES_INTERFACE
           where invoice_id = 416486
       
       grant all on XXSV_COMVIVA_AP_INVOICE_LINES to apps with grant option;
       
       create or replace public synonym XXSV_COMVIVA_AP_INVOICE_LINES 
       for bolinf.XXSV_COMVIVA_AP_INVOICE_LINES
       
       
       select * from XXSV_COMVIVA_AP_INVOICE_LINES
       
       delete from XXSV_COMVIVA_AP_INVOICE_LINES where amount !=-5036.8
       
       select 
      decode(   nvl(iv.STATUS,'E') ,'S','Pending Export' ,'P','Pending Export','I','Sent to Interface','E','Error','D','Discarted') status
       ,iv.SOURCE                      --+ 1
       ,iv.INVOICE_TYPE_LOOKUP_CODE    --+ 2
       ,iv.INVOICE_NUM                 --+ 3
       ,iv.INVOICE_DATE                --+ 4
       ,iv.GL_DATE                     --+ 5
       ,iv.VENDOR_ID                   --+ 6
       ,iv.vendor_num
       ,iv.VENDOR_NAME                 --+ 7
       ,iv.VENDOR_SITE_CODE            --+ 8
       ,iv.INVOICE_AMOUNT              --+ 9
       ,iv.INVOICE_CURRENCY_CODE       --+ 10
       ,iv.EXCHANGE_RATE_TYPE          --+ 11
       ,iv.EXCHANGE_RATE               --+ 12
       ,iv.EXCHANGE_DATE               --+ 13
       ,iv.DESCRIPTION                 --+ 14
       ,iv.ORG_ID                      --+ 15
       ,iv.INVOICE_ID                  --+ 16
       ,iv.INVOICE_RECEIVED_DATE       --+ 17
       ,iv.CALC_TAX_DURING_IMPORT_FLAG
     ,ivl.AMOUNT                    --+ 2
     ,ivl.DESCRIPTION               --+ 3
     ,ivl.DIST_CODE_CONCATENATED    --+ 4
     ,ivl.LINE_NUMBER               --+ 5
     ,ivl.ACCOUNTING_DATE           --+ 6
     ,ivl.TAX_CODE                  --+ 8
     ,ivl.TAX
         from 
         XXSV_COMVIVA_AP_INVOICE_LINES ivl
         ,XXSV_COMVIVA_AP_INVOICES   iv
         where ivl.invoice_id = iv.invoice_id
         and nvl( iv.status,'N') = 'P'
        and iv.gl_date   between nvl(to_date(:P_GL_DATE       , 'YYYY/MM/DD HH24:MI:SS'),iv.gl_date)
                             and nvl(to_date(:P_GL_DATE_FIN    , 'YYYY/MM/DD HH24:MI:SS'),iv.gl_date)
        and iv.INVOICE_DATE      between nvl(to_date(:P_INVOICE_DATE          , 'YYYY/MM/DD HH24:MI:SS'),iv.INVOICE_DATE)   
                            and nvl(to_date(:P_INVOICE_DATE_FIN    , 'YYYY/MM/DD HH24:MI:SS'),iv.INVOICE_DATE)
        and iv.VENDOR_NUM     = nvl(:P_VENDOR_NUM    , iv.vendor_num) 
        and iv.invoice_num = nvl(:P_INVOICE_NUM, iv.invoice_num)  
            and SOURCE = :p_source
            and ORG_ID  = :P_org_id ;
         
update XXSV_COMVIVA_AP_INVOICES
set  VENDOR_NUM = vendor_ID

            update XXSV_CARGA_APINVOICES set status = ''
            
         update XXSV_COMVIVA_AP_INVOICE_LINES set status = 'S' 
         
          update XXSV_COMVIVA_AP_INVOICES set status = 'S' 
         
         
         SELECT * FROM XXSV_COMVIVA_AP_INVOICE_LINES ;
         
          SELECT * FROM XXSV_COMVIVA_AP_INVOICES ;
         
      SELECT * FROM XXSV_CARGA_APINVOICES
      where SOURCE = :p_source
        and ORG_ID  = :P_org_id
        and status != 'P' ;
      
      
      DELETE FROM XXSV_CARGA_APINVOICES;
       
       DELETE FROM XXSV_COMVIVA_AP_INVOICE_LINES;
       
        DELETE FROM XXSV_COMVIVA_AP_INVOICES;
        
        commit;
        
        

 select
        SOURCE                      --+ 1  # P
       ,INVOICE_TYPE_LOOKUP_CODE    --+ 2  # P
       ,INVOICE_CURRENCY_CODE       --+ 3  # P 
       ,VENDOR_NUM                  --+ 4  # P
       ,VENDOR_SITE_CODE            --+ 5  # P
       ,ORG_ID                      --+ 6  # P
       ,CALC_TAX_DURING_IMPORT_FLAG --+ 7  #
       ,EXCHANGE_RATE_TYPE          --+ 10 %
       ,EXCHANGE_RATE               --+ 11 %
       ,EXCHANGE_DATE               --+ 12 %
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :g_invoice_num   ,INVOICE_NUM)         INVOICE_NUM     --+ 20 # P 
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :g_invoice_date  ,INVOICE_DATE)        INVOICE_DATE    --+ 21 # P
       ,SUM(AMOUNT_LINE)                                                      INVOICE_AMOUNT_CALC
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', 0                ,INVOICE_AMOUNT)     INVOICE_AMOUNT  --+ 22     C
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', DESCRIPTION     ,DESCRIPTION)         DESCRIPTION     --+ 23 #   C
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :G_GL_DATE       ,GL_DATE)             GL_DATE         --+ 24 #
  FROM XXSV_CARGA_APINVOICES ivh
 WHERE ivh.ORG_ID = :P_ORG_ID
   AND NVL(ivh.STATUS,'N') in ( 'N' )
   group by ( SOURCE                      --+ 1  # P
       ,INVOICE_TYPE_LOOKUP_CODE    --+ 2  # P
       ,INVOICE_CURRENCY_CODE       --+ 3  # P 
       ,VENDOR_NUM                  --+ 4  # P
       ,VENDOR_SITE_CODE            --+ 5  # P
       ,ORG_ID                      --+ 6  # P
       ,CALC_TAX_DURING_IMPORT_FLAG --+ 7  #
       ,EXCHANGE_RATE_TYPE          --+ 10 %
       ,EXCHANGE_RATE               --+ 11 %
       ,EXCHANGE_DATE               --+ 12 %
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :g_invoice_num   ,INVOICE_NUM)
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :g_invoice_date  ,INVOICE_DATE)
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', 0               ,INVOICE_AMOUNT)
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', DESCRIPTION     ,DESCRIPTION)
       ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :G_GL_DATE       ,GL_DATE)
       )
   order by VENDOR_NUM, VENDOR_SITE_CODE, INVOICE_NUM;




  select apd.LINE_TYPE_LOOKUP_CODE
        ,sum(apd.AMOUNT_LINE) AMOUNT_LINE
        ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', LAST_DESCRIPTION_LINE  , DESCRIPTION_LINE)  DESCRIPTION_LINE
        ,apd.DIST_CODE_CONCATENATED
        ,apd.LINE_NUMBER
        ,apd.TAX_CODE
        ,apd.TAX
        ,apd.CALC_TAX_DURING_IMPORT_FLAG
  from
      (
     SELECT LINE_TYPE_LOOKUP_CODE
           ,AMOUNT_LINE
           ,DESCRIPTION_LINE
           ,LAST_VALUE(DESCRIPTION_LINE)  OVER ( 
                ORDER BY  DESCRIPTION_LINE
                 ROWS BETWEEN UNBOUNDED PRECEDING AND  UNBOUNDED FOLLOWING   ) AS LAST_DESCRIPTION_LINE
           ,DIST_CODE_CONCATENATED
           ,LINE_NUMBER
           ,TAX_CODE
           ,TAX    
           ,CALC_TAX_DURING_IMPORT_FLAG
      FROM XXSV_CARGA_APINVOICES
     WHERE NVL(STATUS,'N') in ( 'N'  )
       and SOURCE                      = :p_SOURCE
       and INVOICE_TYPE_LOOKUP_CODE    = :p_INVOICE_TYPE_LOOKUP_CODE
       and INVOICE_CURRENCY_CODE       = :p_INVOICE_CURRENCY_CODE
       and VENDOR_NUM                  = :p_VENDOR_NUM
       and VENDOR_SITE_CODE            = :p_VENDOR_SITE_CODE
       and ORG_ID                      = :p_ORG_ID
--       and DECODE(:P_GROUP_BY_SUPPLIER,'Y', :g_invoice_num   ,INVOICE_NUM)  = :p_INVOICE_NUM
--       and DECODE(:P_GROUP_BY_SUPPLIER,'Y', :g_invoice_date  ,INVOICE_DATE) = :p_INVOICE_DATE
      ) apd
  group by 
        (LINE_TYPE_LOOKUP_CODE
        ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', LAST_DESCRIPTION_LINE  , DESCRIPTION_LINE)
        ,DIST_CODE_CONCATENATED
        ,LINE_NUMBER
        ,TAX_CODE
        ,TAX    
        ,CALC_TAX_DURING_IMPORT_FLAG
        )
       ;   
       
       --+ SVLASOUSD0001
       --+ 14332
       --+ STANDARD
       --+ USD
       --+ 346
       
       
       
       
        || 'and iv.gl_date   between nvl(to_date(:P_GL_DATE       , ''YYYY/MM/DD HH24:MI:SS''),iv.gl_date)'    
        ||                                           'and nvl(to_date(:P_GL_DATE_FIN    , ''YYYY/MM/DD HH24:MI:SS''),iv.gl_date)'
        || 'and iv.INVOICE_DATE      between nvl(to_date(:P_invoice_DATE          , ''YYYY/MM/DD HH24:MI:SS''),iv.INVOICE_DATE)    '
        ||                                                     'and nvl(to_date(:P_invoice_DATE_FIN    , ''YYYY/MM/DD HH24:MI:SS''),iv.INVOICE_DATE)'
        ||' and iv.vendor_num     = nvl(:p_vendor_num    , iv.vendor_num)    '
        ||' and iv.invoice_num = nvl(:p_invoice_num, iv.invoice_num)    '
        ||' and nvl(iv.status, ''N'' ) in ( ''P'' ) '
        
        
        
        
