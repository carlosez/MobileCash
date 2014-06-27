CREATE OR REPLACE PACKAGE BOLINF.XXSV_CARGA_INVOICES_PKG IS

 -- 
 -- Leyenda
 G_Null         Varchar2(1) := 'N';
 G_AWAITING     Varchar2(1) := 'A';
 G_Processed    Varchar2(1) := 'P';
 g_interface    Varchar2(1) := 'I';
 G_Discarted    Varchar2(1) := 'D';
 G_Error        Varchar2(1) := 'E';
 
 
 PROCEDURE XX_AR_INTERFACE  
    (P_Org_Id                   Number
    ,P_Batch_Source             Varchar2
    ,p_interface_line_context   varchar2
    ,P_GL_DATE                  varchar2
    ,P_TRX_DATE                 varchar2
    ,P_GROUP_BY_CUSTOMER        varchar2
    );

 procedure AR_INTERFACE_STAGGING
    (P_ORG_ID                   NUMBER
    ,P_BATCH_SOURCE             VARCHAR2
    ,P_INTERFACE_LINE_CONTEXT   VARCHAR2
    ,P_GL_DATE                  VARCHAR2
    ,P_TRX_DATE                 VARCHAR2
    ,P_GROUP_BY_CUSTOMER        VARCHAR2
    );

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
    );

 --
 PROCEDURE XX_AP_INTERFACE  
    (P_Org_Id               Number
    ,P_User_Id              Number
    ,p_resp_id              Number
    ,P_Source               Varchar2
    ,p_gl_date              varchar2
    ,p_trx_date             varchar2
    ,p_group_by_supplier    varchar2
    );    

   PROCEDURE AP_PROCESS_STAGGING
    (P_PROCESS_TYPE         varchar2
    ,P_Org_Id               Number
    ,P_User_Id              Number
    ,p_resp_id              Number
    ,P_Source               Varchar2
    );   
                   
 
 
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
