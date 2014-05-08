CREATE OR REPLACE PACKAGE BOLINF.XXSV_CARGA_INVOICES_PKG IS

 --
 PROCEDURE XX_AR_INTERFACE( ERRBUF OUT VARCHAR2,
                            RETCODE OUT VARCHAR2,
                            P_ORG_ID NUMBER,
                            P_USER_ID NUMBER);

 --
 PROCEDURE XX_AP_INTERFACE (ERRBUF OUT VARCHAR2,
                            RETCODE OUT VARCHAR2,
                            P_ORG_ID NUMBER);    
                            
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
