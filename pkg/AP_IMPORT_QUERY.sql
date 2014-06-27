/* Formatted on 6/19/2014 11:02:50 AM (QP5 v5.139.911.3011) */
desc RA_BATCH_SOURCES_ALL;


SELECT BATCH_SOURCE_ID
  --    INTO V_BATCH_SOURCE_ID
  FROM APPS.RA_BATCH_SOURCES_ALL
 WHERE ORG_ID = :P_ORG_ID AND NAME = 'SV-TIGOCASH';


SELECT MEANING
  FROM FND_LOOKUPS
 WHERE LOOKUP_TYPE = 'YES_NO' AND lookup_code = 'Y';

SELECT SUBSTR (
          'INVOICE ' || '-' || TO_CHAR (SYSDATE, 'YYYY-MON-DD HH24:MI:SS'),
          1,
          30)
  FROM DUAL;


  SELECT LOOKUP_CODE, MEANING, DESCRIPTION
    FROM FND_LOOKUP_VALUES_VL
   WHERE     lookup_type = 'SOURCE'
         AND (VIEW_APPLICATION_ID = 200)
         AND (SECURITY_GROUP_ID = 0)
         AND (ENABLED_FLAG = 'Y')
ORDER BY LOOKUP_CODE;



SELECT status, a.*
  FROM XXSV_CARGA_APINVOICES a;

SELECT ou.name,
       sp.vendor_name,
       sp.segment1,
       ss.vendor_site_code
  FROM ap.ap_suppliers sp,
       ap.ap_supplier_sites_all ss,
       apps.hr_operating_units ou
 WHERE     OU.name LIKE 'SV%'
       AND ou.ORGANIZATION_ID = ss.org_id
       AND ss.vendor_id = sp.vendor_id;


