CREATE OR REPLACE PACKAGE BODY BOLINF.XXSV_CARGA_INVOICES_PKG IS
 
 PROCEDURE XX_AR_INTERFACE  (P_ORG_ID                   NUMBER
                            ,P_BATCH_SOURCE             VARCHAR2
                            ,P_INTERFACE_LINE_CONTEXT   VARCHAR2
                            ,P_GL_DATE                  VARCHAR2
                            ,P_TRX_DATE                 VARCHAR2
                            ,P_GROUP_BY_CUSTOMER        VARCHAR2
                            ) IS

    g_gl_date date := sysdate;
    g_trx_date  date := sysdate;
     
 CURSOR C_DATOS IS
  select sum(dt.QUANTITY) QUANTITY
        ,sum(dt.AMOUNT) AMOUNT
        , sum(dt.AMOUNT)/sum(dt.QUANTITY) UNIT_SELLING_PRICE 
        ,ORIG_SYSTEM_BILL_CUSTOMER_REF
        ,CUST_TRX_TYPE_NAME
        ,decode( p_group_by_customer,'Y',  dt.LAST_INTERFACE_LINE_ATTRIBUTE1 , dt.INTERFACE_LINE_ATTRIBUTE1)  INTERFACE_LINE_ATTRIBUTE1
        ,decode( p_group_by_customer,'Y',  dt.LINE_NUMBER_RANK , dt.line_number )  line_number
        ,MEMO_LINE_NAME
        ,decode( p_group_by_customer,'Y', g_gl_date , dt.GL_DATE)  GL_DATE
        ,decode( p_group_by_customer,'Y', g_trx_date, dt.TRX_DATE) TRX_DATE
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
        ,AR.AMOUNT
        ,AR. UNIT_SELLING_PRICE 
        ,ORIG_SYSTEM_BILL_CUSTOMER_REF
        ,AR.INTERFACE_LINE_ATTRIBUTE1
        ,LAST_VALUE(AR.INTERFACE_LINE_ATTRIBUTE1)  OVER ( 
            PARTITION BY  ORIG_SYSTEM_BILL_CUSTOMER_REF ,AR.CUST_TRX_TYPE_NAME
                ORDER BY  ORIG_SYSTEM_BILL_CUSTOMER_REF ,AR.CUST_TRX_TYPE_NAME , AR.INTERFACE_LINE_ATTRIBUTE1
                 ROWS BETWEEN UNBOUNDED PRECEDING AND  UNBOUNDED FOLLOWING   ) AS LAST_INTERFACE_LINE_ATTRIBUTE1
        ,AR.CUST_TRX_TYPE_NAME   CUST_TRX_TYPE_NAME
        ,AR.MEMO_LINE_NAME
        ,LINE_NUMBER
       ,DENSE_RANK() OVER (
        PARTITION BY ORIG_SYSTEM_BILL_CUSTOMER_REF  ,AR.CUST_TRX_TYPE_NAME 
            ORDER BY ORIG_SYSTEM_BILL_CUSTOMER_REF  ,AR.CUST_TRX_TYPE_NAME ,AR.MEMO_LINE_NAME  ) LINE_NUMBER_RANK
        ,AR.CONVERSION_RATE
        ,AR.CONVERSION_TYPE
        ,AR.CURRENCY_CODE
          ,AR.GL_DATE
          ,AR.TRX_DATE
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
  WHERE NVL(STATUS,'C') in ('C', 'N') 
    AND ORG_ID                  = p_ORG_ID
    and BATCH_SOURCE_NAME       = p_Batch_Source
    and INTERFACE_LINE_CONTEXT  = p_interface_line_context
   ) dt
   group by 
        dt.ORIG_SYSTEM_BILL_CUSTOMER_REF
        ,dt.CUST_TRX_TYPE_NAME
        ,decode( p_group_by_customer,'Y',  dt.LAST_INTERFACE_LINE_ATTRIBUTE1 , dt.INTERFACE_LINE_ATTRIBUTE1)
        ,decode( p_group_by_customer,'Y',  dt.LINE_NUMBER_RANK , dt.line_number )
        ,MEMO_LINE_NAME 
        ,DT.CONVERSION_RATE
        ,DT.CONVERSION_TYPE
        ,DT.CURRENCY_CODE
        ,decode( p_group_by_customer,'Y', g_gl_date , dt.GL_DATE)
        ,decode( p_group_by_customer,'Y', g_trx_date, dt.TRX_DATE)
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
    


 INSERT_FLAG VARCHAR2(1);
 C_Line          Varchar2(4000);
  C_Del           Varchar2(1) := '|';
 
 P_USER_ID number;
 
 L_LINE_SECUENCE NUMBER;
 V_INTERFACE_LINE_ATTRIBUTE3 NUMBER;
 L_GL_LINE_SECUENCE NUMBER;
 VCONTA NUMBER;
 VFLAG VARCHAR2(20);  


 REQUEST NUMBER;
 VPHASE_CODE APPS.FND_CONCURRENT_REQUESTS.PHASE_CODE%TYPE;
 VSTATUS_CODE APPS.FND_CONCURRENT_REQUESTS.STATUS_CODE%TYPE;
 VTEXT APPS.FND_CONCURRENT_REQUESTS.COMPLETION_TEXT%TYPE;
 
 RETCODE varchar2(30);
 ERRBUF  varchar2(300);
