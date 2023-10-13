FUNCTION zexcel_to_cust_details_db.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_CUST_DETAILS) TYPE  ZTT_CUST_DETAILS
*"     VALUE(IM_BOOKINGS) TYPE  ZTT_BOOKING_DATA
*"----------------------------------------------------------------------
  DATA : lt_final   TYPE TABLE OF ztcust_details,
         lt_booking TYPE TABLE OF ztbooking.

  LOOP AT im_cust_details INTO DATA(wa).
    APPEND wa TO lt_final.
*    Push the data into DB table by using Modify statement.
  ENDLOOP.

  LOOP AT im_bookings INTO DATA(wa_book).
    APPEND wa_book TO lt_booking.
*    Push the data into DB table by using Modify statement.
  ENDLOOP.

  IF sy-subrc = 0.
  ENDIF.

ENDFUNCTION.