SELECT LAST_DAY (SYSDATE) FROM DUAL;


  SELECT ATTRIBUTE7,
         TRANSACTION_ID,
         ORGANIZATION_ID,
         NAME,
         SUBINVENTORY_CODE,
         LOCATOR_ID,
         ITEM,
         ITEM_ID,
         '  ' || DESCRIPTION DESCRIPTION,
         TRANSACTION_DATE,
         TRANSACTION_TYPE_ID,
         '  ' || TRANSACTION_TYPE_NAME TRANSACTION_TYPE_NAME,
         DOCUMENTO,
         SALDO_INICIAL,
         ENTRADAS,
         SALIDAS SALIDAS,
         (SALDO_INICIAL + ENTRADAS) + SALIDAS SALDO_FINAL,
         TRANSACTION_COST TRANSACTION_COST,
         NEW_COST NEW_COST,
         RCV_TRANSACTION_ID,
         TRANSACTION_SOURCE_ID,
         VENDOR_ID,
         VENDOR_SITE_ID
    FROM (  SELECT MTT.ATTRIBUTE7,
                   MTT.ORGANIZATION_ID,
                   MTT.TRANSACTION_ID,
                   HR.NAME,
                   MTT.SUBINVENTORY_CODE,
                   MTT.LOCATOR_ID,
                   MIT.SEGMENT1 ITEM,
                   MIT.INVENTORY_ITEM_ID ITEM_ID,
                   MIT.DESCRIPTION,
                   MTT.TRANSACTION_DATE,
                   MTT.TRANSACTION_TYPE_ID,
                   MTL.TRANSACTION_TYPE_NAME,
                   DECODE (MTT.TRANSACTION_TYPE_ID,
                           18, PH.SEGMENT1,
                           MTT.TRANSACTION_REFERENCE)
                      DOCUMENTO,
                   0 SALDO_INICIAL,
                   --NVL(DECODE(MTT.TRANSACTION_ACTION_ID,27,TRANSACTION_QUANTITY,0),0) ENTRADAS,
                   NVL (
                      DECODE (SIGN (TRANSACTION_QUANTITY),
                              1, TRANSACTION_QUANTITY,
                              0),
                      0)
                      ENTRADAS,
                   --NVL(DECODE(MTT.TRANSACTION_ACTION_ID,1,TRANSACTION_QUANTITY,2,TRANSACTION_QUANTITY,0),0) SALIDAS,
                   NVL (
                      DECODE (SIGN (TRANSACTION_QUANTITY),
                              -1, TRANSACTION_QUANTITY,
                              0),
                      0)
                      SALIDAS,
                   NVL (MTT.ACTUAL_COST, 0) TRANSACTION_COST,
                   MTT.NEW_COST,
                   MTT.RCV_TRANSACTION_ID,
                   MTT.TRANSACTION_SOURCE_ID,
                   PH.VENDOR_ID,
                   PH.VENDOR_SITE_ID
              FROM MTL_MATERIAL_TRANSACTIONS MTT,
                   MTL_SYSTEM_ITEMS_B MIT,
                   MTL_TRANSACTION_TYPES MTL,
                   HR_ORGANIZATION_UNITS HR,
                   PO_HEADERS_ALL PH
             WHERE     MTT.ORGANIZATION_ID = MIT.ORGANIZATION_ID(+)
                   AND MTT.INVENTORY_ITEM_ID = MIT.INVENTORY_ITEM_ID(+)
                   AND MTT.TRANSACTION_TYPE_ID = MTL.TRANSACTION_TYPE_ID(+)
                   AND MTT.ORGANIZATION_ID = HR.ORGANIZATION_ID(+)
                   AND MTT.TRANSACTION_SOURCE_ID = PH.PO_HEADER_ID(+)
                   --
                   AND MTT.ORGANIZATION_ID = :P_ORGANIZATION_ID
                   --AND TO_CHAR (MTT.TRANSACTION_DATE, 'DD-MON-YY') BETWEEN TO_DATE (:P_DATE1, 'DD-MON-YY') AND TO_DATE (:P_DATE2, 'DD-MON-YY')
                   AND TRUNC (MTT.TRANSACTION_DATE) BETWEEN DECODE (
                                                               USERENV ('LANG'),
                                                               'US', TO_DATE (
                                                                        :P_DATE1,
                                                                        'YYYY-MM-DD HH24:MI:SS',
                                                                        'NLS_DATE_LANGUAGE = ENGLISH'),
                                                               TO_DATE (
                                                                  :P_DATE1,
                                                                  'YYYY-MM-DD HH24:MI:SS',
                                                                  'NLS_DATE_LANGUAGE = SPANISH'))
                                                        AND DECODE (
                                                               USERENV ('LANG'),
                                                               'US', TO_DATE (
                                                                        :P_DATE2,
                                                                        'YYYY-MM-DD HH24:MI:SS',
                                                                        'NLS_DATE_LANGUAGE = ENGLISH'),
                                                               TO_DATE (
                                                                  :P_DATE2,
                                                                  'YYYY-MM-DD HH24:MI:SS',
                                                                  'NLS_DATE_LANGUAGE = SPANISH'))
                   --
                   AND MTT.INVENTORY_ITEM_ID BETWEEN :P_ITEM_FROM
                                                 AND NVL (:P_ITEM_TO,
                                                          :P_ITEM_FROM)
          --
          ORDER BY TO_NUMBER (MTT.ATTRIBUTE7))
ORDER BY TRANSACTION_DATE, TRANSACTION_ID, ORGANIZATION_ID              --1, 2




vCost_ret Number;
vCost_New Number;
vRetaceo varchar2(50);
vVarRetaceo Number;
begin

