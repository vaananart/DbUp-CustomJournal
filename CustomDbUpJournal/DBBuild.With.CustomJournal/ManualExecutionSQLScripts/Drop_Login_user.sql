USE [AccountingDB]
GO
--SELECT s.name
--FROM sys.schemas s
--WHERE s.principal_id = USER_ID('serviceUser');

ALTER AUTHORIZATION ON SCHEMA::db_owner TO dbo;
ALTER AUTHORIZATION ON SCHEMA::db_datareader TO dbo;
ALTER AUTHORIZATION ON SCHEMA::db_datawriter TO dbo;
/****** Object:  User [serviceUser]    Script Date: 8/04/2022 21:14:01 ******/
DROP USER [serviceUser]
GO

USE [SchoolManagementDB]
GO
SELECT s.name
FROM sys.schemas s
WHERE s.principal_id = USER_ID('serviceUser');

ALTER AUTHORIZATION ON SCHEMA::db_owner TO dbo;
ALTER AUTHORIZATION ON SCHEMA::db_datareader TO dbo;
ALTER AUTHORIZATION ON SCHEMA::db_datawriter TO dbo;
/****** Object:  User [serviceUser]    Script Date: 8/04/2022 21:14:01 ******/
DROP USER [serviceUser]
GO


