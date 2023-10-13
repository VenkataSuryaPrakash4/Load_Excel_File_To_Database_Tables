*&---------------------------------------------------------------------*
*& Form f4_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_file .
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_FPATH'
    IMPORTING
      file_name     = gv_fpath.

  IF sy-subrc EQ 0.
    p_fpath = gv_fpath.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Load_to_Itab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM load_to_itab.
  DATA : lv_filename  TYPE rlgrap-filename,
         lwa_raw_data TYPE truxs_t_text_data.

  lv_filename = p_fpath.

  DATA: lt_excel_data TYPE TABLE OF alsmex_tabline.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 16
      i_end_row               = 9999
    TABLES
      intern                  = lt_excel_data
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc EQ 0.
    LOOP AT lt_excel_data INTO DATA(lwa_excel_data).
      CASE lwa_excel_data-col.
        WHEN 001.
          gwa_excel_data-record_no = lwa_excel_data-value.
        WHEN 002.
          gwa_excel_data-prefix = lwa_excel_data-value.
        WHEN 003.
          gwa_excel_data-customer_name = lwa_excel_data-value.
        WHEN 004.
          gwa_excel_data-aadhar = lwa_excel_data-value.
        WHEN 005.
          gwa_excel_data-address = lwa_excel_data-value.
        WHEN 006.
          gwa_excel_data-mobile = lwa_excel_data-value.
        WHEN 007.
          gwa_excel_data-mail = lwa_excel_data-value.
        WHEN 008.
          gwa_excel_data-password = lwa_excel_data-value.
        WHEN 009.
          gwa_excel_data-room_type = lwa_excel_data-value.
        WHEN 010.
          gwa_excel_data-occupation_date = lwa_excel_data-value.
        WHEN 011.
          gwa_excel_data-occupation_time = lwa_excel_data-value.
        WHEN 012.
          gwa_excel_data-vacate_date = lwa_excel_data-value.
        WHEN 013.
          gwa_excel_data-vacate_time = lwa_excel_data-value.
        WHEN 014.
          gwa_excel_data-reason_for_stay = lwa_excel_data-value.
        WHEN 015.
          gwa_excel_data-source = lwa_excel_data-value.
        WHEN 016.
          gwa_excel_data-allot_by = lwa_excel_data-value.
      ENDCASE.

      AT END OF row.
        APPEND gwa_excel_data TO gt_excel_data.
        CLEAR : gwa_excel_data.
      ENDAT.

      CLEAR: lwa_excel_data.
    ENDLOOP.
  ENDIF.

  IF sy-subrc = 0.
  ENDIF.

  PERFORM loaded_to_itab TABLES gt_excel_data.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form loaded_to_itab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EXCEL_DATA
*&---------------------------------------------------------------------*
FORM loaded_to_itab  TABLES   p_gt_excel_data.

******Fetching Employee_name.
  SELECT employee_id,employee_name
         INTO TABLE @DATA(lt_emp)
         FROM ztemployee."Use for all entires with gt_excel_Data

******Fetching price, tax, maintenance bill.
  SELECT room_type,price,tax,maintenance_charges
    INTO TABLE @DATA(lt_ztprice)
    FROM ztprice."Use for all entires with gt_excel_Data

*************************************************
***************Local Declerations****************

  CONSTANTS : lv_length       TYPE i VALUE 12,
              lv_aadhar_lower TYPE i VALUE 1,
              lv_passlen      TYPE i VALUE 8,
              lv_pass_lower   TYPE i VALUE 1,
              lv_mbl          TYPE i VALUE 10,
              lc_source       TYPE c VALUE 'E',
              lv_mbl_lower    TYPE i VALUE 1,
              lv_cust(4)      TYPE c VALUE 'CUST',
              lv_floor        TYPE c VALUE 'F',
              lv_seperator    TYPE c VALUE '-',
              c_total_rooms   TYPE i VALUE 5.

  DATA : lv_date(10)      TYPE c,
         lv_name          TYPE char100,
         lv_date_1(10)    TYPE c,
         lv_passfix       TYPE c,
         lv_str(2)        TYPE c,
         lv_aadhar_flag   TYPE c,
         lv_fin(8)        TYPE c,
         lv_fin1(8)       TYPE c,