/*
    If :RCV_TRANSACTION_ID Is Not Null Then
    
    Begin
  select sdr.COSTO_UNITARIO_CON_RET, (sdr.COSTO_UNITARIO_CON_RET - (Monto_Recibir/CANTIDAD_A_RECIBIR)) var_Unitario  ,scr.NUMERO_RETACEO||'-'||sdr.CABRET_ID retaceo 
       Into  vCost_ret,vVarRetaceo , vRetaceo
  from rcv_transactions rcvt, simac.SI_DETALLEPO_RETACEO sdr, simac.SI_CABECERA_RETACEO scr
 where rcvt.TRANSACTION_ID  = :RCV_TRANSACTION_ID 
   and rcvt.ORGANIZATION_ID = :P_ORGANIZATION_ID
   and rcvt.po_header_id = sdr.PO_HEADER_ID
   and rcvt.po_line_id   = sdr.PO_LINE_ID
   and scr.CABRET_ID     = sdr.CABRET_ID;
    Exception 
        When Others Then
        vCost_ret   := 0; 
        vVarRetaceo := 0;
        vRetaceo  := Null;
    End;   
-- Nuevo Costo
Begin    
     select MAX(mtt.NEW_COST) Into  vCost_New
     from mtl_material_transactions mtt
    where organization_id = :P_ORGANIZATION_ID
      and mtt.SOURCE_CODE = 'AJUSTE'
      AND mtt.INVENTORY_ITEM_ID = :item_id
      --And SOURCE_LINE_ID = vRef_Line
      and transaction_reference like 'Retaceo%'||LTRIM(RTRIM(vRetaceo))
      GROUP BY QUANTITY_ADJUSTED;
Exception
    When Others Then
    vCost_New := 0;
End;*/      
 
--Else
        vCost_ret := 0; 
        vRetaceo  := Null;
        vCost_New := Null;
        vVarRetaceo := 0;
--End If;

 
   :CP_Costo_Retaceo := Nvl(vCost_ret,0);
   :CP_Costo_Final   := Nvl(vCost_New,:New_Cost);
   :CP_Retaceo_Unitario := Nvl(vVarRetaceo,0);
 
 
 IF :Entradas > 0 And :RCV_TRANSACTION_ID Is Null Then
   :CP_Valor_Salida := :Entradas * :CP_Costo_Final;
 elsif :Entradas > 0 And :RCV_TRANSACTION_ID Is Not Null Then
     :CP_Valor_Salida := :Entradas * :CP_Costo_Retaceo;
       
 Else
     
   :CP_Valor_Salida  := :Salidas * :CP_Costo_Final;
 End if;
 
  :CP_Valor_Final   := :CF_Saldo_Final * :CP_Costo_Final;
  return 0;
end;


select * from AP_INVOICES_INTERFACE
where org_id = 346
and STATUS != 'PROCESSED'
;

 select * 
  from AP_INVOICE_LINES_INTERFACE ivl
      ,AP_INVOICES_INTERFACE      iv
where iv.org_id = 346
and STATUS != 'PROCESSED'
and ivl.invoice_id = iv.invoice_id
;


     
     SELECT DISTINCT
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
           ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :g_invoice_num   ,INVOICE_NUM)       INVOICE_NUM     --+ 20 # P
           ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :g_trx_date      ,INVOICE_DATE)      INVOICE_DATE    --+ 21 # P
           ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', 0               ,INVOICE_AMOUNT)    INVOICE_AMOUNT  --+ 22 
           ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :DESCRIPTION     ,DESCRIPTION)       DESCRIPTION     --+ 23 #
           ,DECODE(:P_GROUP_BY_SUPPLIER,'Y', :G_GL_DATE       ,GL_DATE)           GL_DATE         --+ 24 #
      FROM XXSV_CARGA_APINVOICES ivh
     WHERE ivh.ORG_ID = :P_ORG_ID
       AND NVL(ivh.STATUS,'NULL') in ( 'NULL', 'I' )
       order by VENDOR_NUM, VENDOR_SITE_CODE, INVOICE_NUM;
       
       
       345, 10585, 51435, INVOICE_UPLOAD, N, 2014/06/19 00:00:00, 2014/06/19 00:00:00, INVOICE -2014-JUN-19 15:47:43, Y, N
       
       ap_invoices_all
       
       delete from XXSV_CARGA_APINVOICES;

update XXSV_CARGA_APINVOICES
set status = null;

update XXSV_CARGA_APINVOICES ivh
set 
CALC_TAX_DURING_IMPORT_FLAG = 'Y'
 WHERE ivh.ORG_ID = :P_ORG_ID
       AND NVL(ivh.STATUS,'NULL') in ( 'NULL', 'I' )

select * from XXSV_CARGA_APINVOICES
 WHERE ORG_ID = :P_ORG_ID
       AND NVL(STATUS,'NULL') in ( 'NULL', 'I' );