@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'new interface for ML material transfer'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_MAT_TRANS_N as  select distinct from I_MaterialDocumentHeader_2 as a
       left outer join ztb_ml_mat_trans as b
       on  a.MaterialDocument = b.materialdocument
       left outer join I_MaterialDocumentItem_2 as c
      on  a.MaterialDocument = c.MaterialDocument
{
    key a.MaterialDocument as Materialdocument,
    c.GoodsMovementType
//    base64 as Base64,
//    base64_1 as Base641,
//    base64_2 as Base642,
//    base64_3 as Base643,
//    m_ind as MInd
}
where c.GoodsMovementType = '315'

