Check that the combination of values in RA_INTERFACE_LINES_ALL INTERFACE_LINE_CONTEXT + INTERFACE_LINE_ATTRIBUTE* does not yet exist in RA_CUSTOMER_TRX_LINES_ALL


(trx_number=210,customer_trx_id=5743961)



select ctrx.  ctrx.* 
from   RA_CUSTOMER_TRX_LINES_ALL ctrx
where ctrx.customer_trx_id=5743961