BEGIN
 RETCODE := '0';
 
 VCONTA := 0;
 VFLAG := 'INI FOR';
  INSERT_FLAG := 'Y';

    fnd_file.put_line(fnd_file.log,'Begin Process');
    fnd_file.put_line(fnd_file.log,'P_Org_Id                 '||P_Org_Id);
    fnd_file.put_line(fnd_file.log,'P_Batch_Source           '||P_Batch_Source);
    fnd_file.put_line(fnd_file.log,'p_interface_line_context '||p_interface_line_context);
    fnd_file.put_line(fnd_file.log,'p_gl_date                '||p_gl_date);
    fnd_file.put_line(fnd_file.log,'p_trx_date               '||p_trx_date);
    fnd_file.put_line(fnd_file.log,'p_group_by_custome       '||p_group_by_customer);
    
 
     begin
        g_gl_date       := to_date(p_gl_date    ,fnd_date.canonical_DT_mask);
        g_trx_date  := to_date(p_trx_date   ,fnd_date.canonical_DT_mask);
    exception when others then
        fnd_file.put_line(fnd_file.output,'Error while Date Conversion');
    end;    
    



    FOR I IN C_DATOS  LOOP
     -- 
     
        IF INSERT_FLAG = 'Y' THEN

            VCONTA := VCONTA + 1;

            SELECT APPS.RA_CUSTOMER_TRX_LINES_S.NEXTVAL 
              INTO L_LINE_SECUENCE
              FROM DUAL;
              
            SELECT BOLINF.XXSV_CARGA_AR_INV_CONVIVA_S.NEXTVAL 
              INTO V_INTERFACE_LINE_ATTRIBUTE3
              FROM DUAL;
            
            INSERT INTO XXSV_COMVIVA_RA_INTERFACE (
                 STATUS
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
                ) 
             VALUES (   
                 'S'
                ,L_LINE_SECUENCE
                ,I.INTERFACE_LINE_CONTEXT
                ,I.INTERFACE_LINE_ATTRIBUTE1 
                ,I.CUST_TRX_TYPE_NAME -- I.INTERFACE_LINE_ATTRIBUTE2
                ,V_INTERFACE_LINE_ATTRIBUTE3 -- I.INTERFACE_LINE_ATTRIBUTE3
                ,I.BATCH_SOURCE_NAME
                ,I.SET_OF_BOOKS_ID
                ,I.LINE_TYPE
                ,I.DESCRIPTION
                ,I.CURRENCY_CODE
                ,I.AMOUNT
                ,I.CUST_TRX_TYPE_NAME
                ,I.TERM_NAME
                ,I.ORIG_SYSTEM_BILL_CUSTOMER_REF
                ,I.ORIG_SYSTEM_BILL_ADDRESS_REF
                ,I.LINK_TO_LINE_CONTEXT         
                ,I.CONVERSION_TYPE
                ,I.CONVERSION_RATE
                ,I.TRX_DATE   
                ,I.GL_DATE
                ,I.QUANTITY
                ,I.UNIT_SELLING_PRICE
                ,I.PRINTING_OPTION
                ,I.TAX_CODE
                ,I.MEMO_LINE_NAME                                         
                ,I.PRIMARY_SALESREP_ID
                ,I.UOM_CODE                                                
                ,P_USER_ID
                ,SYSDATE
                ,P_ORG_ID 
                );
                                                                                          
        END IF;

    END LOOP;
 
    VFLAG := 'UPDATE STATUS';   
 

    UPDATE XXSV_CARGA_ARINVOICES_CONVIVA 
       SET STATUS = 'P'
     WHERE NVL(STATUS,'C') in ('C', 'N') 
       AND ORG_ID                  = p_ORG_ID
       and BATCH_SOURCE_NAME       = p_Batch_Source
       and INTERFACE_LINE_CONTEXT  = p_interface_line_context
    ;
    COMMIT;

    VFLAG := 'REQUEST';
    /*

    */
    
EXCEPTION
  WHEN OTHERS THEN
       --   
       RETCODE := '2';
       ERRBUF  := 'AR_INTERFACE: '||VFLAG||' '||SQLERRM;
       ROLLBACK;       
       --
END XX_AR_INTERFACE;


 procedure AR_INTERFACE_STAGGING
                            (P_ORG_ID                   NUMBER
                            ,P_BATCH_SOURCE             VARCHAR2
                            ,P_INTERFACE_LINE_CONTEXT   VARCHAR2
                            ,P_GL_DATE                  VARCHAR2
                            ,P_TRX_DATE                 VARCHAR2
                            ,P_GROUP_BY_CUSTOMER        VARCHAR2
                            ) IS
                            
 begin
    update XXSV_COMVIVA_RA_INTERFACE tr
    set status = 'P'
    where tr.ORG_ID                    = P_ORG_ID
       and tr.BATCH_SOURCE_NAME         = P_BATCH_SOURCE
       and tr.INTERFACE_LINE_CONTEXT    = P_INTERFACE_LINE_CONTEXT
    and         status = 'S'
    ;
    commit;

 end;

 PROCEDURE AR_TRANSFER_INTERFACE
    (P_PROCESS_TYPE             varchar2
    ,P_ORG_ID                   Number
    ,P_BATCH_SOURCE             Varchar2
    ,P_INTERFACE_LINE_CONTEXT   varchar2
    ,P_GL_DATE_INI              varchar2
    ,P_GL_DATE_FIN              varchar2
    ,P_TRX_DATE_INI             varchar2
    ,P_TRX_DATE_FIN             varchar2
    ,P_CUSTOMER_ACCOUNT         varchar2
    ,P_TRX_NUMBER               varchar2
    ,P_User_Id                  Number
    ,p_resp_id                  Number
    )
     is
    
 cursor c_data is
    select tr.rowid, tr.* 
      from XXSV_COMVIVA_RA_INTERFACE tr
     where tr.ORG_ID                    = P_ORG_ID
       and tr.BATCH_SOURCE_NAME         = P_BATCH_SOURCE
       and tr.INTERFACE_LINE_CONTEXT    = P_INTERFACE_LINE_CONTEXT
       and tr.gl_date   between nvl(to_date(P_GL_DATE_INI   , 'YYYY/MM/DD HH24:MI:SS'),tr.gl_date)
                            and nvl(to_date(P_GL_DATE_FIN   , 'YYYY/MM/DD HH24:MI:SS'),tr.gl_date)
       and tr.trx_DATE  between nvl(to_date(P_TRX_DATE_INI  , 'YYYY/MM/DD HH24:MI:SS'),tr.trx_DATE)
                            and nvl(to_date(P_TRX_DATE_FIN  , 'YYYY/MM/DD HH24:MI:SS'),tr.trx_DATE)
       and tr.ORIG_SYSTEM_BILL_CUSTOMER_REF  = nvl(P_CUSTOMER_ACCOUNT,tr.ORIG_SYSTEM_BILL_CUSTOMER_REF)
       and tr.INTERFACE_LINE_ATTRIBUTE1      = nvl(P_TRX_NUMBER,tr.INTERFACE_LINE_ATTRIBUTE1)
       and decode(P_PROCESS_TYPE ,'DISCARD' ,  decode( STATUS, null, 'P', 'E' , 'P', STATUS  ) , 'TRANSFER' , nvl( STATUS,'N')  ) = 'P'
      ;
      
      v_user_id number;
      v_user_name varchar2(50);
      L_REQUEST_ID NUMBER;
       V_BATCH_SOURCE_ID NUMBER;
-- P_USER_NAME VARCHAR2(100);
      
 begin
    
    v_user_id := p_user_id;
    
        fnd_file.put_line(fnd_file.log,'Begin Process');
    
    fnd_file.put_line(fnd_file.log,'P_Org_Id                 '||P_Org_Id);
    --fnd_file.put_line(fnd_file.log,'P_User_Id                '||P_User_Id);
    --fnd_file.put_line(fnd_file.log,'p_resp_id                '||p_resp_id);
    fnd_file.put_line(fnd_file.log,'P_Batch_Source           '||P_Batch_Source);
    fnd_file.put_line(fnd_file.log,'p_interface_line_context '||p_interface_line_context);
    
        BEGIN
        SELECT USER_NAME, user_id
          INTO v_user_name,v_user_id
          FROM FND_USER
         WHERE USER_ID = p_user_id; 
    END;
    
        BEGIN
        SELECT BATCH_SOURCE_ID
          INTO V_BATCH_SOURCE_ID      
          FROM APPS.RA_BATCH_SOURCES_ALL
         WHERE ORG_ID = P_ORG_ID
           AND NAME = P_Batch_Source;

    EXCEPTION 
       WHEN OTHERS THEN

            ROLLBACK;    
    END;
    
