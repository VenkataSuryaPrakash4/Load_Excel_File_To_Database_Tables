*&---------------------------------------------------------------------*
*& Include          ZEXCEL_TO_DB_DD
*&---------------------------------------------------------------------*

*********************Structure Decleration*********************
TYPES : BEGIN OF ty_alv_merge,
          prefix          TYPE zprefix_de_minipro,
          customer_number TYPE zcustnum_de_minipro,
          customer_name   TYPE zcustname_de_minipro,
          aadhar          TYPE string,
          address         TYPE zpermanent_addr_de_minipro,
          mobile          TYPE zmobile_num_de_minipro,
          mail            TYPE zmail_id_de_minipro,
          password        TYPE zpassword_de_minipro,
          room_type       TYPE zroom_type_de_minipro,
          room_number     TYPE zroom_number_de_minipro,
          occupation_date TYPE zoccupation_date_de_minipro,
          occupation_time TYPE zoccupation_time_de_minipro,
          vacate_date     TYPE zvacate_date_de_minipro,
          vacate_time     TYPE zvacate_time_de_minipro,
          number_of_days  TYPE znumber_of_days_de_minipro,
          room_price      TYPE dmbtr,
          total_price     TYPE dmbtr,
          reason_for_stay TYPE zpurpose_of_stay_de_minipro,
          source          TYPE zsource_de_minipro,
          allot_by        TYPE zalloted_by_de_minipro,
          alloted_name    TYPE zalloted_name_de_minipro,
        END OF ty_alv_merge,

        BEGIN OF ty_fieldname,
          field_name TYPE char20,
        END OF ty_fieldname,

        BEGIN OF ty_excel_data,
          record_no       TYPE i,
          prefix          TYPE zprefix_de_minipro,
          customer_name   TYPE zcustname_de_minipro,
          aadhar          TYPE string, "zaadharnum_de_minipro,
          address         TYPE zpermanent_addr_de_minipro,
          mobile          TYPE zmobile_num_de_minipro,
          mail            TYPE zmail_id_de_minipro,
          password        TYPE zpassword_de_minipro,
          room_type       TYPE zroom_type_de_minipro,
          occupation_date TYPE zoccupation_date_de_minipro,
          occupation_time TYPE zoccupation_time_de_minipro,
          vacate_date     TYPE zvacate_date_de_minipro,
          vacate_time     TYPE zvacate_time_de_minipro,
          reason_for_stay TYPE zpurpose_of_stay_de_minipro,
          source          TYPE zsource_de_minipro,
          allot_by        TYPE zalloted_by_de_minipro,
        END OF ty_excel_data,

        BEGIN OF ty_alv_log,
          record_no TYPE i,
          field(20) TYPE c,
          remark    TYPE string,
        END OF ty_alv_log.




********************Data variiable Decleration****************
DATA : gt_excel_data    TYPE TABLE OF ty_excel_data,
       gt_alv_log       TYPE TABLE OF ty_alv_log,
       gt_final         TYPE TABLE OF ty_excel_data,
       gt_cust_details  TYPE TABLE OF ztcust_details,
       gt_booking       TYPE TABLE OF ztbooking,
       gt_alv_merge     TYPE TABLE OF ty_alv_merge,
       gt_fieldname type table of ty_fieldname,
       gwa_alv_merge    TYPE ty_alv_merge,
       gwa_cust_details TYPE ztcust_details,
       wa_layout        TYPE slis_layout_alv,
       gwa_booking      TYPE ztbooking,
       gwa_alv_log      TYPE ty_alv_log,
       gwa_final        TYPE ty_excel_data,
       gwa_excel_data   TYPE ty_excel_data,
       gv_fpath         TYPE ibipparms-path,
       customer_number  TYPE zcustnum_de_minipro,
       gv_nod           TYPE i.

********************Parameter Deceleration********************
*PARAMETER: p_fpath TYPE dynpread-fieldname,
*           p_alv AS CHECKBOX USER-COMMAND alv,
*           p_txt AS CHECKBOX USER-COMMAND txt.

SELECTION-SCREEN BEGIN OF BLOCK text-033 WITH FRAME TITLE TEXT-034.
  SELECTION-SCREEN SKIP 1.
  PARAMETER: p_fpath TYPE dynpread-fieldname.
  SELECTION-SCREEN SKIP 1.
  PARAMETERS:  p_alv AS CHECKBOX USER-COMMAND alv.
  SELECTION-SCREEN SKIP 1.

  PARAMETER: p_txt RADIOBUTTON GROUP rd_1 USER-COMMAND ucom,
             p_exl RADIOBUTTON GROUP rd_1.


SELECTION-SCREEN END OF BLOCK text-033.
