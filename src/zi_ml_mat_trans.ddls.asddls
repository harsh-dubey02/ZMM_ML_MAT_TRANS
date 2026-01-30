@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface for ML material transfer'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_ML_MAT_TRANS   as select from    ZI_MAT_TRANS_N as a
    left outer join ztb_ml_mat_trans     as b on a.Materialdocument = b.materialdocument

{
  key a.Materialdocument,
      b.base64_3 as base64,
      b.m_ind

}
