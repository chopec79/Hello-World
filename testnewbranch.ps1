# Clearing Console Window
Clear-Host
# Set Error Preference
#$ErrorActionPreference = 'silentlycontinue'
# BEGIN SCRIPT RUN
Write-Host "-----------------------------------------------------"
Write-host "|       Rebuilding Nintex Workflow Inventory        |"
Write-Host "-----------------------------------------------------"
Write-Host ""
Write-progress -Activity "Adding snapins and assemblies to PowerShell session..." -Id 1 -PercentComplete "5" -Status "Adding SharePoint Snap-ins"
#Adding SharePoint Powershell Snapin
Add-PSSnapin Microsoft.SharePoint.PowerShell -EA silentlycontinue
Write-progress -Activity "Adding snapins and assemblies to PowerShell session..." -Id 1 -PercentComplete "8" -Status "Adding Nintex Assemblies"
 
# Loading SharePoint and Nintex assemblies into the PS session
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
[void][System.Reflection.Assembly]::LoadWithPartialName("Nintex.Workflow")
[void][System.Reflection.Assembly]::LoadWithPartialName("Nintex.Workflow.SupportConsole")
[void][System.Reflection.Assembly]::LoadWithPartialName("Nintex.Workflow.Administration")
Write-progress -Activity "Opening a connection to the Nintex Configuration Database..." -Id 1 -PercentComplete "15" -Status "Please Wait."
# Grab Nintex Config database name
$CFGDB = [Nintex.Workflow.Administration.ConfigurationDatabase]::OpenConfigDataBase().Database
Start-sleep -Seconds 5
Write-progress -Activity "Opening a connection to the Nintex Database..." -Id 1 -PercentComplete "25" -Status "Processing Databases"
#Creating an instance of the .net SQL Client
$cmd = New-Object -TypeName System.Data.SqlClient.SqlCommand
$cmd.CommandType = [System.Data.CommandType]::Text
$cmd.CommandTimeout = '0'
$Cmd.CommandText = "TRUNCATE Table dbo.workflows;" #TRUNCATING Tables
Write-progress -Activity "Opening a connection to the Nintex Database..." -Id 1 -PercentComplete "50" -Status "Clearing existing WF history Data."
#Removing existing WF inventory from Nintex databases
Write-Host "Clearing existing WF Inventory from Nintex databases..."
Write-Host ""
 foreach ($database in [Nintex.Workflow.Administration.ConfigurationDatabase]::GetConfigurationDatabase().ContentDatabases)
{
 
    Write-host "     Clearing WF Inventory From DB:"$database.SqlConnectionString #-replace ".\[(.*?)\]." 
        $reader = $database.ExecuteReader($cmd)
}
Write-host ""
Write-progress -Activity "Rebuilding Workflow Inventory" -Id 1 -PercentComplete "50" -Status "Please Wait..."
#Repopulating Workflow Inventory Tables
Write-Host "----------"
Write-Host "Queuing new instance of the WF inventory Upgrade (SPTimer) job" 
TRY {
     
    [Nintex.Workflow.Administration.UpgradeHelper]::ScheduleInsertWorkflowDatabaseJob() 
    Write-Host "Done."
    }
CATCH {
    $ErrorMessage = $_.Exception.Message
    Write-Host "An error occured with the WF inventory rebuild job. Please contact Nintex support with the details below..."
    $ErrorMessage
}
#Finished!
Write-Host "----------"
Write-Host ""
Write-Host "The Nintex Workflow inventory rebuild is complete. "
