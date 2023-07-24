while ($true) {
  Get-Process opensim* | Where-Object {$_.CPU -gt 5} | Kill -Force
  Start-Sleep 0.5
}