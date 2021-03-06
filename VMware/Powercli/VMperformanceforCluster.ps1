[CmdletBinding()]
Param(
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$v="", 		## vcenter FQDN
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$u,		## username
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$p, 		## password
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$tag, 		## filter got get VMs by
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$output="test.csv", 	## file to save report output
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$sortBy,   ## sort output
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$colour='#e6f2ff', ## table row colour
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$title=$v, ## report title
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$klas="table1" ## class to separate CSS styling from other HTML fragments
)

Set-Location -Path C:\scripts\vmware
. ".\code\statics.ps1"
$output = "D:\vmware-output\performance\$v`_ILHQ_perf_" + (get-date -Format "dd/MM/yyyy/HH/mm") + ".csv"

if( (login $v $u $p) -eq 0) {
	write-host " here"

	Get-VM | Where {$_.PowerState -eq "PoweredOn"}  | Select Name, Host, NumCpu, MemoryMB, `
	@{N="CPU Usage (Average) %"         ; E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average  -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}}, `
	@{N="Memory Usage (Average), %"     ; E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average  -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} , `
	@{N="Network Usage (Average), KBps" ; E={[Math]::Round((($_ | Get-Stat -Stat net.usage.average  -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} , `
	@{N="Disk Usage (Average), KBps"    ; E={[Math]::Round((($_ | Get-Stat -Stat disk.usage.average -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} , `
	@{N="total Read Latency"            ; E={[Math]::Round((($_ | Get-Stat -Stat total.Read.Latency -Start (Get-Date).AddDays(-30) -IntervalMins 5 | Measure-Object Value -Average).Average),2)}} |`
	Export-Csv -Path $output
} else {
	echo "Login failde"| Out-File $output
}