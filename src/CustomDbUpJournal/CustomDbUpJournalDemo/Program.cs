// See https://aka.ms/new-console-template for more information

using System.Reflection;

using CommandLine;

using CustomDbUpJournalDemo.CustomJournals;

using DbUp;
using DbUp.Engine;

using Microsoft.Extensions.Configuration;

class Program
{
	public class Options
	{ 
		[Option('m',"mode",Required = false, HelpText ="Set specific appsetting.json")]
		public string Mode { get; set; }
	}

	static int Main(string[] args)
	{
		IConfigurationRoot configs = new ConfigurationBuilder().Build();
		Parser.Default.ParseArguments<Options>(args)
		.WithParsed<Options>(o =>
		{
			if(string.IsNullOrWhiteSpace(o.Mode))
			{		
				configs = new ConfigurationBuilder()
					.SetBasePath(Directory.GetCurrentDirectory())
					.AddJsonFile("appsettings.json")
					.Build(); 
			}
			else if(o.Mode.ToLowerInvariant() == "docker")
			{
				configs = new ConfigurationBuilder()
						.SetBasePath(Directory.GetCurrentDirectory())
						.AddJsonFile("appsettings.docker.json")
						.Build();
			}
			else if (o.Mode.ToLowerInvariant() == "azure")
			{
				configs = new ConfigurationBuilder()
						.SetBasePath(Directory.GetCurrentDirectory())
						.AddJsonFile("appsettings.azure.json")
						.Build();
			}

		});


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
					.JournalTo(new HistoricalTrackingJournal(parsedConnectionString))
					.LogToConsole();
				var test = dbBuilder.Build();

				var result = test.PerformUpgrade();
				Console.WriteLine(result.Successful ? "Upgrade is performed successfully" : "Upgrade has failed");

			}
		}
		catch (Exception ex)
		{
			Console.WriteLine($"Exception: {ex.Message}");
		}

		return 0;
	}
}

