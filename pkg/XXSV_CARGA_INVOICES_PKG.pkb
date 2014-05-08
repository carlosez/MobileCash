CREATE OR REPLACE PACKAGE BODY BOLINF.XXSV_CARGA_INVOICES_PKG IS

                                     
 --       
 PROCEDURE XX_AR_INTERFACE( ERRBUF OUT VARCHAR2,
                            RETCODE OUT VARCHAR2,
                            P_ORG_ID NUMBER,
                            P_USER_ID NUMBER) IS
 CURSOR C_DATOS IS
 SELECT SUM(AR.QUANTITY) QUANTITY,
        SUM(AMOUNT) AMOUNT,
        SUM(AMOUNT)/SUM(AR.QUANTITY) UNIT_SELLING_PRICE, 
        ORIG_SYSTEM_BILL_CUSTOMER_REF,
        AR.CONVERSION_RATE,
        AR.CONVERSION_TYPE,
        AR.CONVERSION_DATE,
        AR.CURRENCY_CODE,
        AR.GL_DATE,
        AR.TRX_DATE,
        MAX(AR.TERM_NAME) TERM_NAME,
        AR.PRINTING_OPTION,
        AR.INTERFACE_LINE_CONTEXT,
        AR.INTERFACE_LINE_ATTRIBUTE1,
        AR.UOM_CODE,
        AR.BATCH_SOURCE_NAME,
        AR.CUST_TRX_TYPE_NAME,
        AR.LINK_TO_LINE_CONTEXT,
        AR.TAX_CODE,
        AR.PRIMARY_SALESREP_NUMBER,
        AR.PRIMARY_SALESREP_ID,
        AR.ORIG_SYSTEM_BILL_ADDRESS_REF,
        AR.DESCRIPTION,
        AR.LINE_TYPE,
        AR.SET_OF_BOOKS_ID
   FROM XXSV_CARGA_ARINVOICES_CONVIVA AR
  WHERE NVL(STATUS,'C') = 'C' 
    AND ORG_ID = P_ORG_ID
  GROUP BY ORIG_SYSTEM_BILL_CUSTOMER_REF,
           AR.CONVERSION_RATE,
           AR.CONVERSION_TYPE,
           AR.CONVERSION_DATE,
           AR.CURRENCY_CODE,
           AR.GL_DATE,
           AR.TRX_DATE,
           AR.PRINTING_OPTION,
           AR.INTERFACE_LINE_CONTEXT,
           AR.INTERFACE_LINE_ATTRIBUTE1,
           AR.UOM_CODE,
           AR.BATCH_SOURCE_NAME,
           AR.CUST_TRX_TYPE_NAME,
           AR.LINK_TO_LINE_CONTEXT,
           AR.TAX_CODE,
           AR.PRIMARY_SALESREP_NUMBER,
           AR.PRIMARY_SALESREP_ID,
           AR.ORIG_SYSTEM_BILL_ADDRESS_REF,
           AR.DESCRIPTION,
           AR.LINE_TYPE,
           AR.SET_OF_BOOKS_ID;
    

 SALESREP_NUMBER VARCHAR2(30);
 SALESREP_ID NUMBER;
 INSERT_FLAG VARCHAR2(1);
 
 L_LINE_SECUENCE NUMBER;
 L_GL_LINE_SECUENCE NUMBER;
 VCONTA NUMBER;
 VFLAG VARCHAR2(20);  
 V_BATCH_SOURCE_ID NUMBER;
 P_USER_NAME VARCHAR2(100);
 L_REQUEST_ID NUMBER;
 REQUEST NUMBER;
 VPHASE_CODE APPS.FND_CONCURRENT_REQUESTS.PHASE_CODE%TYPE;
 VSTATUS_CODE APPS.FND_CONCURRENT_REQUESTS.STATUS_CODE%TYPE;
 VTEXT APPS.FND_CONCURRENT_REQUESTS.COMPLETION_TEXT%TYPE;