*         before(2)        TYPE c,
*         first(2)         TYPE c,
*         before1          TYPE c,
*         first1           TYPE c,
         lv_final(8)      TYPE i,
         lv_final1(8)     TYPE i,
         lv_prefix_flag   TYPE c,
         lv_tot_rooms     TYPE i VALUE 1,
         lv_floor_num     TYPE i VALUE 1,
         lv_ctot_rooms(2) TYPE c,
         lv_cfloor_num(2) TYPE c,
         lv_total_price   TYPE dmbtr,
         lv_room_number   TYPE zroom_number_de_minipro,
         lv_cust_number   TYPE zcustnum_de_minipro,
         lv_cust_number_1 TYPE ztcust_details,
         lv_countcust     TYPE i,
         lv_counts(2)     TYPE c.
***************End of Declerations***************
*************************************************

  LOOP AT gt_excel_data INTO DATA(lwa_load)."Place all decalrations at the beginning
    DATA(gwa_load) = lwa_load.
******************Validating Prefix******************
    AT NEW record_no.
      CLEAR :lv_name.
      lv_name = gwa_load-customer_name.
      CASE gwa_load-prefix.
        WHEN 'Married/M'. "remove 2nd when condition for male portion
          gwa_final-record_no = gwa_load-record_no.
          gwa_final-prefix = TEXT-001.

        WHEN 'Unmarried/M'.
          gwa_final-record_no = gwa_load-record_no.
          gwa_final-prefix = TEXT-001.

        WHEN 'Unmarried/F'.
          gwa_final-record_no = gwa_load-record_no.
          gwa_final-prefix = TEXT-003.

        WHEN 'Married/F'.
          gwa_final-record_no = gwa_load-record_no.
          gwa_final-prefix = TEXT-002.

        WHEN OTHERS.
* If there is no '/' in the Prefix.
          SEARCH gwa_load-prefix FOR '/'.
          IF sy-subrc <> 0.
            gwa_alv_log-record_no = gwa_load-record_no.
            gwa_alv_log-field = TEXT-004.
            gwa_alv_log-remark = TEXT-005.
            APPEND gwa_alv_log TO gt_alv_log.
            lv_prefix_flag = 'X'.
          ENDIF.
*--remove serach part for 2nd time instead place logic as ELSE part
          SEARCH gwa_load-prefix FOR '/'. "If there is a '/' in the prefix, we then split.
          IF sy-subrc EQ 0.
            SPLIT gwa_load-prefix AT '/' INTO DATA(lv_predecessor) DATA(lv_successor).
            IF sy-subrc EQ 0.
              IF ( ( lv_predecessor IS INITIAL ) AND ( lv_successor IS NOT INITIAL ) ).
                gwa_alv_log-record_no = gwa_load-record_no.
                gwa_alv_log-field = TEXT-004.
                gwa_alv_log-remark = TEXT-006.
                APPEND gwa_alv_log TO gt_alv_log.
                lv_prefix_flag = 'X'.

              ELSEIF  ( ( lv_predecessor IS NOT INITIAL ) AND ( lv_successor IS INITIAL ) ) .
                gwa_alv_log-record_no = gwa_load-record_no.
                gwa_alv_log-field = TEXT-004.
                gwa_alv_log-remark = TEXT-007.
                APPEND gwa_alv_log TO gt_alv_log.
                lv_prefix_flag = 'X'.
              ENDIF.
            ENDIF.
          ENDIF.

          IF gwa_load-prefix IS INITIAL. "If the Prefix values is Initial.
            gwa_alv_log-record_no = gwa_load-record_no.
            gwa_alv_log-field = TEXT-004.
            gwa_alv_log-remark = TEXT-008.
            APPEND gwa_alv_log TO gt_alv_log.
            lv_prefix_flag = 'X'.
          ENDIF.
      ENDCASE.
*****************Validating Customer_Name*****************
      IF gwa_load-customer_name IS INITIAL.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-009.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.
      ENDIF.
*****************Validating Aadhar_Number*****************
      lv_str = strlen( gwa_load-aadhar ).

      IF gwa_load-aadhar IS INITIAL.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-010.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.

      ELSEIF ( lv_str <> lv_length ) AND ( gwa_load-aadhar IS NOT INITIAL )."make this logic as elseif part for above IF condition
        CONCATENATE 'Only' lv_str 'digits found' INTO DATA(lv_concat) SEPARATED BY space. "repalce lv_str at 209 line
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-010.
        gwa_alv_log-remark = lv_concat.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.
      ENDIF.
****Clearing
      CLEAR: lv_str, lv_concat.
