using DbUp.Engine.Output;
using DbUp.Engine.Transactions;
using DbUp.SqlServer;

namespace CustomDbUpJournalDemo.CustomJournals;

public class SimpleDbUpJournal: SqlTableJournal
{
    private readonly string FQCatalogedSchemaTableName;

    public SimpleDbUpJournal(Func<IConnectionManager> connectionManager
            , Func<IUpgradeLog> logger
            , string catalog
            , string schema
            , string table) : base(connectionManager, logger, schema, table)
    {
        FQCatalogedSchemaTableName = new SqlServerObjectParser()
            .QuoteIdentifier(catalog) + "." + FqSchemaTableName;
    }

    protected override string GetInsertJournalEntrySql(string scriptName, string applied)
    {
        return @$"INSERT INTO [DbUpDatabase].{base.FqSchemaTableName} (ScriptName, Applied)
                    VALUES ({@scriptName}, {@applied})";
    }

    protected override string GetJournalEntriesSql()
    {
        return @$"SELECT [ScriptName] 
                FROM [DbUpDatabase].{base.FqSchemaTableName} 
                ORDER BY [ScriptName]";
    }

    protected override string CreateSchemaTableSql(string quotedPrimaryKeyName)
    {
        return @$"CREATE TABLE [DbUpDatabase].{base.FqSchemaTableName} (
                        [Id] INT IDENTITY(1, 1) NOT NULL CONSTRAINT {quotedPrimaryKeyName} PRIMARY KEY
                        , [ScriptName] NVARCHAR(255) NO NULL
                        , [Applied] DATETIME NOT NULL
                    ) ";
    }

    protected override string DoesTableExistSql()
    {
        return string.IsNullOrEmpty(SchemaTableSchema)
                ? string.Format(@"SELECT 1 
                                    FROM [DbUpDatabase].INFORMATION_SCHEMA.TABLES 
                                    WHERE TABLE_NAME='{0}'", UnquotedSchemaTableName)
                : string.Format(@"SELECT 1 
                                    FROM [DbUpDatabase].INFORMATION_SCHEMA.TABLES 
                                    WHERE TABLE_NAME = '{0}' AND TABLE_SCHEMA = '{1}'"
                        , UnquotedSchemaTableName, SchemaTableSchema);
    }
}