BEGIN
 RETCODE := '0';
 
 VCONTA := 0;
 VFLAG := 'INI FOR';
 --
 /*
 REQUEST := APPS.FND_REQUEST.SUBMIT_REQUEST( 'BOLINF',
                                        'XXSV_CARGA_AR_CONVIVA3',
                                        NULL,
                                        NULL,
                                        FALSE,
                                        P_ORG_ID,
                                        P_USER_ID,
                                        CHR(0),NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                                        );
 --
 COMMIT;                                                                              
 --
                                      
 IF REQUEST = 0 THEN
    RETCODE := '2';
    INSERT_FLAG := 'N';
    ERRBUF := ' ERROR: NO SE EJECUTO EL CONCURENTE  '||SQLERRM;
    ROLLBACK;    
 END IF;    
 --
 LOOP
  --
  BEGIN  
   --
   DBMS_LOCK.SLEEP(10);
    -- 
  EXCEPTION
   WHEN OTHERS THEN
        RETCODE := '2';
        INSERT_FLAG := 'N';
        ERRBUF := ' ERROR DURMIENDO EL PROCESO  '||SQLERRM;
        ROLLBACK; 
  END;  
  --  
  BEGIN
   -- EXTRAE INFORMACION DE ESTADO PROCESO
   SELECT UNIQUE PHASE_CODE, STATUS_CODE, COMPLETION_TEXT
     INTO VPHASE_CODE, VSTATUS_CODE, VTEXT
     FROM APPS.FND_CONCURRENT_REQUESTS
    WHERE REQUEST_ID = REQUEST;
  EXCEPTION
   WHEN OTHERS THEN
        VPHASE_CODE := 'C';
  END;
  --
  EXIT WHEN VPHASE_CODE = 'C';
  --
 END LOOP;  
 --
 BEGIN
  UPDATE XXSV_CARGA_ARINVOICES_CONVIVA  
     SET AMOUNT = (QUANTITY * UNIT_SELLING_PRICE),
         TRX_DATE = SYSDATE,
         GL_DATE = SYSDATE,
         STATUS = 'C'         
   WHERE STATUS IS NULL   
     AND ORG_ID = P_ORG_ID;
 END;
 */
 
 INSERT_FLAG := 'Y';
 BEGIN
  SELECT BATCH_SOURCE_ID
    INTO V_BATCH_SOURCE_ID      
    FROM APPS.RA_BATCH_SOURCES_ALL
   WHERE ORG_ID = P_ORG_ID
     AND NAME = 'SV-TIGOCASH';
 EXCEPTION 
   WHEN OTHERS THEN
        RETCODE := '2';
        INSERT_FLAG := 'N';
        ERRBUF := 'NO ENCUENTRA EL SORUCE '||SQLERRM;
        ROLLBACK;    
 END;
 
 BEGIN
  SELECT USER_NAME
    INTO P_USER_NAME
    FROM FND_USER
   WHERE USER_ID = P_USER_ID; 
 END;
 
 FOR I IN C_DATOS  LOOP
     -- 
     

     SALESREP_NUMBER    := I.PRIMARY_SALESREP_NUMBER;
     SALESREP_ID        := I.PRIMARY_SALESREP_ID;
     
     
     
     IF (NVL(SALESREP_NUMBER, 'NULL') = 'NULL') AND (NVL(SALESREP_ID, 0) = 0) THEN
        SALESREP_ID := -3;
     END IF;

     IF INSERT_FLAG = 'Y' THEN
     
     
        VCONTA := VCONTA + 1;
        
        SELECT APPS.RA_CUSTOMER_TRX_LINES_S.NEXTVAL 
          INTO L_LINE_SECUENCE
          FROM DUAL;
         
     
        INSERT INTO AR.RA_INTERFACE_LINES_ALL (
                                                INTERFACE_LINE_ID
                                                ,INTERFACE_LINE_CONTEXT                                                
                                                ,INTERFACE_LINE_ATTRIBUTE1
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
                                                ,CONVERSION_DATE                                                
                                                ,CONVERSION_RATE
                                                ,TRX_DATE                                                
                                                ,GL_DATE
                                                ,QUANTITY                                                
                                                ,UNIT_SELLING_PRICE
                                                ,PRINTING_OPTION
                                                ,TAX_CODE                                                
                                                ,PRIMARY_SALESREP_NUMBER
                                                ,PRIMARY_SALESREP_ID
                                                ,UOM_CODE                                                
                                                ,CREATED_BY
                                                ,CREATION_DATE                                                
                                                ,ORG_ID
                                              ) 
                                     VALUES (   
                                                L_LINE_SECUENCE
                                                ,I.INTERFACE_LINE_CONTEXT
                                                ,VCONTA --I.INTERFACE_LINE_ATTRIBUTE1 
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
                                                ,I.CONVERSION_DATE 
                                                ,I.CONVERSION_RATE
                                                ,I.TRX_DATE   
                                                ,I.GL_DATE
                                                ,I.QUANTITY
                                                ,I.UNIT_SELLING_PRICE
                                                ,I.PRINTING_OPTION
                                                ,I.TAX_CODE                                                
                                                ,SALESREP_NUMBER 
                                                ,SALESREP_ID 
                                                ,I.UOM_CODE                                                
                                                ,P_USER_ID
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
                     CREATION_DATE
                   )
            VALUES ( '100',
                     1,
                     P_ORG_ID,
                     P_USER_NAME,
                     I.INTERFACE_LINE_CONTEXT,
                     VCONTA,--I.INTERFACE_LINE_ATTRIBUTE1,
                     SYSDATE );                                                                     

     END IF;
     
 END LOOP;
 
 VFLAG := 'UPDATE STATUS';   
 
 UPDATE XX_CARGA_ARINVOICES_CONVIVA 
    SET STATUS = 'P'
  --WHERE INTERFACE_STATUS IS NULL   
  WHERE NVL(STATUS,'C') = 'C' 
    AND ORG_ID = P_ORG_ID;
 COMMIT;

      
    
    /* SELECT MAX(A.RESPONSIBILITY_ID) INTO VRESPO_ID
    FROM FND_USER_RESP_GROUPS A,FND_RESPONSIBILITY_TL C
    WHERE A.RESPONSIBILITY_ID = C.RESPONSIBILITY_ID
    AND A.RESPONSIBILITY_APPLICATION_ID = 222
    --AND A.USER_ID = VUSER_ID
    AND C.RESPONSIBILITY_NAME LIKE 'US%RWT%SUPER%';
    
    FND_GLOBAL.APPS_INITIALIZE(PUSER_ID, VRESPO_ID, 222);*/
 
    VFLAG := 'REQUEST';
 
    IF VCONTA > 0 THEN
       --     
       L_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST(
                         'AR',
                         'RAXMTR',
                         '',
                         '',
                         FALSE,     
                         '1',
                         P_ORG_ID,
                         V_BATCH_SOURCE_ID, 
                         'SV-TIGOCASH',
                         SYSDATE,--arg5
                         '','','','','','' ,'','','','', --arg15
                         '','','','','','' ,'','','','', --arg25
                         '','','','','','Y','',CHR(0)             --arg28
--                         '','','','','','','','','','',
--                         '','','','','','','','','','',
--                         '','','','','','','','','','',
--                         '','','','','','','','','','',
--                         '','','','','','','','','','',
--                         '','','','','','','','','','',
--                         '','','','','','','','','',''
                         );
      COMMIT;
    END IF;

  
