using DbUp.Engine;

using System.Data;

namespace DBBuild.With.CustomJournal.CustomSupport
{
	public class DetailedDeploymentTrackJournal : IJournal
	{
		public void EnsureTableExistsAndIsLatestVersion(Func<IDbCommand> dbCommandFactory)
		{
			throw new NotImplementedException();
		}

		public string[] GetExecutedScripts()
		{
			throw new NotImplementedException();
		}

		public void StoreExecutedScript(SqlScript script, Func<IDbCommand> dbCommandFactory)
		{
			throw new NotImplementedException();
		}
	}
}
