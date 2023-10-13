*&---------------------------------------------------------------------*
*& Report ZLOAD_EXCEL_TO_DB
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zload_excel_to_db.


INCLUDE zexcel_to_db_dd.
INCLUDE zexcel_to_db_code.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath.
  PERFORM f4_file.
  skip 2.

START-OF-SELECTION.
  PERFORM load_to_itab.
  PERFORM display.
