// See https://aka.ms/new-console-template for more information

using System.Reflection;
using DBBuild.With.CustomJournal.CustomSupport;
using DbUp;
using DbUp.Engine;
using Microsoft.Extensions.Configuration;

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
            .JournalTo(new DetailedDeploymentTrackJournal(parsedConnectionString))
            .LogToConsole();
        var test = dbBuilder.Build();

        var result = test.PerformUpgrade();
        Console.WriteLine(result.Successful ? "Upgrade is performed successfully" : "Upgrade has failed");

    }
}
catch (Exception ex)
{
    Console.WriteLine( $"Exception: {ex.Message}");
}