*****************Validating Permanent_address*************
      IF gwa_load-address IS INITIAL.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-011.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.
      ENDIF.
*****************Validating Mail Id***********************
      IF gwa_load-mail IS INITIAL.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-013.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.
      ELSE.
        SEARCH gwa_load-mail FOR '@'.
        IF sy-subrc <> 0.
          gwa_alv_log-record_no = gwa_load-record_no.
          gwa_alv_log-field = TEXT-013.
          gwa_alv_log-remark = TEXT-012.
          APPEND gwa_alv_log TO gt_alv_log.
          lv_prefix_flag = 'X'.
        ENDIF.
      ENDIF.
******************Validating Password*********************
*      Place declaration at beginning
* replace constants lv_ to lc_
*   Revise validatiing passowrd logic wr.t IF condition
      lv_passfix = lv_passlen.
      lv_str = strlen( gwa_load-password ).
      SEARCH gwa_load-password FOR '@'.
      IF sy-subrc <> 0.
        SEARCH gwa_load-password FOR '_'.
        IF sy-subrc <> 0.
          lv_prefix_flag = 'X'.
        ENDIF.
      ENDIF.
      IF gwa_load-password IS INITIAL.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-014.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.

      ELSEIF ( ( lv_prefix_flag EQ 'X' ) ) AND ( gwa_load-password IS NOT INITIAL ).
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-014.
        gwa_alv_log-remark = TEXT-015.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.

      ELSEIF  ( lv_str  GE lv_pass_lower ) AND (  lv_str LT lv_passlen ).
        CONCATENATE 'Not maintained with minimum length (' lv_passfix 'characters )' INTO lv_concat SEPARATED BY space.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-014.
        gwa_alv_log-remark = lv_concat.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.
      ENDIF.
****Clearing
      CLEAR: lv_concat, lv_str, lv_passfix.
******************Validating Mobile_Number******************
      lv_str = lv_mbl.
      IF ( ( strlen( gwa_load-mobile ) GE lv_mbl_lower ) AND ( strlen( gwa_load-mobile ) LT lv_mbl ) ).
        CONCATENATE '<' lv_str 'digits' INTO lv_concat SEPARATED BY space.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-016.
        gwa_alv_log-remark = lv_concat.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.
      ENDIF.
      IF ( gwa_load-mobile IS INITIAL ).
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-016.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_prefix_flag = 'X'.
      ENDIF.
****Clearing
      CLEAR : lv_str, lv_concat.

*********Generating Customer_number
      ADD 1 TO lv_countcust.
      lv_counts = lv_countcust.
      SPLIT gwa_final-prefix AT '.' INTO DATA(lv_front) DATA(lv_back).
      CONCATENATE lv_front lv_cust lv_counts INTO lv_cust_number.
*************Validating Flag && Customer_Number**************
      IF lv_prefix_flag <> 'X'.

*********Generating Customer_number
*        ADD 1 TO lv_countcust.
*        lv_counts = lv_countcust.
*        SPLIT gwa_final-prefix AT '.' INTO DATA(lv_front) DATA(lv_back).
*        CONCATENATE lv_front lv_cust lv_counts INTO lv_cust_number.

********Field mapping to Cust_detail Work area.
        gwa_cust_details-prefix = gwa_final-prefix.
        gwa_cust_details-customer_number = lv_cust_number.
        gwa_cust_details-customer_name = gwa_load-customer_name.
        gwa_cust_details-aadhar_number = gwa_load-aadhar.
        gwa_cust_details-permanent_address = gwa_load-address.
        gwa_cust_details-mobile_number = gwa_load-mobile.
        gwa_cust_details-mail_id = gwa_load-mail.
        gwa_cust_details-password = gwa_load-password.

*******Appending to Cust_detail Internal table.
        APPEND gwa_cust_details TO gt_cust_details.
      ENDIF.
    ENDAT.

***************End Of Control Break Statement*************
**********************************************************
****************Validating Booking Data*******************

*********Validating for empty booking Records.
    IF gwa_load-room_type IS INITIAL.
      IF gwa_load-occupation_date IS INITIAL.
        IF gwa_load-occupation_time IS INITIAL.
          IF gwa_load-vacate_date IS INITIAL.
            IF gwa_load-vacate_time IS INITIAL.
              IF gwa_load-reason_for_stay IS INITIAL.
                IF gwa_load-source IS INITIAL.
                  IF gwa_load-allot_by IS INITIAL.
                    DATA(lv_booking_flag) = 'X'. "If whole record for booking is empty, flag will be enabled.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_booking_flag <> 'X'. "no flag initiated inside the program.
