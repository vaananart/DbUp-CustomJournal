// See https://aka.ms/new-console-template for more information
using DBBuild.With.CustomJournal.CustomSupport;

using DbUp;
using DbUp.Engine;
//using DbUp.SqlServer;

using Microsoft.Extensions.Configuration;

using System.Reflection;

var configs = new ConfigurationBuilder()
	.SetBasePath(Directory.GetCurrentDirectory())
	.AddJsonFile("appsettings.json")
	.Build();

try
{
	var connectionString = configs["ConnectionString"];
	var dbNames = configs.GetSection("DatabaseNames").GetChildren();

	foreach (var configElement in dbNames)
	{

		var parsedConnectionString = connectionString.Replace("{{DATABASENAME}}", configElement.Value);

		var sqlScriptOptions = new SqlScriptOptions();
		sqlScriptOptions.ScriptType = DbUp.Support.ScriptType.RunAlways;

		var dbBuilder = DeployChanges.To.SqlDatabase(parsedConnectionString)
				.WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), (string s) => s.Contains(configElement.Value), sqlScriptOptions)
				//.JournalToSqlTable("dbo", "SchemaVersions")
				.JournalTo(new DetailedDeploymentTrackJournal(parsedConnectionString))
				.LogToConsole();

		//dbBuilder.Configure(
		//	c =>
		//	{
		//		c.Journal = new InheritedDeploymentTrackJournal(
		//			() => c.ConnectionManager,
		//			() => c.Log,
		//			new SqlServerObjectParser(),
		//			"",
		//			"SchemaVersions"
		//		);
			
		//	}
		//);
		var test = dbBuilder.Build();
				

		//var scripts = test.GetScriptsToExecute();

		var result = test.PerformUpgrade();
		Console.WriteLine(result.Successful ? "Upgrade is performed successfully" : "Upgrade has failed");
	}
}
catch (Exception ex)
{
	var message = ex.Message;
}