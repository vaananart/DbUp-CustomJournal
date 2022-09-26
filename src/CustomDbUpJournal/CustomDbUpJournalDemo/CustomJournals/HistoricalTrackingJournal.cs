using System.Data;
using System.Data.SqlClient;
using DbUp.Engine;

namespace CustomDbUpJournalDemo.CustomJournals
{
	public class HistoricalTrackingJournal : IJournal
	{
		private readonly string _connectionString;

		public HistoricalTrackingJournal(string connectionString)
		{
			_connectionString = connectionString;
		}
		public void EnsureTableExistsAndIsLatestVersion(Func<IDbCommand> dbCommandFactory)
		{
			var schemaInformationQuery = "SELECT 1 FROM [DbUpDatabase].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SchemaVersions' AND TABLE_SCHEMA = 'dbo'";
			using var command = dbCommandFactory();
			command.CommandText = schemaInformationQuery;
			command.CommandType	= CommandType.Text;
			var reader = command.ExecuteScalar();

			if (reader == null)
			{
				string tableCreationSQL = @"CREATE TABLE [DbUpDatabase].SchemaVersions (
						[Id] INT IDENTITY(1,1) NOT NULL
						, [ScriptName] NVARCHAR(255) NOT NULL
						, [Applied] DATETIME NOT NULL
						, CONSTRAINT pk_SchemaVersions_Id PRIMARY KEY NONCLUSTERED (Id)
						)
					CREATE TABLE [DbUpDatabase].HistoricalDates(
						[Id] INT IDENTITY(1,1) NOT NULL
						, SchemaVersionsId INT not null
						, DeploymentDate DATETIME NOT NULL
						, CONSTRAINT pk_HistoricalDates_Id PRIMARY KEY NONCLUSTERED (Id)
					)

					ALTER TABLE [DbUpDatabase].HistoricalDates
					ADD CONSTRAINT FK_SchemaVersions_SchmaVersionsId
					FOREIGN KEY (SchemaVersionsId)
					REFERENCES [DbUpDatabase].SchemaVersions (Id)
					ON DELETE CASCADE
					ON UPDATE CASCADE;
					";

				command.CommandText = tableCreationSQL;
				command.CommandType = CommandType.Text;
				command.ExecuteNonQuery();
			}

		}

		public string[] GetExecutedScripts()
		{

			string schemaInformationQuery = "SELECT 1 FROM [DbUpDatabase].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SchemaVersions' AND TABLE_SCHEMA = 'dbo'";
			using SqlConnection checkingConnection = new SqlConnection(_connectionString);
			checkingConnection.Open();
			using SqlCommand checkingCommand = new SqlCommand(schemaInformationQuery, checkingConnection);
			checkingCommand.CommandText = schemaInformationQuery;
			checkingCommand.CommandType = CommandType.Text;
			var readerQuery = checkingCommand.ExecuteScalar();

			if (readerQuery == null)
			{ 
				
				return Array.Empty<string>();
			}

			string queryString = "SELECT ScriptName FROM [DbUpDatabase].[SchemaVersions]";

			var result = new List<string>();

			using SqlConnection connection = new SqlConnection(_connectionString);
			connection.Open();
			using SqlCommand command = new SqlCommand(queryString, connection);
			using SqlDataReader reader = command.ExecuteReader();
			
			while (reader.Read())
			{ 
				result.Add(reader.GetString(0));
			}

			return result.ToArray();
		}

		public void StoreExecutedScript(SqlScript script, Func<IDbCommand> dbCommandFactory)
		{
			string insertionSQL = @$"
						IF EXISTS(SELECT 1 FROM [DbUpDatabase].[SchemaVersions] WHERE ScriptName = @scriptName)
						BEGIN
							UPDATE [DbUpDatabase].[SchemaVersions]
							SET Applied = @applied
							WHERE ScriptName = @scriptName 
						END
						ELSE
						BEGIN
							INSERT INTO [DbUpDatabase].[SchemaVersions] (ScriptName, Applied) 
							VALUES (@scriptName, @applied);
						END

						INSERT INTO [DbUpDatabase].[HistoricalDates](SchemaVersionsId, DeploymentDate)
						SELECT Id, Applied
						FROM [DbUpDatabase].[SchemaVersions]
						WHERE ScriptName = @scriptName
						AND Applied = @applied
					";

			using var command = dbCommandFactory();
			
			var scriptNameParam = command.CreateParameter();
			scriptNameParam.ParameterName = "scriptName";
			scriptNameParam.Value = script.Name;
			command.Parameters.Add(scriptNameParam);

			var appliedParam = command.CreateParameter();
			appliedParam.ParameterName = "applied";
			appliedParam.Value = DateTime.Now;
			command.Parameters.Add(appliedParam);

			command.CommandText = insertionSQL;
			command.CommandType = CommandType.Text;
			command.ExecuteNonQuery();
		}
	}
}