*********Validating Room_type.
      TRANSLATE gwa_load-room_type TO UPPER CASE.
      CASE gwa_load-room_type.
        WHEN 'O'.
          gwa_final-room_type = gwa_load-room_type.
          gwa_booking-room_type = gwa_final-room_type."mapping to booking work area.

        WHEN 'L'.
          gwa_final-room_type = gwa_load-room_type.
          gwa_booking-room_type = gwa_final-room_type."mapping to booking work area.

        WHEN 'S'.
          gwa_final-room_type = gwa_load-room_type.
          gwa_booking-room_type = gwa_final-room_type."mapping to booking work area.

        WHEN 'P'.
          gwa_final-room_type = gwa_load-room_type.
          gwa_booking-room_type = gwa_final-room_type."mapping to booking work area.

        WHEN OTHERS.

          IF ( gwa_load-room_type IS INITIAL )."Move code to WHEN OTHERS and place 379 code in ELSE part
            gwa_alv_log-record_no = gwa_load-record_no.
            gwa_alv_log-field = TEXT-017.
            gwa_alv_log-remark = TEXT-008.
            APPEND gwa_alv_log TO gt_alv_log.
            lv_booking_flag = 'X'.

          ELSE.
            CONCATENATE '<' gwa_load-room_type '>' TEXT-018 INTO DATA(lv_flagmsg) SEPARATED BY space.
            gwa_alv_log-record_no = gwa_load-record_no.
            gwa_alv_log-field = TEXT-017.
            gwa_alv_log-remark = lv_flagmsg.
            APPEND gwa_alv_log TO gt_alv_log.
            lv_booking_flag = 'X'.
          ENDIF.

      ENDCASE.
****************Validating Room_number******************
*-------Bypass the room number logic if room type flag is not initial
      IF lv_booking_flag <> 'X'.
        lv_ctot_rooms = lv_tot_rooms.
        lv_cfloor_num = lv_floor_num.

        CASE gwa_load-room_type.
          WHEN 'O'.
            IF lv_tot_rooms LE c_total_rooms.
              CONCATENATE gwa_load-room_type lv_floor lv_cfloor_num lv_seperator lv_ctot_rooms
                          INTO lv_room_number.
              ADD 1 TO lv_tot_rooms.
              IF ( lv_tot_rooms GT c_total_rooms ).
                ADD 1 TO lv_floor_num.
                lv_tot_rooms = 1.
              ENDIF.
              gwa_booking-room_number = lv_room_number."mapping to booking work area.
            ENDIF.

*          ADD 1 to lv_tot_rooms.
*          if lv_tot_rooms gt 5.
*            ADD 1 to lv_floor_num.
*            lv_tot_rooms = 1.
*          ENDIF.
*          CONCATENATE gwa_load-room_type lv_floor lv_cfloor_num lv_seperator lv_ctot_rooms
*                        INTO lv_room_number.

          WHEN 'L'.
            IF lv_tot_rooms LE c_total_rooms.
              CONCATENATE gwa_load-room_type lv_floor lv_cfloor_num lv_seperator lv_ctot_rooms
                          INTO lv_room_number.
              ADD 1 TO lv_tot_rooms.
              IF ( lv_tot_rooms GT c_total_rooms ).
                ADD 1 TO lv_floor_num.
                lv_tot_rooms = 1.
              ENDIF.
              gwa_booking-room_number = lv_room_number."mapping to booking work area.
            ENDIF.

          WHEN 'S'.
            IF lv_tot_rooms LE c_total_rooms.
              CONCATENATE gwa_load-room_type lv_floor lv_cfloor_num lv_seperator lv_ctot_rooms
                          INTO lv_room_number.
              ADD 1 TO lv_tot_rooms.
              IF ( lv_tot_rooms GT c_total_rooms ).
                ADD 1 TO lv_floor_num.
                lv_tot_rooms = 1.
              ENDIF.
              gwa_booking-room_number = lv_room_number."mapping to booking work area.
            ENDIF.

          WHEN 'P'.
            IF lv_tot_rooms LE c_total_rooms.
              CONCATENATE gwa_load-room_type lv_floor lv_cfloor_num lv_seperator lv_ctot_rooms
                          INTO lv_room_number.
              ADD 1 TO lv_tot_rooms.
              IF ( lv_tot_rooms GT c_total_rooms ).
                ADD 1 TO lv_floor_num.
                lv_tot_rooms = 1.
              ENDIF.
              gwa_booking-room_number = lv_room_number."mapping to booking work area.
            ENDIF.

        ENDCASE.