--    UPDATE XXSV_COMVIVA_RA_INTERFACE inter
--                  SET inter.status = 'D'
--                  where status not in ('I')
--             ;     
--             commit;
    
    if  P_PROCESS_TYPE = 'TRANSFER' then
        
        for I in c_data loop
            
         INSERT INTO RA_INTERFACE_LINES_ALL (
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
            ) 
         VALUES (   
             I.INTERFACE_LINE_ID
            ,I.INTERFACE_LINE_CONTEXT
            ,I.INTERFACE_LINE_ATTRIBUTE1 
            ,I.INTERFACE_LINE_ATTRIBUTE2
            ,I.INTERFACE_LINE_ATTRIBUTE3
            ,I.BATCH_SOURCE_NAME
            ,I.SET_OF_BOOKS_ID
            ,I.LINE_TYPE
            ,I.DESCRIPTION
            ,I.CURRENCY_CODE
            ,I.AMOUNT
            ,I.CUST_TRX_TYPE_NAME
            ,I.TERM_NAME
            ,I.ORIG_SYSTEM_BILL_CUSTOMER_REF
            ,I.ORIG_SYSTEM_BILL_ADDRESS_REF
            ,I.LINK_TO_LINE_CONTEXT         
            ,I.CONVERSION_TYPE
            ,I.CONVERSION_RATE
            ,I.TRX_DATE   
            ,I.GL_DATE
            ,I.QUANTITY
            ,I.UNIT_SELLING_PRICE
            ,I.PRINTING_OPTION
            ,I.TAX_CODE
            ,I.MEMO_LINE_NAME                                         
            ,I.PRIMARY_SALESREP_ID
            ,I.UOM_CODE                                                
            ,v_user_id
            ,SYSDATE
            ,P_ORG_ID 
            );
            
            INSERT INTO RA_INTERFACE_SALESCREDITS_ALL
                    ( SALES_CREDIT_PERCENT_SPLIT,
                     SALES_CREDIT_TYPE_ID,
                     ORG_ID,
                     SALESREP_NUMBER,
                     INTERFACE_LINE_CONTEXT,
                     INTERFACE_LINE_ATTRIBUTE1,
                     INTERFACE_LINE_ATTRIBUTE2,
                     INTERFACE_LINE_ATTRIBUTE3,
                     CREATION_DATE
                    )
            VALUES ( 
                '100',
                1,
                P_ORG_ID,
                v_user_name,
                I.INTERFACE_LINE_CONTEXT,
                I.INTERFACE_LINE_ATTRIBUTE1,
                I.CUST_TRX_TYPE_NAME, 
                I.INTERFACE_LINE_ATTRIBUTE3, --I.INTERFACE_LINE_ATTRIBUTE3,
             SYSDATE );    
            
            UPDATE XXSV_COMVIVA_RA_INTERFACE inter
              SET inter.status = 'I'
              WHERE inter.rowid = i.rowid
               ;
            
        end loop;
        commit;
        
        begin
            L_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST(
                             'AR',
                             'RAXMTR',
                             '',
                             '',
                             FALSE,     
                             '1',
                             P_ORG_ID,
                             V_BATCH_SOURCE_ID, 
                             P_Batch_Source,
                             to_char(SYSDATE,fnd_date.canonical_DT_mask ),--arg5
                             '','','','','','' ,'','','','', --arg15
                             '','','','','','' ,'','','','', --arg25
                             'Y','',CHR(0)         --arg28
                             );
            COMMIT;
        END;
        
    elsif P_PROCESS_TYPE = 'DISCARD' then
        begin
            for I in c_data loop
                                              
                UPDATE XXSV_COMVIVA_RA_INTERFACE inter
                  SET inter.status = 'D'
                WHERE inter.rowid = I.rowid
                    ;
                    
            end loop; 
            
             UPDATE XXSV_COMVIVA_RA_INTERFACE inter
                  SET inter.status = 'D'
                  where status not in ('I')
             ;     
             commit;
        end;
        
    end if;
 exception
    when others then
        rollback;
 end AR_TRANSFER_INTERFACE;

PROCEDURE XX_AP_INTERFACE  
    (P_Org_Id               Number
    ,P_User_Id              Number
    ,p_resp_id              Number
    ,P_Source               Varchar2
    ,p_gl_date              varchar2
    ,p_trx_date             varchar2
    ,p_group_by_supplier    varchar2
    ) IS

    g_gl_date date := sysdate;
    g_invoice_date  date := sysdate;
    g_invoice_num varchar2(35);
    
 CURSOR C_DATA_H IS
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
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', g_invoice_num   ,INVOICE_NUM)         INVOICE_NUM     --+ 20 # P 
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', g_invoice_date  ,INVOICE_DATE)        INVOICE_DATE    --+ 21 # P
       ,SUM(AMOUNT_LINE)                                                      INVOICE_AMOUNT_CALC
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', 0                ,INVOICE_AMOUNT)     INVOICE_AMOUNT  --+ 22     C
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', DESCRIPTION     ,DESCRIPTION)         DESCRIPTION     --+ 23 #   C
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', G_GL_DATE       ,GL_DATE)             GL_DATE         --+ 24 #
  FROM XXSV_CARGA_APINVOICES ivh
 WHERE ivh.ORG_ID = P_ORG_ID
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
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', g_invoice_num   ,INVOICE_NUM)
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', g_invoice_date  ,INVOICE_DATE)
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', 0               ,INVOICE_AMOUNT)
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', DESCRIPTION     ,DESCRIPTION)
       ,DECODE(P_GROUP_BY_SUPPLIER,'Y', G_GL_DATE       ,GL_DATE)
       )
   order by VENDOR_NUM, VENDOR_SITE_CODE, INVOICE_NUM;




     CURSOR C_DATA_L (      p_SOURCE                        varchar2
                           ,p_INVOICE_TYPE_LOOKUP_CODE      varchar2
                           ,p_INVOICE_CURRENCY_CODE         varchar2
                           ,p_VENDOR_NUM                    varchar2
                           ,p_VENDOR_SITE_CODE              varchar2
                           ,p_ORG_ID                        varchar2
                           ,p_INVOICE_NUM                   varchar2    
                           ,p_INVOICE_DATE                  date        
                        ) IS
       select apd.LINE_TYPE_LOOKUP_CODE
        ,sum(apd.AMOUNT_LINE) AMOUNT_LINE
        ,DECODE(P_GROUP_BY_SUPPLIER,'Y', LAST_DESCRIPTION_LINE  , DESCRIPTION_LINE)  DESCRIPTION_LINE
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
       and SOURCE                      = p_SOURCE
       and ORG_ID                      = p_ORG_ID
       and INVOICE_TYPE_LOOKUP_CODE    = p_INVOICE_TYPE_LOOKUP_CODE
       and INVOICE_CURRENCY_CODE       = p_INVOICE_CURRENCY_CODE
       and VENDOR_NUM                  = p_VENDOR_NUM
       and VENDOR_SITE_CODE            = p_VENDOR_SITE_CODE
       and DECODE(P_GROUP_BY_SUPPLIER,'Y', g_invoice_num   ,INVOICE_NUM)  = p_INVOICE_NUM
       and DECODE(P_GROUP_BY_SUPPLIER,'Y', g_invoice_date  ,INVOICE_DATE) = p_INVOICE_DATE
      ) apd
  group by 
        (LINE_TYPE_LOOKUP_CODE
        ,DECODE(P_GROUP_BY_SUPPLIER,'Y', LAST_DESCRIPTION_LINE  , DESCRIPTION_LINE)
        ,DIST_CODE_CONCATENATED
        ,LINE_NUMBER
        ,TAX_CODE
        ,TAX    
        ,CALC_TAX_DURING_IMPORT_FLAG
        )
       ;   


    
   
    --+ Calculated
    V_Vendor_Name   Varchar2(240);
    V_Vendor_Id     Number;
    V_Heder_Count   Number;
    V_Line_Count    Number;
    v_line_number   number;
    V_Sum_Line      Number;
    V_Invoice_Num   varchar2(50);
    V_Gl_Date       Date;
    V_Invoice_Date  Date;
    V_Line_Desc     Varchar2(5);
    
    --+ Flags
    ID_FACTURA      NUMBER;
    vUser_Id        NUMBER;
    Vresponsibility_Id NUMBER;
    NOM_BATCH       VARCHAR2(250);
    REQUEST         NUMBER;
    VFLAG           VARCHAR2(250);
    VPHASE_CODE     VARCHAR2(1);
    VSTATUS_CODE    VARCHAR2(1);
    EXISTE_BATCH    NUMBER;
    
    -- 
