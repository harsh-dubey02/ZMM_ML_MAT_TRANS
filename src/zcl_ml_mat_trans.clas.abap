CLASS zcl_ml_mat_trans DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS get_pdf_64
      IMPORTING
        VALUE(io_MaterialDocument) TYPE I_MaterialDocumentHeader_2-MaterialDocument
      RETURNING
        VALUE(pdf_64)              TYPE string.

  PRIVATE SECTION.

    METHODS build_xml
      IMPORTING
        VALUE(io_MaterialDocument) TYPE I_MaterialDocumentHeader_2-MaterialDocument
      RETURNING
        VALUE(rv_xml)              TYPE string.

ENDCLASS.



CLASS ZCL_ML_MAT_TRANS IMPLEMENTATION.


  METHOD get_pdf_64.

    DATA(lv_xml) = build_xml( io_MaterialDocument = io_MaterialDocument ).

    IF lv_xml IS INITIAL.
      RETURN.
    ENDIF.

    CALL METHOD zadobe_ads_class=>getpdf
      EXPORTING
        template = 'ZML_MAT_TRANS/ZML_MAT_TRANS'
        xmldata  = lv_xml
      RECEIVING
        result   = DATA(lv_result).

    IF lv_result IS NOT INITIAL.
      pdf_64 = lv_result.
    ENDIF.

  ENDMETHOD.


  METHOD build_xml.

*--------------------------------------
* HEADER DATA
*--------------------------------------
    DATA:
      lv_docdate          TYPE i_materialdocumentheader_2-DocumentDate,
      lv_materialdocument TYPE i_materialdocumentheader_2-MaterialDocument,
      lv_dept             TYPE i_materialdocumentitem_2-IssuingOrReceivingStorageLoc,
      Lv_mat_desc         TYPE I_ProductDescription-ProductDescription,
      lv_pr_bt_cd         TYPE i_materialdocumentitem_2-MaterialDocumentItemText,
      lv_res_no           TYPE i_materialdocumentitem_2-Reservation,
      lv_dept_des         TYPE I_StorageLocation-StorageLocationName,
      lv_dept_no          TYPE I_StorageLocation-StorageLocation,
      Lv_mat_doc          TYPE i_materialdocumentitem_2-MaterialDocumentItemText,
      Lv_mat_bt           TYPE i_materialdocumentitem_2-Batch,
      Lv_mat_quan         TYPE i_materialdocumentitem_2-QuantityInBaseUnit,
      Lv_mat              TYPE i_materialdocumentitem_2-Material,
      lv_stor_loc         TYPE i_materialdocumentitem_2-StorageLocation,
      lv_mt_dt            TYPE i_materialdocumentitem_2-PostingDate,
      lv_year             TYPE string,
      lv_month            TYPE string,
      lv_day              TYPE string,
      lv_month_name       TYPE string,
      lv_doc_date_text    TYPE string,
      lv_sr_no            TYPE i VALUE 0.

*--------------------------------------
* READ MATERIAL DOCUMENT
*--------------------------------------
    SELECT
     a~materialdocument,
     c~productdescription,
     b~QuantityInBaseunit,
     b~reservation,
     b~PostingDate,
     b~material,
     b~Batch,
     b~storagelocation,
     b~IssuingOrReceivingStorageLoc,
     b~materialdocumentitemtext,
     b~isautomaticallycreated
*    d~storageLocationName
 FROM i_materialdocumentheader_2 AS a
 INNER JOIN i_materialdocumentitem_2 AS b
     ON a~MaterialDocument = b~MaterialDocument
 LEFT OUTER JOIN I_ProductDescription AS c
     ON b~Material = c~Product
    AND c~Language = @sy-langu
*LEFT OUTER JOIN I_StorageLocation AS d
*    ON b~Plant = d~Plant
* AND b~IssuingOrReceivingStorageLoc = d~StorageLocation
 WHERE b~materialdocument = @io_materialDOCUMENT
   AND b~IsAutomaticallyCreated <> 'X'
 INTO TABLE @DATA(it_matdoc).

    IF it_matdoc IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE it_matdoc INTO DATA(ls_first) INDEX 1.


*         SELECT SINGLE *
*   FROM I_StorageLocation
*   WHERE StorageLocation = @ls_first-IssuingOrReceivingStorageLoc
*   INTO @DATA(wa_storeloc).

    SELECT
        a~MaterialDocument,
        a~MaterialDocumentYear,
        a~MaterialDocumentHeaderText,
        b~MaterialDocumentItem,
        b~goodsMovementType,
        b~StorageLocation,
        b~IssuingOrReceivingStorageLoc
    FROM I_MaterialDocumentHeader_2 AS a
    INNER JOIN I_MaterialDocumentItem_2 AS b
        ON a~MaterialDocument     = b~MaterialDocument
       AND a~MaterialDocumentYear = b~MaterialDocumentYear
    WHERE b~goodsMovementType = '315'
    AND b~IsAutomaticallyCreated <> 'X'
    INTO TABLE @DATA(it_matdoc_loc).

 READ TABLE it_matdoc_loc INTO DATA(lv_first) INDEX 1.

    SELECT SINGLE *
    FROM I_StorageLocation
    WHERE StorageLocation = @lv_first-StorageLocation
    INTO @DATA(wa_dept).


    SELECT SINGLE *
