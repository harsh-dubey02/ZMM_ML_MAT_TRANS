@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for ML material transfer'
@Metadata.allowExtensions: true
define root view entity ZC_ML_MAT_TRANS as projection on ZI_ML_MAT_TRANS
{
    key Materialdocument,
    base64,
    m_ind
}