BEGIN

  

    begin
    g_gl_date := to_date(p_gl_date,fnd_date.canonical_DT_mask);
    g_invoice_date := to_date(p_trx_date,fnd_date.canonical_DT_mask);
    g_invoice_num := to_char(sysdate,'YYYYMMDD-HH24:MI:SS');
    exception when others then
        fnd_file.put_line(fnd_file.output,'Error while Date Conversion');
    end;
    
    BEGIN


        v_heder_count := 0;
        

        FOR K IN C_DATA_H LOOP
            

            v_heder_count := v_heder_count +1;
            fnd_file.put_line(fnd_file.log, 'HEADER '||v_heder_count  );
            
            BEGIN 
               SELECT sp.VENDOR_NAME,
                      sp.VENDOR_ID
                 INTO V_VENDOR_NAME,
                      V_VENDOR_ID    
                 FROM apps.ap_suppliers sp,
                      apps.ap_supplier_SITES_ALL SS
                WHERE sp.VENDOR_ID = ss.VENDOR_ID
                  AND ss.ORG_ID = P_ORG_ID
                  AND ss.VENDOR_SITE_CODE= K.VENDOR_SITE_CODE
                  and sp.segment1 = k.VENDOR_NUM;
                  
                  fnd_file.put_line(fnd_file.log, 'V_VENDOR_NAME '||V_VENDOR_NAME  );
            EXCEPTION 
              WHEN OTHERS THEN
                   V_VENDOR_NAME := NULL;
            END;
            
            
            if    V_VENDOR_NAME is not null then 
                
                begin
                    
                    if p_group_by_supplier = 'Y' then
                        v_sum_line          := k.INVOICE_AMOUNT_CALC;                      
                        V_Invoice_Num       := G_Invoice_Num;
                        V_Gl_Date           := G_Gl_Date;
                        V_Invoice_Date      := G_Invoice_Date;
                    else
                        V_Sum_Line          := K.Invoice_Amount;
                        V_Invoice_Num       := K.Invoice_Num;
                        V_Gl_Date           := K.Gl_Date;
                        V_Invoice_Date      := K.Invoice_Date;
                    end if;
                    
                exception when others then
                    fnd_file.put_line(fnd_file.log, 'error while Computing Sum of lines '||sqlerrm );
                end;
                
             -- INCREMENTA EN UNO LA SECUENCIA
             SELECT AP_INVOICES_S.NEXTVAL 
               INTO ID_FACTURA
               FROM DUAL;
             --

                
             INSERT INTO XXSV_COMVIVA_AP_INVOICES
                                   (SOURCE                      --+ 1
                                   ,INVOICE_TYPE_LOOKUP_CODE    --+ 2
                                   ,INVOICE_NUM                 --+ 3
                                   ,INVOICE_DATE                --+ 4
                                   ,GL_DATE                     --+ 5
                                   ,VENDOR_ID                   --+ 6
                                   ,vendor_num                  --+ Solo es de referencia
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
                                   ,STATUS
                                   )
                           VALUES  (K.SOURCE                    --+ 1
                                   ,K.INVOICE_TYPE_LOOKUP_CODE  --+ 2
                                   ,K.INVOICE_NUM               --+ 3
                                   ,v_invoice_date              --+ 4*
                                   ,V_Gl_Date                   --+ 5*
                                   ,V_VENDOR_ID                 --+ 6*
                                   ,k.VENDOR_NUM                --+ Solo es de referencia
                                   ,V_VENDOR_NAME               --+ 7*
                                   ,K.VENDOR_SITE_CODE          --+ 8
                                   ,v_sum_line                  --+ 9*
                                   ,K.INVOICE_CURRENCY_CODE     --+ 10
                                   ,K.EXCHANGE_RATE_TYPE        --+ 11
                                   ,K.EXCHANGE_RATE             --+ 12
                                   ,K.EXCHANGE_DATE             --+ 13
                                   ,K.DESCRIPTION               --+ 14
                                   ,K.ORG_ID                    --+ 15
                                   ,ID_FACTURA                  --+ 16*
                                   ,K.INVOICE_DATE              --+ 17
                                   ,K.CALC_TAX_DURING_IMPORT_FLAG
                                   ,'S'
                                    ); 
                              

                v_line_count := 0;
                
                FOR J IN C_DATA_L (     k.SOURCE
                                       ,k.INVOICE_TYPE_LOOKUP_CODE      
                                       ,k.INVOICE_CURRENCY_CODE         
                                       ,k.VENDOR_NUM                    
                                       ,k.VENDOR_SITE_CODE              
                                       ,k.ORG_ID                        
                                       ,k.INVOICE_NUM                   
                                       ,k.INVOICE_DATE) 
                LOOP
                   v_line_count := v_line_count + 1;
                    
                    if p_group_by_supplier = 'Y' then
                        v_line_number   := v_line_count;
                    else
                        v_line_number   := J.LINE_NUMBER;
                    end if;
                    
                 INSERT INTO XXSV_COMVIVA_AP_INVOICE_LINES --+ 
                            ( LINE_TYPE_LOOKUP_CODE     --+ 1
                             ,AMOUNT                    --+ 2
                             ,DESCRIPTION               --+ 3
                             ,DIST_CODE_CONCATENATED    --+ 4
                             ,LINE_NUMBER               --+ 5
                             ,ACCOUNTING_DATE           --+ 6
                             ,INVOICE_ID                --+ 7
                             ,TAX_CODE                  --+ 8
                             ,TAX
                             ,STATUS
                             ) 
                     VALUES  (J.LINE_TYPE_LOOKUP_CODE   --+ 1
                             ,J.AMOUNT_LINE             --+ 2
                             ,J.DESCRIPTION_LINE        --+ 3
                             ,J.DIST_CODE_CONCATENATED  --+ 4
                             ,v_line_number             --+ 5
                             ,K.GL_DATE                 --+ 6
                             ,ID_FACTURA                --+ 7
                             ,j.TAX_CODE
                             ,j.TAX  
                             ,'S'  
                             );


                    COMMIT;
                     
                END LOOP;
                
            end if;
            
           
            
        END LOOP;
        
                            
        UPDATE XXSV_CARGA_APINVOICES inv
           SET inv.STATUS   = 'P'
         WHERE SOURCE       = p_SOURCE
           and ORG_ID       = p_ORG_ID
           and nvl(inv.STATUS,'N') = 'N'
           ;

        COMMIT;


     
    EXCEPTION WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.output,'EXCEPCION IMPORTING TO INTERFACE '|| SQLERRM);
    END;

     /*
     SELECT MIN(A.Responsibility_Id) 
       INTO Vresponsibility_Id
       FROM Fnd_User_Resp_Groups A, 
            Fnd_Responsibility_Tl C,
            Fnd_Profile_Options_Vl D, 
            Fnd_Profile_Option_Values E
      WHERE A.Responsibility_Id = C.Responsibility_Id
        AND A.Responsibility_Id = E.Level_Value
        AND E.Profile_Option_Id = D.Profile_Option_Id
        AND A.Responsibility_Application_Id = 200-- Codigo De Aplicacion 
        AND E.Profile_Option_Value = (SELECT H.ORGANIZATION_ID
                                        FROM HR_OPERATING_UNITS H 
                                       WHERE H.ORGANIZATION_ID = P_ORG_ID )  --Nombre Libro
        AND D.Profile_Option_Name = 'ORG_ID'
        AND TO_CHAR(A.END_DATE,'DD/MM/YYYY') = '01/01/9999';*/
     --
     --FND_GLOBAL.APPS_INITIALIZE(2961, Vresponsibility_Id, 200);

       /*
        
        if p_raise_Interface = 'Y' then
            
            begin
                vUser_Id  := fnd_global.USER_ID;
                NOM_BATCH := nvl(NOM_BATCH,SUBSTR('INVOICE UPLOAD' ||'-' ||TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS'),1,30));


                --+`346, INVOICE_UPLOAD, , INVOICE UPLOAD-20140619 17:31:, , , , N, N, N, N, 1000, 10585, -1
                REQUEST := FND_REQUEST.SUBMIT_REQUEST ('SQLAP',
                                                    'APXIIMPT',
                                                    '',
                                                    '',
                                                    FALSE,
                                                    P_ORG_ID,
                                                    P_Source,
                                                    '',
                                                    p_batch_name,
                                                    '',
                                                    '',
                                                    '',--GL_DATE
                                                    'N',
                                                    'N', 
                                                    'N', 
                                                    'N',
                                                    '1000', 
                                                    vUser_Id, 
                                                    '-1', 
                                                    CHR(0)
                                                    );

                COMMIT;
            -- LOOP PARA ESPERAR QUE FINALICE EL REQUEST
            --    LOOP
            --       --
            --       -- TIMER
            --       DBMS_LOCK.sleep(10);
            --       --
            --       SELECT PHASE_CODE,
            --              STATUS_CODE  
            --         INTO VPHASE_CODE,
            --              VSTATUS_CODE
            --         FROM FND_CONCURRENT_REQUESTS
            --        WHERE REQUEST_ID = REQUEST;
            --       --
            --       EXIT WHEN VPHASE_CODE = 'C';        
            --    END LOOP;
            --
                IF VSTATUS_CODE IN ('G','E') THEN
                 VFLAG := 'EL REQUEST NUMERO ' || TO_CHAR(REQUEST) || ' FINALIZO CON ERROR';
                END IF;

            EXCEPTION WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.output,'EXCEPCION SUBMITTING RECUEST '|| SQLERRM);
            END;
        end if;
        */
            