FROM I_StorageLocation
WHERE StorageLocation = @ls_first-StorageLocation
INTO @DATA(wa_deptc).

*--------------------------------------
* HEADER DATA — FIRST RECORD
*--------------------------------------


    lv_dept             = ls_first-IssuingOrReceivingStorageLoc.
*    lv_dept_des         = ls_first-StorageLocationName.
*    lv_res          =      ls_first-Reservation.
    lv_stor_loc       =    ls_first-StorageLocation.
*    lv_res_dt        =    ls_first-MatlCompRequirementDate.
    lv_mt_dt       = ls_first-PostingDate.

    READ TABLE it_matdoc INTO DATA(ls_matdoc_item) INDEX 1.

    Lv_mat_desc = ls_matdoc_item-ProductDescription.
    Lv_mat = ls_matdoc_item-Material.
    Lv_mat_doc = ls_matdoc_item-MaterialDocumentItemText.
    Lv_mat_bt = ls_matdoc_item-Batch.
    Lv_mat_quan = ls_matdoc_item-QuantityInBaseUnit.

    lv_docdate = ls_first-PostingDate.
    IF lv_docdate IS NOT INITIAL.
      lv_year  = lv_docdate+0(4).
      lv_month = lv_docdate+4(2).
      lv_day   = lv_docdate+6(2).

      CASE lv_month.
        WHEN '01'. lv_month_name = '01'.
        WHEN '02'. lv_month_name = '02'.
        WHEN '03'. lv_month_name = '03'.
        WHEN '04'. lv_month_name = '04'.
        WHEN '05'. lv_month_name = '05'.
        WHEN '06'. lv_month_name = '06'.
        WHEN '07'. lv_month_name = '07'.
        WHEN '08'. lv_month_name = '08'.
        WHEN '09'. lv_month_name = '09'.
        WHEN '10'. lv_month_name = '10'.
        WHEN '11'. lv_month_name = '11'.
        WHEN '12'. lv_month_name = '12'.
        WHEN OTHERS. lv_month_name = ''.
      ENDCASE.

      lv_doc_date_text = |{ lv_day }-{ lv_month_name }-{ lv_year }|.
    ELSE.
      lv_doc_date_text = 'N/A'.
    ENDIF.

    SELECT
  a~storagelocation,
  a~storagelocationname,
  b~IssuingOrReceivingStorageLoc
  FROM I_StorageLocation AS a
  INNER JOIN i_materialdocumentitem_2 AS b
   ON b~StorageLocation = a~StorageLocation
  INTO TABLE @DATA(it_matdoc_desc).

    READ TABLE it_matdoc_desc INTO DATA(ls_first_desc) INDEX 1.


    lv_dept_no             = ls_first_desc-StorageLocation.
    lv_dept_des         = ls_first_desc-StorageLocationName.
    lv_dept            = ls_first_desc-IssuingOrReceivingStorageLoc.

*--------------------------------------
* XML HEADER
*--------------------------------------
    DATA(lv_header) =
     |<form1>| &&
     |   <Subform2>| &&
     |      <SUBFORM3>| &&
     |         <fields_subform>| &&
     |            <ISSUED_FOR>{ lv_res_no }</ISSUED_FOR>| &&
     |            <ISS_DOC_DATE>{ lv_doc_date_text }</ISS_DOC_DATE>| &&
     |            <ISS_DOC_NO>{ IO_materialdocument }</ISS_DOC_NO>| &&
     |            <FROM>{ wa_deptc-StorageLocationName },{ ls_first-StorageLocation }</FROM>| &&
     |            <DEPT>{ wa_dept-StorageLocationName },{ lv_first-StorageLocation }</DEPT>| &&
     |         </fields_subform>| &&
     |         <SUBFORM4>| &&
     |            <Table1>| &&
     |               <HeaderRow/>|.

*--------------------------------------
* XML ITEMS
*--------------------------------------
    DATA(lv_items) = ``.

    LOOP AT it_matdoc INTO DATA(ls_matdoc).
      lv_sr_no += 1.
      SHIFT ls_first-Material LEFT DELETING LEADING '0'.
      lv_items &&=                                      "#EC CI_NOORDER

        |               <Row1>| &&
        |                  <SR_NO>{ lv_sr_no }</SR_NO>| &&
        |                  <MATERIALNO>{ ls_first-Material }</MATERIALNO>| &&
        |                  <MATERIAL_DES>{ ls_first-ProductDescription }</MATERIAL_DES>| &&
        |                  <QUANTITY>{ ls_first-QuantityInBaseUnit }</QUANTITY>| &&
        |                  <BATCH>{ ls_first-Batch }</BATCH>| &&
        |                  <PR_BT_CD>{ ls_first-MaterialDocumentItemText }</PR_BT_CD>| &&
        |               </Row1>|.

    ENDLOOP.

*--------------------------------------
* XML FOOTER
*--------------------------------------
    DATA(lv_footer) =
     |            </Table1>| &&
     |            <SUBFORM5/>| &&
     |         </SUBFORM4>| &&
     |      </SUBFORM3>| &&
     |   </Subform2>| &&
     |</form1>|.

*--------------------------------------
* FINAL XML
*--------------------------------------
    rv_xml = |{ lv_header }{ lv_items }{ lv_footer }|.
  ENDMETHOD.
ENDCLASS.