EXCEPTION
  WHEN OTHERS THEN
       --   
       RETCODE := '2';
       ERRBUF  := 'AR_INTERFACE: '||VFLAG||' '||SQLERRM;
       ROLLBACK;       
       --
END XX_AR_INTERFACE;

PROCEDURE XX_AP_INTERFACE (ERRBUF OUT VARCHAR2,
                            RETCODE OUT VARCHAR2,
                            P_ORG_ID NUMBER) IS

CURSOR C_DATA_H IS
SELECT DISTINCT
       SOURCE, 
       INVOICE_TYPE_LOOKUP_CODE,
       INVOICE_NUM, 
       INVOICE_DATE,
       VENDOR_NUM,
       VENDOR_SITE_CODE,
       VENDOR_ID,
       INVOICE_AMOUNT,
       INVOICE_CURRENCY_CODE,
       EXCHANGE_RATE_TYPE,
       EXCHANGE_RATE,
       EXCHANGE_DATE,
       DESCRIPTION,
       ORG_ID,
       GL_DATE
  FROM XXSV_CARGA_APINVOICES
 WHERE ORG_ID = P_ORG_ID
   AND NVL(STATUS,'X') = 'X';
--
CURSOR C_DATA_L (INV_NUM_L VARCHAR2, V_VENDOR_SITE_CODE VARCHAR2) IS
SELECT LINE_TYPE_LOOKUP_CODE,
       AMOUNT_LINE, 
       --TAX_CODE,
       DESCRIPTION_LINE,
       DIST_CODE_CONCATENATED,
       LINE_NUMBER
  FROM XXSV_CARGA_APINVOICES
 WHERE ORG_ID = P_ORG_ID
   AND NVL(STATUS,'X') = 'X'
   AND INVOICE_NUM = INV_NUM_L
   AND VENDOR_SITE_CODE = V_VENDOR_SITE_CODE;
   