END;


   PROCEDURE AP_PROCESS_STAGGING
    (P_PROCESS_TYPE         varchar2
    ,P_Org_Id               Number
    ,P_User_Id              Number
    ,p_resp_id              Number
    ,P_Source               Varchar2
    ) is
    
 cursor c_header is
 select iv.rowid, iv.*
   from XXSV_COMVIVA_AP_INVOICES iv
  where status = 'P'
    and org_id = P_Org_Id
    and source = P_Source
    ;
    
    cursor c_lines is 
    select ivl.rowid, ivl.*
    from XXSV_COMVIVA_AP_INVOICE_LINES ivl
    where status = 'P'
      and exists (  select null
                      from XXSV_COMVIVA_AP_INVOICES iv
                     where iv.invoice_id = ivl.invoice_id  
                       and iv.org_id = P_Org_Id
                       and iv.source = P_Source
                 )
                 ;
         
 
    
 begin
     if P_PROCESS_TYPE = 'IMPORT' then
         begin
            
            update XXSV_COMVIVA_AP_INVOICE_LINES ivl 
               set ivl.status = 'P'
             where ivl.status = 'S'
               and exists (  select null
                              from XXSV_COMVIVA_AP_INVOICES iv
                             where iv.invoice_id = ivl.invoice_id  
                               and iv.org_id = P_Org_Id
                               and iv.source = P_Source
                               and iv.status = 'S'
                             )
                             ;
                             
             update XXSV_COMVIVA_AP_INVOICES
                set status = 'P'
              where status = 'S'
                and org_id = P_Org_Id
                and source = P_Source
                ;
         end;
      
     elsif P_PROCESS_TYPE = 'TRANSFER' then
        
        for I in c_header loop
            
            insert into AP_INVOICES_INTERFACE
               (SOURCE                      --+ 1
               ,INVOICE_TYPE_LOOKUP_CODE    --+ 2
               ,INVOICE_NUM                 --+ 3
               ,INVOICE_DATE                --+ 4
               ,GL_DATE                     --+ 5
               ,VENDOR_ID                   --+ 6
               ,vendor_num                  --+ Solo es de referencia
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
               )
              values
              ( I.SOURCE                      --+ 1
               ,I.INVOICE_TYPE_LOOKUP_CODE    --+ 2
               ,I.INVOICE_NUM                 --+ 3
               ,I.INVOICE_DATE                --+ 4
               ,I.GL_DATE                     --+ 5
               ,I.VENDOR_ID                   --+ 6
               ,I.vendor_num                  --+ Solo es de referencia
               ,I.VENDOR_NAME                 --+ 7
               ,I.VENDOR_SITE_CODE            --+ 8
               ,I.INVOICE_AMOUNT              --+ 9
               ,I.INVOICE_CURRENCY_CODE       --+ 10
               ,I.EXCHANGE_RATE_TYPE          --+ 11
               ,I.EXCHANGE_RATE               --+ 12
               ,I.EXCHANGE_DATE               --+ 13
               ,I.DESCRIPTION                 --+ 14
               ,I.ORG_ID                      --+ 15
               ,I.INVOICE_ID                  --+ 16
               ,I.INVOICE_RECEIVED_DATE       --+ 17
               ,I.CALC_TAX_DURING_IMPORT_FLAG
               );
               
               update XXSV_COMVIVA_AP_INVOICES inv
               set status = 'I' 
               where inv.rowid = I.rowid
               ;
               
               
        end loop;                   
         
        for I in c_lines loop
            
            insert into XXSV_COMVIVA_AP_INVOICE_LINES
                    (LINE_TYPE_LOOKUP_CODE     --+ 1
                    ,AMOUNT                    --+ 2
                    ,DESCRIPTION               --+ 3
                    ,DIST_CODE_CONCATENATED    --+ 4
                    ,LINE_NUMBER               --+ 5
                    ,ACCOUNTING_DATE           --+ 6
                    ,INVOICE_ID                --+ 7
                    ,TAX_CODE                  --+ 8
                    ,TAX
                    ,STATUS
               )
              values
                 (I.LINE_TYPE_LOOKUP_CODE     --+ 1
                 ,I.AMOUNT                    --+ 2
                 ,I.DESCRIPTION               --+ 3
                 ,I.DIST_CODE_CONCATENATED    --+ 4
                 ,I.LINE_NUMBER               --+ 5
                 ,I.ACCOUNTING_DATE           --+ 6
                 ,I.INVOICE_ID                --+ 7
                 ,I.TAX_CODE                  --+ 8
                 ,I.TAX
                 ,I.STATUS
               );
              
               update XXSV_COMVIVA_AP_INVOICE_LINES inv
               set status = 'I' 
               where inv.rowid = I.rowid
               ;

               
        end loop; 
        
     end if;

 end;

