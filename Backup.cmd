set DATABASE=.\
set DBNAME=iCC

echo %date% %time% Start Backup  >>C:\Atlantis-Logs\Script.log

DEL C:\Atlantis-Backup\iCC_LOG_CYCLIC.bak
DEL C:\Atlantis-Backup\ASPNET_LOG_CYCLIC.bak

echo %date% %time% Old deleted >>C:\Atlantis-Logs\Script.log

SQLCMD -Q "backup log iCC to disk = N'C:\Atlantis-Backup\iCC_LOG_CYCLIC.bak'"
echo %date% %time% iCC LOG done >>C:\Atlantis-Logs\Script.log
SQLCMD -Q "backup log ASPNET_iCC to disk = N'C:\Atlantis-Backup\ASPNET_LOG_CYCLIC.bak'"
echo %date% %time% ASPNET_iCC LOG done >>C:\Atlantis-Logs\Script.log

SQLCMD -Q "backup database iCC to disk = N'C:\Atlantis-Backup\iCC_FULL.bak'"
echo %date% %time% iCC FULL done >>C:\Atlantis-Logs\Script.log
SQLCMD -Q "backup database ASPNET_iCC to disk = N'C:\Atlantis-Backup\ASPNET_FULL.bak'"
echo %date% %time% ASPNET_iCC FULL done >>C:\Atlantis-Logs\Script.log


echo %date% %time% End >>C:\Atlantis-Logs\Script.log
