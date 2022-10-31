#Parameters
$url = "https://gismaps.unc.edu/arcgis/rest/services/HQ_BUILDINGS/MapServer/0/query?where=BL_ID+%3C%3E%27%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&distance=&units=esriSRUnit_Foot&relationParam=&outFields=bl_id%2Cname%2Carea_gros_bestest%2Cunc_land_ent_class_id&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&havingClause=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&returnExtentOnly=false&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&featureEncoding=esriDefault&f=pjson"

$destinationInstance = "localhost"
$destinationDB = "BFD"
$destinationSchema ="Staging"
$destinationTable = "SPOTS_HQ_QUANTITY"

#Load Required Types and modules
Import-Module SqlServer

$content = Invoke-WebRequest $url | ConvertFrom-Json
$features = $content.features

$dt = New-Object System.Data.Datatable
[void]$dt.Columns.Add("bl_id")
[void]$dt.Columns.Add("name")
[void]$dt.Columns.Add("area_gros_bestest")
[void]$dt.Columns.Add("unc_land_ent_class_id")

$features | ForEach-Object {  
    $bl_id = $_.attributes.bl_id
    $name = $_.attributes.name
    $area_gros_bestest = $_.attributes.area_gros_bestest
    $unc_land_ent_class_id = $_.attributes.unc_land_ent_class_id
    [void]$dt.Rows.Add($bl_id,$name,$area_gros_bestest,$unc_land_ent_class_id)
}

#Now you can do anything with the data inside of $resultset, we're uploading it to SQL Server just because
$dt | Write-DbaDbTableData -SqlInstance $destinationInstance -Database $destinationDB -Schema $destinationSchema -Table $destinationTable -Truncate  -BatchSize 10000 -EnableException