-- XXSV INV KARDEX
PROCEDURE XXSV_MTL_KARDEX( ERRBUF OUT VARCHAR2,
                            RETCODE OUT VARCHAR2,
                            P_DATE1 VARCHAR2,
                            P_DATE2 VARCHAR2,
                            P_ITEMS_FROM VARCHAR2,
                            P_ITEMS_TO VARCHAR2,
                            P_ORG_ID VARCHAR2,
                            P_SUBINV VARCHAR2,
                            P_SEP VARCHAR2) IS
--+
-- Cursor obtiene CIA
 CURSOR C_CIA IS
   Select ATTRIBUTE7
   from apps.MTL_PARAMETERS_VIEW
   where organization_id=P_ORG_ID;
--+
-- Cursor principal de datos
--+
CURSOR C_DATOS IS
  Select ATTRIBUTE7,transaction_id,organization_id,name,subinventory_code, LOCATOR_ID, Item, item_id, description,transaction_date,
       TRANSACTION_TYPE_ID,TRANSACTION_TYPE_NAME,Documento,Saldo_inicial,Entradas,Salidas Salidas,
       (Saldo_inicial + Entradas) + Salidas Saldo_Final ,
       TRANSACTION_COST  TRANSACTION_COST,
       NEW_COST NEW_COST , RCV_TRANSACTION_ID
from
(Select mtt.ATTRIBUTE7,
        mtt.organization_id,
        mtt.transaction_id,
        hr.name,
        mtt.SUBINVENTORY_CODE,
        mtt.LOCATOR_ID,
        mit.segment1 item,
        mit.INVENTORY_ITEM_ID item_id,
        mit.description,
        mtt.transaction_date,
        mtt.TRANSACTION_TYPE_ID,
        mtl.TRANSACTION_TYPE_NAME,
        decode(mtt.TRANSACTION_TYPE_ID,18,ph.segment1,mtt.TRANSACTION_REFERENCE) Documento,
        0 Saldo_Inicial,
        nvl(Decode(sign(TRANSACTION_quantity),1,TRANSACTION_quantity,0),0) Entradas,
        nvl(Decode(sign(TRANSACTION_quantity),-1,TRANSACTION_quantity,0),0) Salidas,
        nvl(mtt.ACTUAL_COST,0)  TRANSACTION_COST,
        nvl(mtt.NEW_COST,0) NEW_COST,
        RCV_TRANSACTION_ID
   From apps.mtl_material_transactions mtt,
        apps.mtl_system_items_b        mit,
        apps.mtl_transaction_types     mtl,
        apps.hr_organization_units     hr,
        apps.po_headers_all            ph
  Where mtt.organization_id = mit.organization_id(+)
    And mtt.inventory_item_id = mit.inventory_item_id(+)
    And mtt.TRANSACTION_TYPE_ID = mtl.TRANSACTION_TYPE_ID(+)
    And mtt.organization_id = hr.organization_id(+)
    And mtt.TRANSACTION_SOURCE_ID = ph.po_header_id(+)
    And mtt.organization_id   = P_ORG_ID
    And NVL(mtt.transaction_reference,'XXXXX') != 'CARGA INICIAL'
    --And MTT.TRANSACTION_DATE >= SIMAC_FUNCIONES_VARIAS.CONVIERTE_FECHA_IDIOMA(USERENV('LANG'), P_DATE1,'DD-MON-YYYY')
    --And MTT.TRANSACTION_DATE <= SIMAC_FUNCIONES_VARIAS.CONVIERTE_FECHA_IDIOMA(USERENV('LANG'), P_DATE2,'DD-MON-YYYY')
    And mtt.inventory_item_id in
        (Select inventory_item_id
           From apps.mtl_system_items_b
          Where segment1 BETWEEN P_ITEMS_FROM AND P_ITEMS_TO
            And organization_id= P_ORG_ID)
            And   mtt.SUBINVENTORY_CODE = nvl(P_SUBINV,mtt.SUBINVENTORY_CODE)
Union
Select Min(mtt.ATTRIBUTE7),
       mtt.organization_id,
       Min(mtt.transaction_id),
       hr.name,
       mtt.SUBINVENTORY_CODE,
       mtt.LOCATOR_ID,
       mit.segment1 item,
       mit.INVENTORY_ITEM_ID item_id,
       mit.description,
       mtt.transaction_date,
       Max(mtt.TRANSACTION_TYPE_ID),
       Max(mtl.TRANSACTION_TYPE_NAME),
       decode(mtt.TRANSACTION_TYPE_ID,18,ph.segment1,mtt.TRANSACTION_REFERENCE) Documento,
       0 Saldo_Inicial,
      Sum( nvl(Decode(sign(TRANSACTION_quantity),1,TRANSACTION_quantity,0),0)) Entradas,
      Sum(nvl(Decode(sign(TRANSACTION_quantity),-1,TRANSACTION_quantity,0),0)) Salidas,
      nvl(mtt.ACTUAL_COST,0)  TRANSACTION_COST,
      mtt.NEW_COST,
      RCV_TRANSACTION_ID
 From apps.mtl_material_transactions mtt,
      apps.mtl_system_items_b        mit,
      apps.mtl_transaction_types     mtl,
      apps.hr_organization_units     hr,
      apps.po_headers_all            ph
where mtt.organization_id = mit.organization_id(+)
  And mtt.inventory_item_id = mit.inventory_item_id(+)
  And mtt.TRANSACTION_TYPE_ID = mtl.TRANSACTION_TYPE_ID(+)
  And mtt.organization_id = hr.organization_id(+)
  And mtt.TRANSACTION_SOURCE_ID = ph.po_header_id(+)
  And mtt.organization_id   = P_ORG_ID
  And mtt.transaction_reference = 'CARGA INICIAL'
  --And MTT.TRANSACTION_DATE >= SIMAC_FUNCIONES_VARIAS.CONVIERTE_FECHA_IDIOMA(USERENV('LANG'), P_DATE1,'DD-MON-YYYY')
  --And MTT.TRANSACTION_DATE <= SIMAC_FUNCIONES_VARIAS.CONVIERTE_FECHA_IDIOMA(USERENV('LANG'), P_DATE2,'DD-MON-YYYY')
  and mtt.inventory_item_id in
      (Select inventory_item_id
         From apps.mtl_system_items_b
        Where segment1 BETWEEN P_ITEMS_FROM AND P_ITEMS_TO
          And organization_id= P_ORG_ID)
          And mtt.SUBINVENTORY_CODE = nvl(P_SUBINV,mtt.SUBINVENTORY_CODE)
 Group by mtt.organization_id,
       hr.name,
       mtt.SUBINVENTORY_CODE,
       mtt.LOCATOR_ID,
       mit.segment1 ,
       mit.INVENTORY_ITEM_ID ,
       mit.description,
       mtt.transaction_date,
       decode(mtt.TRANSACTION_TYPE_ID,18,ph.segment1,mtt.TRANSACTION_REFERENCE),
       nvl(mtt.ACTUAL_COST,0),
       mtt.NEW_COST,
       RCV_TRANSACTION_ID
order by 1 )
order by transaction_date, 1, 2;
--
--+
Cursor cExistencia (pITEM_ID IN APPS.MTL_MATERIAL_TRANSACTIONS.INVENTORY_ITEM_ID%TYPE,
                      PFECHA in varchar2 ) Is