*******converting char type vacate_date to date type.
*---change split statement
        lv_date = gwa_load-vacate_date."01.01.2022
        SPLIT lv_date AT '.' INTO DATA(before) DATA(after).
        SPLIT after AT '.' INTO DATA(first) DATA(last).
        CONCATENATE last first before INTO lv_fin.
        lv_final = lv_fin.
*******converting char type Occupation_date to date type.
        lv_date_1 = gwa_load-occupation_date.
        SPLIT lv_date_1 AT '.' INTO DATA(before1) DATA(after1).
        SPLIT after1 AT '.' INTO DATA(first1) DATA(last1).
        CONCATENATE last1 first1 before1 INTO lv_fin1.
        lv_final1 = lv_fin1.

*************Validating which is Greater OD or VD and Validating room price**************
        IF ( lv_final LT lv_final1 ).
          gwa_alv_log-record_no = gwa_load-record_no.
          gwa_alv_log-field = TEXT-023.
          gwa_alv_log-remark = TEXT-025.
          APPEND gwa_alv_log TO gt_alv_log.
          lv_booking_flag = 'X'.

        ELSEIF ( lv_final GT lv_final1 ).
          IF ( ( gwa_load-vacate_date IS NOT INITIAL ) AND ( gwa_load-vacate_time IS NOT INITIAL ) ).
            gv_nod = lv_final - lv_final1.
            READ TABLE lt_ztprice INTO DATA(wa_ztprice) WITH KEY room_type = gwa_load-room_type.
            IF sy-subrc EQ 0.
              lv_total_price = ( ( wa_ztprice-price + wa_ztprice-tax + wa_ztprice-maintenance_charges ) * gv_nod ).
              gwa_booking-total_price = lv_total_price.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*****************Validating Occupation Date*******************
      IF gwa_load-occupation_date IS INITIAL.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-021.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_booking_flag = 'X'.
      ENDIF.
*****************Validating Occupation Time*******************
      IF gwa_load-occupation_time IS INITIAL.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-022.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_booking_flag = 'X'.
      ENDIF.
***************Validating Vacate Time && Date*****************
      IF ( ( gwa_load-vacate_date IS NOT INITIAL ) AND ( gwa_load-vacate_time IS INITIAL ) ).
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-024.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_booking_flag = 'X'.
      ENDIF.
      IF ( ( gwa_load-vacate_date IS INITIAL ) AND ( gwa_load-vacate_time IS NOT INITIAL ) ).
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-023.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_booking_flag = 'X'.
      ENDIF.

****************Validating Purpose of Stay******************
      IF gwa_load-reason_for_stay IS INITIAL.
        gwa_alv_log-record_no = gwa_load-record_no.
        gwa_alv_log-field = TEXT-026.
        gwa_alv_log-remark = TEXT-008.
        APPEND gwa_alv_log TO gt_alv_log.
        lv_booking_flag = 'X'.
      ENDIF.
*******************Validating employee Id*******************

      IF gwa_load-source EQ lc_source.
        IF ( gwa_load-allot_by IS INITIAL ).
          gwa_alv_log-record_no = gwa_load-record_no.
          gwa_alv_log-field = TEXT-028.
          gwa_alv_log-remark = TEXT-008.
          APPEND gwa_alv_log TO gt_alv_log.
          lv_booking_flag = 'X'.
        ENDIF.

        READ TABLE lt_emp INTO DATA(wa_emp) WITH KEY employee_id = gwa_load-allot_by.
        IF sy-subrc EQ 0.
          "field Mapping.(map booking table alloed name with employee name)
          gwa_booking-alloted_by = wa_emp-employee_id.
          gwa_booking-alloted_name = wa_emp-employee_name.

        ELSE.
          gwa_alv_log-record_no = gwa_load-record_no.
          gwa_alv_log-field = TEXT-029.
          gwa_alv_log-remark = TEXT-030.
          APPEND gwa_alv_log TO gt_alv_log.
          lv_booking_flag = 'X'.
        ENDIF.
      ENDIF.

      IF gwa_load-source <> lc_source.
        READ TABLE lt_emp INTO wa_emp WITH KEY employee_id = gwa_load-allot_by.
        "field Mapping.
        gwa_booking-alloted_by = wa_emp-employee_name.
        lv_booking_flag = 'X'.
      ENDIF.
