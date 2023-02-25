#Requires -RunAsAdministrator
<# USAGE
& '\\auto-contact.com\das\4 - Departments\K - Support & Operations\Operations\bdd\SQL\upgrade_2014\update_SQL_SP3.ps1'
#>

$exe = '\\auto-contact.com\das\4 - Departments\K - Support & Operations\Operations\bdd\SQL\upgrade_2014\SQLServer2014SP3-KB4022619-x64-ENU.exe'

#===================================================================================================
# MAIN
$ErrorActionPreference = 'Stop'
try
{
	write-host "$($env:computername)\$instance" -foregroundcolor red -backgroundcolor white
	$date = get-date
	write-host "START $date" -foregroundcolor cyan

	Start-Process -verb runas -Wait -FilePath $exe -ArgumentList `
		'/ACTION="Patch"',`
		'/IACCEPTSQLSERVERLICENSETERMS="true"',`
		# '/UpdateEnabled="true"',`
		# "/UpdateSource=`"$update_source`"",`
		'/INDICATEPROGRESS="true"',
		"/AllInstances",`
		# "/INSTANCENAME=`"$instance`"",`
		'/QUIETSIMPLE="true"',`
		# '/QUIET="false"',` #ok
		# '/UIMODE="Normal"',`
		'/SkipRules=RebootRequiredCheck'


# /qs /IAcceptSQLServerLicenseTerms /ACTION=Patch /UpdateEnabled=True /UpdateSource=$update_source /AllInstances
}
catch
{
	write-host 'catch main' -fore red
	write-output $_.Exception.ToString()

	exit 1
}
finally
{
	write-host "End $(get-date)" -foregroundcolor cyan
}
# END MAIN
#===================================================================================================