SELECT NVL(SUM(A.TRANSACTION_QUANTITY),0)
  FROM APPS.MTL_MATERIAL_TRANSACTIONS A
 WHERE INVENTORY_ITEM_ID = pITEM_ID
   AND ORGANIZATION_ID = p_Org_Id
   AND SUBINVENTORY_CODE = NVL(P_SUBINV,SUBINVENTORY_CODE);
   --And TRUNC(TRANSACTION_DATE) >= SIMAC_FUNCIONES_VARIAS.CONVIERTE_FECHA_IDIOMA(USERENV('LANG'), '01-JAN-1999','DD-MON-YYYY')
   --And TRUNC(TRANSACTION_DATE) <= SIMAC_FUNCIONES_VARIAS.CONVIERTE_FECHA_IDIOMA(USERENV('LANG'), PFECHA,'DD-MON-YYYY');
--
sal_in number(10):=0;
--sal_final number(10):=0;
cont number(10):=0;
--
vSaldo_Ini   Number:=0;
vTransaction Number:=0;
----------------
sal_final number:=0;
----------------
vCost_ret Number:=0;
vCost_New Number;
vRetaceo varchar2(50);
vVarRetaceo Number;
---------------------
vcompany_name varchar2(100);
vLinea varchar2(3000);
vLenguaje varchar2(25);
vdebug varchar2(150);
--------------------
cp_retaceo_unitario number:=0;
cp_costo_final        number:=0;
cf_saldo_Inicial    number:=0;
cp_valor_salida        number:=0;
cf_saldo_final        number:=0;
cp_valor_final        number:=0;
CP_saldo_inicial     number:=0;
cp_costo_retaceo     number:=0;
-----------------
cp_subinv varchar2(40);
---
vfecha_d date;
vfecha_c varchar2(15);
--
BEGIN
  VLenguaje:=USERENV('LANG');
