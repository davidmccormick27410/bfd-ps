#Parameters
$OracleDLLPath = "F:\downloads\Oracle.ManagedDataAccess.dll"

#The oracle DataSource as you would compile it in TNSNAMES.ORA
$datasource = Get-Content C:\UNC\lodestar_ds.txt
$username = Get-Content C:\UNC\lodestar_user.txt
$password = Get-Content C:\UNC\lodestar_pw.txt

$queryStatment = "SELECT uidaccountclass, accountclasscode, accountclassname, lsuser, lstime from accountclass" #Be careful not to terminate it with a semicolon, it doesn't like it

$destinationInstance = "localhost"
$destinationDB = "Lodestar"
$destinationSchema ="dbo"
$destinationTable = "ACCOUNTCLASS"

#Actual Code

#Load Required Types and modules
Add-Type -Path $OracleDLLPath
Import-Module SqlServer

#Create the connection string
$connectionstring = 'User Id=' + $username + ';Password=' + $password + ';Data Source=' + $datasource 

#Create the connection object
$con = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($connectionstring)

#Create a command and configure it
$cmd = $con.CreateCommand()
$cmd.CommandText = $queryStatment
$cmd.CommandTimeout = 3600 #Seconds
$cmd.FetchSize = 10000000 #10MB

#Creates a data adapter for the command
$da = New-Object Oracle.ManagedDataAccess.Client.OracleDataAdapter($cmd);
#The Data adapter will fill this DataTable
$resultSet = New-Object System.Data.DataTable

#Only here the query is sent and executed in Oracle 
[void]$da.fill($resultSet)

#Close the connection
$con.Close()


#Now you can do anything with the data inside of $resultset, we're uploading it to SQL Server just because
$resultSet | Write-DbaDbTableData -SqlInstance $destinationInstance -Database $destinationDB -Schema $destinationSchema -Table $destinationTable -Truncate  -BatchSize 10000 -EnableException