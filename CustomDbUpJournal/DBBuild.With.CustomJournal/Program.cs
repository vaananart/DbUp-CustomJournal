// See https://aka.ms/new-console-template for more information
using DBBuild.With.CustomJournal.CustomSupport;

using DbUp;
using DbUp.SqlServer;

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

		var dbBuilder = DeployChanges.To.SqlDatabase(parsedConnectionString)
				.WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), (string s) => s.Contains(configElement.Value))
				.JournalToSqlTable("dbo", "SchemaVersions")
				.LogToConsole();

		var test = dbBuilder.Build();
				

		var scripts = test.GetScriptsToExecute();

		var result = test.PerformUpgrade();
		if (result.Successful)
		{
			Console.WriteLine("Upgrade is performed successfully");
		}
		else
		{
			Console.WriteLine("Upgrade has failed");
		}
	}
}
catch (Exception ex)
{
	var message = ex.Message;
}