****************Field Mapping******************
      gwa_booking-cutomer_number = lv_cust_number.
      gwa_booking-customer_name = lv_name."gwa_cust_details-customer_name. "gwa_load-customer_name
      gwa_booking-occupation_date = gwa_load-occupation_date.
      gwa_booking-occupation_time = gwa_load-occupation_time.
      gwa_booking-vacate_date = gwa_load-vacate_date.
      gwa_booking-number_of_days = gv_nod.
      gwa_booking-room_price = wa_ztprice-price.
      gwa_booking-vacate_time = gwa_load-vacate_time.
      gwa_booking-purpose_of_stray = gwa_load-reason_for_stay.
      gwa_booking-source = gwa_load-source.

***************End of Field Mapping************

********************Loading Work Area to booking Itab*********************
      IF lv_booking_flag <> 'X'.
        APPEND gwa_booking TO gt_booking.
      ENDIF.

    ENDIF.
****Merging Header and Line Items data into Main table.
    MOVE-CORRESPONDING gwa_load TO gwa_alv_merge.
    gwa_alv_merge-room_number = gwa_booking-room_number.
    gwa_alv_merge-number_of_days = gwa_booking-number_of_days.
    gwa_alv_merge-room_price = gwa_booking-room_price.
    gwa_alv_merge-total_price = gwa_booking-total_price.
    gwa_alv_merge-alloted_name = gwa_booking-alloted_name.

    IF lv_prefix_flag <> 'X' AND lv_booking_flag <> 'X'.
      APPEND gwa_alv_merge TO gt_alv_merge.
    ENDIF.

*****************End of validating empty booking Records******************
******Clear statments are missing for booking items.
    CLEAR :gwa_load, gwa_final,gwa_alv_log,gwa_booking,lv_booking_flag,lwa_load,gwa_cust_details,gwa_alv_merge,
           lv_prefix_flag, lv_booking_flag,lv_date,before,after,last,lv_fin,lv_date_1,before1,
           after1,last1,lv_fin1,lv_final,lv_final1,wa_ztprice,gv_nod,lv_total_price,
           lv_room_number,lv_cfloor_num,lv_ctot_rooms,lv_flagmsg.
  ENDLOOP.

  if sy-subrc = 0.
    endif.
***************End of the single record validation.***********************
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .
*******Field Catalog.
  DATA : lv_count    TYPE i VALUE 0,
         gt_fieldcat TYPE slis_t_fieldcat_alv.
  ADD 1 TO lv_count.
  APPEND VALUE #( col_pos = lv_count fieldname = 'Record_No'
                  seltext_s = 'Record Number' ) TO gt_fieldcat.

  ADD 1 TO lv_count.
  APPEND VALUE #( col_pos = lv_count fieldname = 'Field'
                  seltext_s = 'Field' ) TO gt_fieldcat.

  ADD 1 TO lv_count.
  APPEND VALUE #( col_pos = lv_count fieldname = 'Remark'
                  seltext_s = 'Remark' ) TO gt_fieldcat.

*******Events.
  CONSTANTS : lv_event_type TYPE c VALUE '4'.
  DATA : lt_events TYPE slis_t_event,
         lv_type   TYPE slis_list_type.
  lv_type = lv_event_type.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = lv_type
    IMPORTING
      et_events       = lt_events
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  IF lt_events IS NOT INITIAL.

    DATA(lwa_events) = lt_events[ 3 ].
    lwa_events-form = 'TOP_OF_PAGE'.
    MODIFY lt_events FROM lwa_events INDEX 3.
    CLEAR: lwa_events.

    lwa_events = lt_events[ 12 ].
    lwa_events-form = 'END_OF_LIST'.
    MODIFY lt_events FROM lwa_events INDEX 12.
    CLEAR:lwa_events.
  ENDIF.


