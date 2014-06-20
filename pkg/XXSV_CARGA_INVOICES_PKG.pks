CREATE OR REPLACE PACKAGE BOLINF.XXSV_CARGA_INVOICES_PKG IS

 --
 PROCEDURE XX_AR_INTERFACE  (ERRBUF     Out     Varchar2
                            ,RETCODE    Out     Varchar2
                            ,P_Org_Id           Number
                            ,P_User_Id          Number
                            ,P_Batch_Source     Varchar2
                            ,p_raise_autoinvoice    varchar2
                            ,p_batch_name           varchar2
                            );

 --
 PROCEDURE XX_AP_INTERFACE  (ERRBUF     OUT         VARCHAR2
                            ,RETCODE    OUT         VARCHAR2
                            ,P_Org_Id               Number
                            ,P_User_Id              Number
                            ,p_resp_id              Number
                            ,P_Source               Varchar2
                            ,p_raise_Interface      varchar2
                            ,p_gl_date              varchar2
                            ,p_trx_date             varchar2
                            ,p_batch_name           varchar2
                            ,p_group_by_supplier    varchar2
                            ,p_purge                varchar2
                            );    
                            
 --
 PROCEDURE XXSV_MTL_KARDEX( ERRBUF OUT VARCHAR2,
                            RETCODE OUT VARCHAR2,
                            P_DATE1 VARCHAR2,
                            P_DATE2 VARCHAR2,
                            P_ITEMS_FROM VARCHAR2,
                            P_ITEMS_TO VARCHAR2,
                            P_ORG_ID VARCHAR2,
                            P_SUBINV VARCHAR2,
                            P_SEP VARCHAR2);                                                    
                         
  
END;
/
