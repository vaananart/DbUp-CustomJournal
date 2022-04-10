using DbUp.Engine;
using DbUp.Engine.Output;
using DbUp.Engine.Transactions;
using DbUp.Support;

namespace DBBuild.With.CustomJournal.CustomSupport
{
	public class InheritedDeploymentTrackJornal : TableJournal
	{
		public InheritedDeploymentTrackJornal(Func<IConnectionManager> connectionManager, Func<IUpgradeLog> logger, ISqlObjectParser sqlObjectParser, string schema, string table) : base(connectionManager, logger, sqlObjectParser, schema, table)
		{
		}

		protected override string CreateSchemaTableSql(string quotedPrimaryKeyName)
		{
			return @$"CREATE TABLE SchemaVersions (
						[Id] INT IDENTITY(1,1) NOT NULL
						, [ScriptName] NVARCHAR(255) NOT NULL
						,[Applied] DATETIME NOT NULL
						, CONSTRAINT {quotedPrimaryKeyName} PRIMARY KEY NONCLUSTERED (Id)
						)
					CREATE TABLE HistoricalDates(
						[Id] INT IDENTITY(1,1) NOT NULL
						, SchemaVersionsId INT not null
						, DeploymentDate DATETIME NOT NULL
						, CONSTRAINT pk_HistoricalDates_Id PRIMARY KEY NONCLUSTERED (Id)
					)

					ALTER TABLE HistoricalDates
					ADD CONSTRAINT FK_SchemaVersions_SchmaVersionsId
					FOREIGN KEY (SchemaVersionsId)
					REFERENCES SchemaVersions (Id)
					ON DELETE CASCADE
					ON UPDATE CASCADE;
					";
		}

		protected override string GetInsertJournalEntrySql(string scriptName, string applied)
		{
			var result = @$"
						IF EXISTS(SELECT 1 FROM [dbo].[SchemaVersions] WHERE ScriptName = {scriptName})
						BEGIN
							UPDATE [dbo].[SchemaVersions]
							SET Applied = {applied} 
							WHERE ScriptName = {scriptName} 
						END
						ELSE
						BEGIN
							INSERT INTO [dbo].[SchemaVersions] (ScriptName, Applied) 
							VALUES ({scriptName}, {applied});
						END

						INSERT INTO [dbo].[HistoricalDates](SchemaVersionsId, DeploymentDate)
						SELECT Id, Applied
						FROM [dbo].[SchemaVersions]
						WHERE ScriptName = {scriptName}
						AND Applied = {applied}
					";

			return result;
		}

		protected override string GetJournalEntriesSql()
		{
			return $"select [ScriptName] from {FqSchemaTableName} order by [ScriptName]";
		}
	}
}