*******Layout.
  wa_layout-zebra = 'X'.
  wa_layout-colwidth_optimize = 'X'.

  IF p_alv EQ abap_true.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program      = sy-repid
        i_callback_user_command = 'USR_CMD'
        is_layout               = wa_layout
        it_fieldcat             = gt_fieldcat
        it_events               = lt_events
      TABLES
        t_outtab                = gt_alv_log
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.

  ELSE.
    CALL FUNCTION 'ZEXCEL_TO_CUST_DETAILS_DB' IN UPDATE TASK
      EXPORTING
        im_cust_details = gt_cust_details
        im_bookings     = gt_booking.

    IF sy-subrc EQ 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.
*   prefix          TYPE zprefix_de_minipro,
*          customer_number TYPE zcustnum_de_minipro,
*          customer_name   TYPE zcustname_de_minipro,
*          aadhar          TYPE string,
*          address         TYPE zpermanent_addr_de_minipro,
*          mobile          TYPE zmobile_num_de_minipro,
*          mail            TYPE zmail_id_de_minipro,
*          password        TYPE zpassword_de_minipro,
*          room_type       TYPE zroom_type_de_minipro,
*          room_number     TYPE zroom_number_de_minipro,
*          occupation_date TYPE zoccupation_date_de_minipro,
*          occupation_time TYPE zoccupation_time_de_minipro,
*          vacate_date     TYPE zvacate_date_de_minipro,
*          vacate_time     TYPE zvacate_time_de_minipro,
*          number_of_days  TYPE znumber_of_days_de_minipro,
*          room_price      TYPE dmbtr,
*          total_price     TYPE dmbtr,
*          reason_for_stay TYPE zpurpose_of_stay_de_minipro,
*          source          TYPE zsource_de_minipro,
*          allot_by        TYPE zalloted_by_de_minipro,
*          alloted_name    TYPE zalloted_name_de_minipro,


  IF p_txt EQ abap_true.
    DATA: lv_filepath TYPE string VALUE 'Desktop'."'C:\Users\S20abaph54\Downloads'.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = lv_filepath
        filetype                = 'ASC'
        write_field_separator   = 'X'
      TABLES
        data_tab                = gt_alv_merge
*       fieldnames              =
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.

*  ELSEIF p_exl EQ abap_true.
*    DATA : lv_exceldownload TYPE rlgrap-filename VALUE 'Desktop'.
*
*    CALL FUNCTION 'MS_EXCEL_OLE_STANDARD_DAT'
*      EXPORTING
*        file_name                 = lv_exceldownload
*        file_type                 = 'XLS'
*      TABLES
*        data_tab                  = gt_alv_merge
*      EXCEPTIONS
*        file_not_exist            = 1
*        filename_expected         = 2
*        communication_error       = 3
*        ole_object_method_error   = 4
*        ole_object_property_error = 5
*        invalid_pivot_fields      = 6
*        download_problem          = 7
*        OTHERS                    = 8.
**    CALL FUNCTION 'GUI_DOWNLOAD'
*
*      EXPORTING
*        filename                = lv_filepath
*        filetype                = 'ASC'
*        write_field_separator   = 'X'
**       HEADER                  = '00'
*      TABLES
*        data_tab                = gt_alv_merge
**       fieldnames              =
*      EXCEPTIONS
*        file_write_error        = 1
*        no_batch                = 2
*        gui_refuse_filetransfer = 3
*        invalid_type            = 4
*        no_authority            = 5
*        unknown_error           = 6
*        header_not_allowed      = 7
*        separator_not_allowed   = 8
*        filesize_not_allowed    = 9
*        header_too_long         = 10
*        dp_error_create         = 11
*        dp_error_send           = 12
*        dp_error_write          = 13
*        unknown_dp_error        = 14
*        access_denied           = 15
*        dp_out_of_memory        = 16
*        disk_full               = 17
*        dp_timeout              = 18
*        file_not_found          = 19
*        dataprovider_exception  = 20
*        control_flush_error     = 21
*        OTHERS                  = 22.
  ENDIF.
***********
  IF sy-subrc = 0.
  ENDIF.
***********
ENDFORM.
FORM top_of_page.
  DATA:lt_head TYPE slis_t_listheader.
  lt_head = VALUE #( ( typ = 'H' info = 'Excel To Database Log' )
                     ( typ = 'S' key = 'Date' info = sy-datum )
                     ( typ = 'S' key = 'User' info = sy-uname ) ).
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_head
      i_logo             = 'ALVLOG'.
ENDFORM.

FORM end_of_list.
  DATA : lt_footer TYPE slis_t_listheader.
  lt_footer = VALUE #( ( typ = 'A' info = TEXT-032 ) ).
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_footer.

ENDFORM.