--
ID_FACTURA NUMBER;
vUser_Id NUMBER;
Vresponsibility_Id NUMBER;
NOM_BATCH VARCHAR2(250);
REQUEST NUMBER;
VFLAG VARCHAR2(250);
VPHASE_CODE  VARCHAR2(1);
VSTATUS_CODE VARCHAR2(1);
EXISTE_BATCH NUMBER;
V_VENDOR_NAME  VARCHAR2(240);
V_VENDOR_ID NUMBER;
-- 
BEGIN

 FOR K IN C_DATA_H LOOP
     
     BEGIN 
       SELECT PV.VENDOR_NAME,
              PV.VENDOR_ID
         INTO V_VENDOR_NAME,
              V_VENDOR_ID    
         FROM PO_VENDORS PV,
              PO_VENDOR_SITES_ALL PVS
        WHERE PV.VENDOR_ID = PVS.VENDOR_ID
          AND PVS.ORG_ID = P_ORG_ID   
          AND PVS.VENDOR_SITE_CODE= K.VENDOR_SITE_CODE;
    EXCEPTION 
      WHEN OTHERS THEN
           V_VENDOR_NAME := NULL;
    END;              
    
     
     
     -- INCREMENTA EN UNO LA SECUENCIA
     SELECT AP_INVOICES_S.NEXTVAL 
       INTO ID_FACTURA
       FROM DUAL;
     --
     INSERT INTO AP_INVOICES_INTERFACE
                          ( SOURCE, 
                            INVOICE_TYPE_LOOKUP_CODE,
                            INVOICE_NUM, 
                            INVOICE_DATE,
                            GL_DATE,   
                            VENDOR_ID,
                            VENDOR_NAME,
                            VENDOR_SITE_CODE,
                            INVOICE_AMOUNT,
                            INVOICE_CURRENCY_CODE,
                            EXCHANGE_RATE_TYPE,
                            EXCHANGE_RATE,
                            EXCHANGE_DATE,
                            DESCRIPTION,
                            ORG_ID,
                            INVOICE_ID,
                            INVOICE_RECEIVED_DATE)
                   VALUES ( K.SOURCE, 
                            K.INVOICE_TYPE_LOOKUP_CODE,
                            K.INVOICE_NUM, 
                            K.INVOICE_DATE,
                            K.INVOICE_DATE,
                            V_VENDOR_ID,
                            V_VENDOR_NAME,
                            K.VENDOR_SITE_CODE,
                            K.INVOICE_AMOUNT,
                            K.INVOICE_CURRENCY_CODE,
                            K.EXCHANGE_RATE_TYPE,
                            K.EXCHANGE_RATE,
                            K.EXCHANGE_DATE,
                            K.DESCRIPTION,
                            K.ORG_ID,
                            ID_FACTURA,
                            K.INVOICE_DATE); 
     --
     FOR J IN C_DATA_L (K.INVOICE_NUM, K.VENDOR_SITE_CODE) LOOP
         --
         INSERT INTO AP_INVOICE_LINES_INTERFACE
                    ( LINE_TYPE_LOOKUP_CODE,
                      AMOUNT, 
                     -- TAX_CODE,
                      DESCRIPTION,
                      DIST_CODE_CONCATENATED,                      
                      LINE_NUMBER,
                      ACCOUNTING_DATE,
                      INVOICE_ID
                      ) 
             VALUES ( J.LINE_TYPE_LOOKUP_CODE,
                      J.AMOUNT_LINE, 
                      --J.TAX_CODE,
                      J.DESCRIPTION_LINE,
                      J.DIST_CODE_CONCATENATED,
                      J.LINE_NUMBER,
                      K.GL_DATE, 
                      ID_FACTURA );
            --
     END LOOP; -- CIERRA EL LOOP DE LOS DETALLES DE FACTURA 
 END LOOP; -- CIERRA EL LOOP DE CABECERAS DE FACTURA
 --
 COMMIT;
 --
 UPDATE XXSV_CARGA_APINVOICES
    SET STATUS = 'P'
  WHERE ORG_ID = P_ORG_ID
    AND NVL(STATUS,'X') = 'X';
 --
 COMMIT;
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
 
 vUser_Id  := fnd_global.USER_ID;
 --
 NOM_BATCH := SUBSTR('INVOICE_UPLOAD' ||'-' ||TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS'),1,30);
 
 REQUEST := FND_REQUEST.SUBMIT_REQUEST ('SQLAP',
                                        'APXIIMPT',
                                        '',
                                        '',
                                        FALSE,
                                        P_ORG_ID,
                                        'INVOICE_UPLOAD',
                                        '',
                                        NOM_BATCH,
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
                                        CHR(0), 
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '',
                                        '');
 --
 COMMIT;
 -- LOOP PARA ESPERAR QUE FINALICE EL REQUEST
  LOOP
   --
   -- TIMER
   DBMS_LOCK.sleep(10);
   --
   SELECT PHASE_CODE,
          STATUS_CODE  
     INTO VPHASE_CODE,
          VSTATUS_CODE
     FROM FND_CONCURRENT_REQUESTS
    WHERE REQUEST_ID = REQUEST;
   --
   EXIT WHEN VPHASE_CODE = 'C';        
  END LOOP;
  --
  IF VSTATUS_CODE IN ('G','E') THEN
     VFLAG := 'EL REQUEST NUMERO ' || TO_CHAR(REQUEST) || ' FINALIZO CON ERROR';
  END IF;
  -- 
    
END XX_AP_INTERFACE;

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