--*
-- Obtiene el nombre de la compañia
  OPEN C_CIA;
  FETCH C_CIA into vcompany_name;
  IF C_CIA%NOTFOUND Then
     vcompany_name:=null;
  END IF;
  CLOSE C_CIA;
 --
  vdebug:='Inserta Lineas de encabezado del reporte';
  --Inserta el nombre de la compañia
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vcompany_name);
  -- Inserta Lineas de encabezado del reporte
  IF vLenguaje='US' Then
       vLinea :='Kardex Inventory Report';
       if P_SUBINV is null then
          vLinea:= vLinea||' by Organization';
       else
          vLinea:= vLinea||' by Sub Inventory';
       end if;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vLinea);
       --*
       vLinea :='Period from '||P_DATE1||' to '||P_DATE2;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vLinea);
       --*
       vLinea := 'Organization'||P_SEP||'Item'||P_SEP||'Item Name'||P_SEP||'Trans Date'||P_SEP||'Store'||P_SEP||'Transaction Code'||P_SEP||'Document'||P_SEP;
       vLinea := vLinea||'Transac Cost'||P_SEP||'Posterior Cost'||P_SEP||'Retaceo Cost'||P_SEP||'Retaceo Var'||P_SEP||'Final Cost'||P_SEP||'Begin Balance'||P_SEP||'Inputs'||P_SEP||'Outputs'||P_SEP||'Transac Value'||P_SEP||'Final Balance'||P_SEP||'Value Balance'||P_SEP;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vLinea);
       --*
  ELSE
       vLinea :='Reporte de Kardex de Inventario';
              if P_SUBINV is null then
          vLinea:= vLinea||' por Organizacion';
       else
          vLinea:= vLinea||' por Tienda';
       end if;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vLinea);
       --*
       vLinea :='Periodo del '||P_DATE1||' al '||P_DATE2;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vLinea);
       --*
       vLinea := 'Organizacion'||P_SEP||'Articulo'||P_SEP||'Desc Articulo'||P_SEP||'Fecha de Trans'||P_SEP||'Tienda'||P_SEP||'Codigo de Transaccion'||P_SEP||'Documento'||P_SEP;
       vLinea := vLinea||'Costo Transac'||P_SEP||'Costo Posterior'||P_SEP||'Costo Retaceo'||P_SEP||'Var Retaceo'||P_SEP||'Costo Final'||P_SEP||'Saldo Inic'||P_SEP||'Entradas'||P_SEP||'Salidas'||P_SEP||'Valor Transac'||P_SEP||'Saldo Final'||P_SEP||'Valor Saldo'||P_SEP;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vLinea);
       --*
  END IF;
  --+
  --
    vdebug:='Convierte fecha';
     --
     --vfecha_d:=  SIMAC_FUNCIONES_VARIAS.CONVIERTE_FECHA_IDIOMA(USERENV('LANG'), P_DATE1,'DD-MON-YYYY')-1;
     vfecha_c:= to_char(vfecha_d, 'DD-MON-YYYY');
   vdebug:='Insertando datos del reporte';
 FOR k in C_DATOS LOOP
  --*--------------------------*--
   --* Inicializa Variables *--
   --*--------------------------*--
     sal_in :=0;
     cont :=0;
     vSaldo_Ini :=0;
     vSaldo_Ini :=0;
     vTransaction :=0;
     ----------------
     sal_final:=0;
     ----------------
     vCost_ret:=0;
     vCost_New :=0;
     vRetaceo := null;
     vVarRetaceo :=0;
   --*--------------------------*--
   --* Obtiene el saldo inicial *--
   --*--------------------------*--
     --
     vdebug:='Obtiene el saldo inicial';
    if CP_saldo_inicial =0 And CP_subinv Is Null Then
      vdebug:=' Open cExistencia';
       Open cExistencia(k.item_id, vfecha_c);
       Fetch cExistencia Into vSaldo_Ini;
       Close cExistencia;
      vdebug:=' Asinga CP_saldo_inicial';
     --
       CP_saldo_inicial := vSaldo_Ini;
       CP_subinv := k.Item;
    --
   ElsIf CP_subinv <> k.Item Then
       Open cExistencia(k.item_id, vfecha_c);
       Fetch cExistencia Into vSaldo_Ini;
       Close cExistencia;
     CP_saldo_inicial := vSaldo_Ini;
     CP_subinv := k.Item;
   End If;
  sal_in := CP_saldo_inicial;
  --*--------------------------*--
  --* Obtiene el saldo final   *--
  --*--------------------------*--
     vdebug:='Obtiene el saldo final';
   sal_final := CP_SALDO_INICIAL + k.Entradas + k.Salidas;
   CP_saldo_inicial := sal_final;
  --*--------------------------*--
  --*  Calcula Costos          *--
  --*--------------------------*--
  Begin
     vdebug:='Calcula costos brk 1';
  If k.RCV_TRANSACTION_ID Is Not Null Then
     /* 
     Begin
        select sdr.COSTO_UNITARIO_CON_RET, (sdr.COSTO_UNITARIO_CON_RET - (Monto_Recibir/CANTIDAD_A_RECIBIR)) var_Unitario  ,scr.NUMERO_RETACEO||'-'||sdr.CABRET_ID retaceo
               Into  vCost_ret,vVarRetaceo , vRetaceo
         from apps.rcv_transactions rcvt, simac.SI_DETALLEPO_RETACEO sdr, simac.SI_CABECERA_RETACEO scr
        where rcvt.TRANSACTION_ID  = k.RCV_TRANSACTION_ID
          and rcvt.ORGANIZATION_ID = P_ORG_ID
          and rcvt.po_header_id = sdr.PO_HEADER_ID
          and rcvt.po_line_id   = sdr.PO_LINE_ID
          and scr.CABRET_ID     = sdr.CABRET_ID;
       Exception
        When Others Then
        vCost_ret   := 0;
        vVarRetaceo := 0;
        vRetaceo  := Null;
       End;
       
       */
  -- Nuevo Costo
      Begin
         vdebug:='Calcula costos brk2';
        select MAX(mtt.NEW_COST) Into  vCost_New
           from apps.mtl_material_transactions mtt
          where organization_id = P_ORG_ID
            and mtt.SOURCE_CODE = 'AJUSTE'
            AND mtt.INVENTORY_ITEM_ID = k.item_id
            --And SOURCE_LINE_ID = vRef_Line
            and transaction_reference like 'Retaceo%'||LTRIM(RTRIM(vRetaceo))
            GROUP BY QUANTITY_ADJUSTED;
      Exception
       When Others Then
       vCost_New := 0;
      End;
  Else
           vdebug:='Calcula costos brk3';
      vCost_ret := 0;
      vRetaceo  := Null;
      vCost_New := Null;
      vVarRetaceo := 0;
  End If;
  --
  vdebug:='Calcula costos brk4';
   CP_Costo_Retaceo := Nvl(vCost_ret,0);
   CP_Costo_Final   := Nvl(vCost_New,k.New_Cost);
   CP_Retaceo_Unitario := Nvl(vVarRetaceo,0);
   --
   vdebug:='Calcula costos brk5';
   IF k.Entradas > 0 And k.RCV_TRANSACTION_ID Is Null Then
     CP_Valor_Salida := k.Entradas * CP_Costo_Final;
   elsif k.Entradas > 0 And k.RCV_TRANSACTION_ID Is Not Null Then
     CP_Valor_Salida := k.Entradas * CP_Costo_Retaceo;
   Else
     CP_Valor_Salida  := k.Salidas * CP_Costo_Final;
   End if;
   --
   vdebug:='Calcula costos brk6';
   CP_Valor_Final   := sal_final * CP_Costo_Final;
  end;-- Finaliza el calculo de costos
  --*
  --Construye la linea.
        vdebug:='Construye linea';
      vLinea := k.name||P_SEP||k.item||P_SEP||k.description||P_SEP||k.Transaction_date||P_SEP||k.Subinventory_code||P_SEP||k.TRANSACTION_TYPE_NAME||P_SEP||k.DOCUMENTO||P_SEP;
      vLinea := vLinea||round(k.TRANSACTION_COST,2)||P_SEP||round(k.NEW_COST,2)||P_SEP||round(CP_COSTO_RETACEO,2)||P_SEP||round(CP_RETACEO_UNITARIO,2)||P_SEP||round(CP_COSTO_FINAL,2)||P_SEP||sal_in||P_SEP||k.ENTRADAS||P_SEP||k.SALIDAS||P_SEP||round(CP_VALOR_SALIDA,2)||P_SEP||sal_final||P_SEP||round(CP_VALOR_FINAL,2)||P_SEP;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,vLinea);
      --*
  END LOOP;-- Cierra el loop principal de datos
--
EXCEPTION
    WHEN OTHERS THEN
         RETCODE :='2';
         ERRBUF:=SQLERRM||' '||vdebug;
--
END XXSV_MTL_KARDEX;                                  
                             
-- FIN DEL PAQUETE
END ;
/
