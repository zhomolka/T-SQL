USE [master]
GO

/****** Object:  LinkedServer [LDAP]    Script Date: 26.1.2017 15:37:17 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LDAPTest', @srvproduct=N'', @provider=N'ADsDSOObject'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LDAPTest',@useself=N'False',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LDAPTest',@useself=N'False',@locallogin=N'POJCS\cc-fs-prod',@rmtuser=N'POJCS\cc-fs-test',@rmtpassword='CallC2014*T'

GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LDAPTest', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


