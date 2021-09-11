copy /y "\\DC\netlogon\sysmon\config.xml" "C:\windows\"
sysmon64 -c c:\windows\config.xml

sc query "Sysmon64" | find "RUNNING"
if "%ERRORLEVEL%" EQU "0" (
  goto end
)

"\\DC\netlogon\sysmon\sysmon64.exe" -accepteula -i c:\windows\config.xml
net start sysmon64
powershell -Command "& {Restart-Service Winlogbeat;}"

:end
