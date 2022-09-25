USE AccountingDB;
GO
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Transaction')
BEGIN
	CREATE TABLE  [Transaction]
	(
		TransactionId BIGINT IDENTITY(1,1) NOT NULL
		, Number	NVARCHAR(MAX) NOT NULL
		, ContactId BIGINT NOT NULL
		, [Description] NVARCHAR(MAX) NULL
		, TotalIncludingTax DECIMAL NOT NULL
		, TotalExcludingTax DECIMAL NOT NULL
		, TaxAmount DECIMAL NULL
		, CONSTRAINT TransactionId_pk PRIMARY KEY NONCLUSTERED (TransactionId)
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Contact')
BEGIN
	CREATE TABLE [Contact]
	(
		ContactId BIGINT IDENTITY(1,1) NOT NULL
		, DisplayName NVARCHAR(MAX) NULL
		, Suffix NVARCHAR(MAX) NULL
		, FirstName NVARCHAR(MAX) NOT NULL
		, MiddleName NVARCHAR(MAX) NULL
		, LastName NVARCHAR(MAX) NOT NULL
		, CompanyName NVARCHAR(MAX) NULL
		, PrimaryPhoneNumber NVARCHAR(MAX) NULL
		, CONSTRAINT contactId_pk PRIMARY KEY NONCLUSTERED (ContactId)
	)
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TransactionLineItems')
BEGIN
	CREATE TABLE [TransactionLineItems]
	(
		TransactionItemId BIGINT IDENTITY(1,1) NOT NULL
		, TransactionId BIGINT NOT NULL
		, [Name] NVARCHAR(MAX) NULL
		, [Description] NVARCHAR(MAX) NULL
		, ProductName NVARCHAR(MAX) NULL
		, [Type] NVARCHAR(MAX) NOT NULL
		, Quantity BIGINT NOT NULL
		, TotalIncludingTax DECIMAL NOT NULL
		, TotalExcludingTax DECIMAL NOT NULL
		, TaxAmount DECIMAL NOT NULL
		, UnitPrice DECIMAL NOT NULL
		,  CONSTRAINT transactionItemId_pk PRIMARY KEY NONCLUSTERED (TransactionItemId)
	)
END
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_Contact_ContactId')
BEGIN
	ALTER TABLE [dbo].[Transaction] DROP CONSTRAINT [FK_Contact_ContactId]
END
GO

ALTER TABLE [Transaction] 
ADD CONSTRAINT FK_Contact_ContactId 
FOREIGN KEY (ContactId)
REFERENCES Contact (ContactId)
ON DELETE CASCADE
ON UPDATE CASCADE;

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_TransactionLineItems_TransactionId')
BEGIN
	ALTER TABLE [dbo].[TransactionLineItems] DROP CONSTRAINT [FK_TransactionLineItems_TransactionId]
END
GO

ALTER TABLE [TransactionLineItems]
ADD CONSTRAINT FK_TransactionLineItems_TransactionId
FOREIGN KEY (TransactionId)
REFERENCES [Transaction] (TransactionId)
ON DELETE CASCADE
ON UPDATE CASCADE;
