USE SchoolManagementDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PersonalInfo')
BEGIN
	CREATE TABLE PersonalInfo
	( 
		PersonalInfoId BIGINT IDENTITY(1,1) NOT NULL
		, Title NVARCHAR(MAX) NOT NULL
		, FamilyName NVARCHAR(MAX) NOT NULL
		, GivenName NVARCHAR(MAX) NOT NULL
		, MiddleName NVARCHAR(MAX) NOT NULL
		, FamilyNameFirst BIT NULL
		, PreferredFamilyName NVARCHAR(MAX) NOT NULL
		, PrferredFamilyNameFirst BIT NULL
		, PreferredGivenName NVARCHAR(MAX) NOT NULL
		, Suffix NVARCHAR(MAX) NOT NULL
		, FullName NVARCHAR(MAX) NOT NULL
		, DemographicsId BIGINT NOT NULL
		, CONSTRAINT personalInfoId_pk PRIMARY KEY NONCLUSTERED (PersonalInfoId)

	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Demographics')
BEGIN
	CREATE TABLE Demographics
	(
		DemographicId BIGINT IDENTITY(1,1) NOT NULL
		, IndigenousStatus NVARCHAR(MAX) NULL
		, Sex NVARCHAR(MAX) NULL
		, BirthDate DATE NULL
		, Deceased BIT NULL
		, BirthDateVerification BIT NULL
		, PlaceOfBirth NVARCHAR(MAX) NULL
		, StateOfBirth NVARCHAR(MAX) NULL
		, CountryOfBirth NVARCHAR(MAX) NULL
		, CountriesOfCitizenship NVARCHAR(MAX) NULL
		, CountriesOfResidency NVARCHAR(MAX) NULL
		, CountryArrivalDate DATE NULL
		, AustralianCitizenshipStatus NVARCHAR(MAX) NULL
		, EnglishProficiency NVARCHAR(MAX) NULL
		--, LanguageList 
		, DwellingArrangement NVARCHAR(MAX) NULL
		, Religion NVARCHAR(MAX) NULL
		, ReligiousRegion NVARCHAR(MAX) NULL
		, PermanentResident NVARCHAR(MAX) NULL
		, VisaSubClass NVARCHAR(MAX) NULL
		, VisaStatisticalCode NVARCHAR(MAX) NULL
		, VisaNumber NVARCHAR(MAX) NULL
		, VisaGrantDate DATE NULL
		, VisaConditions NVARCHAR(MAX) NULL
		, VisaStudyEntitlement NVARCHAR(MAX) NULL
		, PassportNumber NVARCHAR(MAX) NULL
		, PassportExpiryDate DATE NULL
		, CountryOfPassport NVARCHAR(MAX) NULL
		--, LBOTE
		, InterpreterRequired BIT NULL
		, ImmunisationCertificateStatus NVARCHAR(MAX) NULL
		, CulturalBackground NVARCHAR(MAX) NULL
		, MartialStatus NVARCHAR(MAX) NULL
		, MedicareNumber NVARCHAR(MAX) NULL
		, MedicarePositionNumber INT NULL
		, MedicareCardHolder NVARCHAR(MAX) NULL
		, PrivateHealthInsurance NVARCHAR(MAX) NULL
		, CONSTRAINT demographicId_pk PRIMARY KEY NONCLUSTERED (DemographicId)

	)
END 
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'OtherNames')
BEGIN
	CREATE TABLE OtherNames
	(
		OtherNamesId BIGINT IDENTITY(1,1) NOT NULL
		, PersonalInfoId BIGINT NULL
		, Title NVARCHAR(MAX) NOT NULL
		, FamilyName NVARCHAR(MAX) NOT NULL
		, GivenName NVARCHAR(MAX) NOT NULL
		, MiddleName NVARCHAR(MAX) NOT NULL
		, FamilyNameFirst BIT NULL
		, PreferredFamilyName NVARCHAR(MAX) NOT NULL
		, PrferredFamilyNameFirst BIT NULL
		, PreferredGivenName NVARCHAR(MAX) NOT NULL
		, Suffix NVARCHAR(MAX) NOT NULL
		, FullName NVARCHAR(MAX) NOT NULL
		, CONSTRAINT otherNamesId_pk PRIMARY KEY NONCLUSTERED (OtherNamesId)
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Addresses')
BEGIN
	CREATE TABLE Addresses
	(
		AddressId BIGINT IDENTITY(1,1) NOT NULL
		, PersonalInfoId BIGINT NULL
		, HouseholdContactInfoId BIGINT NULL 
		, [Type] NVARCHAR(MAX) NULL
		, EffectiveFromDate DATETIME NULL
		, EffectiveToDate DATETIME NULL
		, Street NVARCHAR(MAX) NULL
		, City NVARCHAR(MAX) NULL
		, StateProvince NVARCHAR(MAX) NULL
		, Country NVARCHAR(MAX) NULL
		, PostalCode NVARCHAR(MAX) NULL
		, RadioContact NVARCHAR(MAX) NULL
		, Community NVARCHAR(MAX) NULL
		, LocalId NVARCHAR(MAX) NULL
		, CONSTRAINT addressId_pk PRIMARY KEY NONCLUSTERED (AddressId)
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PhoneNumbers')
BEGIN
	CREATE TABLE PhoneNumbers
	(
		PhoneNumberId BIGINT IDENTITY(1,1) NOT NULL
		, PersonalInfoId BIGINT NULL
		, HouseholdContactInfoId BIGINT NULL
		, [Type] NVARCHAR(MAX) NULL
		, Number NVARCHAR(MAX) NULL
		, Extension NVARCHAR(MAX) NULL 
		, ListedStatus NVARCHAR(MAX) NULL
		, Preference NVARCHAR(MAX) NULL
		, CONSTRAINT phoneNumberId_pk PRIMARY KEY NONCLUSTERED (PhoneNumberId)
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Emails')
BEGIN
	CREATE TABLE Emails
	(
		EmailId BIGINT IDENTITY(1,1) NOT NULL
		, PersonalInfoId BIGINT NULL
		, HouseholdContactInfoId BIGINT NULL
		, Email NVARCHAR(MAX) NULL
		, [Type] NVARCHAR(MAX) NULL
		, CONSTRAINT emailId_pk PRIMARY KEY NONCLUSTERED (EmailId)
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'HouseholdContactInfos')
BEGIN
	CREATE TABLE HouseholdContactInfos
	(
		HouseholdContactInfoId BIGINT IDENTITY(1,1) NOT NULL
		, PersonalInfoId BIGINT NULL
		, PreferenceNumber NVARCHAR(MAX) NULL
		, HouseholdSalutation NVARCHAR(MAX) NULL
		, CONSTRAINT householdContactInfoId_pk PRIMARY KEY NONCLUSTERED (HouseholdContactInfoId)
	)
END
GO

USE SchoolManagementDB;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_Demographic_DemographicId')
BEGIN
	ALTER TABLE [dbo].[PersonalInfo] DROP CONSTRAINT [FK_Demographic_DemographicId]
END
GO

ALTER TABLE PersonalInfo
ADD CONSTRAINT FK_Demographic_DemographicId
FOREIGN KEY (DemographicsId)
REFERENCES Demographics (DemographicId)
ON DELETE CASCADE
ON UPDATE CASCADE;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_OtherNames_PersonalInfoId')
BEGIN
	ALTER TABLE [dbo].[OtherNames] DROP CONSTRAINT [FK_OtherNames_PersonalInfoId]
END
GO

ALTER TABLE OtherNames
ADD CONSTRAINT FK_OtherNames_PersonalInfoId
FOREIGN KEY (PersonalInfoId)
REFERENCES PersonalInfo (PersonalInfoId)
ON DELETE CASCADE
ON UPDATE CASCADE;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_Addresses_PersonalInfoId')
BEGIN
	ALTER TABLE [dbo].[Addresses] DROP CONSTRAINT [FK_Addresses_PersonalInfoId]
END
GO

ALTER TABLE Addresses
ADD CONSTRAINT FK_Addresses_PersonalInfoId
FOREIGN KEY (PersonalInfoId)
REFERENCES PersonalInfo (PersonalInfoId)
ON DELETE CASCADE
ON UPDATE CASCADE;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_Addresses_HouseholdContactInfoId')
BEGIN
	ALTER TABLE [dbo].[Addresses] DROP CONSTRAINT [FK_Addresses_HouseholdContactInfoId]
END
GO

ALTER TABLE Addresses
ADD CONSTRAINT FK_Addresses_HouseholdContactInfoId
FOREIGN KEY (HouseholdContactInfoId)
REFERENCES HouseholdContactInfos (HouseholdContactInfoId)
ON DELETE CASCADE
ON UPDATE CASCADE;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_PhoneNumbers_PersonalInfoId')
BEGIN
	ALTER TABLE [dbo].[PhoneNumbers] DROP CONSTRAINT [FK_PhoneNumbers_PersonalInfoId]
END
GO

ALTER TABLE PhoneNumbers
ADD CONSTRAINT FK_PhoneNumbers_PersonalInfoId
FOREIGN KEY (PersonalInfoId)
REFERENCES PersonalInfo (PersonalInfoId)
ON DELETE CASCADE
ON UPDATE CASCADE;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_PhoneNumbers_HouseholdContactInfoId')
BEGIN
	ALTER TABLE [dbo].[PhoneNumbers] DROP CONSTRAINT [FK_PhoneNumbers_HouseholdContactInfoId]
END
GO

ALTER TABLE PhoneNumbers
ADD CONSTRAINT FK_PhoneNumbers_HouseholdContactInfoId
FOREIGN KEY (HouseholdContactInfoId)
REFERENCES HouseholdContactInfos (HouseholdContactInfoId)
ON DELETE CASCADE
ON UPDATE CASCADE;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_Emails_PersonalInfoId')
BEGIN
	ALTER TABLE [dbo].[Emails] DROP CONSTRAINT [FK_Emails_PersonalInfoId]
END
GO

ALTER TABLE Emails
ADD CONSTRAINT FK_Emails_PersonalInfoId
FOREIGN KEY (PersonalInfoId)
REFERENCES PersonalInfo (PersonalInfoId)
ON DELETE CASCADE
ON UPDATE CASCADE;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_Emails_HouseholdContactInfoId')
BEGIN
	ALTER TABLE [dbo].[Emails] DROP CONSTRAINT [FK_Emails_HouseholdContactInfoId]
END
GO

ALTER TABLE Emails
ADD CONSTRAINT FK_Emails_HouseholdContactInfoId
FOREIGN KEY (HouseholdContactInfoId)
REFERENCES HouseholdContactInfos (HouseholdContactInfoId)
ON DELETE CASCADE
ON UPDATE CASCADE;
GO

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE NAME = 'FK_HouseholdContactInfos_PersonalInfoId')
BEGIN
	ALTER TABLE [dbo].[HouseholdContactInfos] DROP CONSTRAINT [FK_HouseholdContactInfos_PersonalInfoId]
END
GO

ALTER TABLE HouseholdContactInfos
ADD CONSTRAINT FK_HouseholdContactInfos_PersonalInfoId
FOREIGN KEY (PersonalInfoId)
REFERENCES PersonalInfo (PersonalInfoId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

GO