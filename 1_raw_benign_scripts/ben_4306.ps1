# This should be included in SQL server if you have it installed, but I don't on this machine.
$package = Find-Package Microsoft.SqlServer.TransactSql.ScriptDom -Source https://www.nuget.org/api/v2
$package | Save-Package -Path $PWD
$fileBaseName = $package.Name + '.' + $package.Version
Rename-Item "$fileBaseName.nupkg" "$fileBaseName.zip"
Expand-Archive "$fileBaseName.zip"
Add-Type -Path $fileBaseName\lib\net40\Microsoft.SqlServer.TransactSql.ScriptDom.dll

# Example from https://docs.microsoft.com/en-us/sql/t-sql/queries/select-examples-transact-sql
$tSqlSample = @'
USE AdventureWorks2012;
GO
SELECT *
FROM Production.Product
ORDER BY Name ASC;
-- Alternate way.
USE AdventureWorks2012;
GO
SELECT p.*
FROM Production.Product AS p
ORDER BY Name ASC;
GO
'@

$reader = [System.IO.StringReader]::new($tSqlSample)

$parser = [Microsoft.SqlServer.TransactSql.ScriptDom.TSql140Parser]::new($false)
$tokenErrors = $null
$tokens = $parser.GetTokenStream($reader, [ref]$tokenErrors)

$fragmentErrors = $null
$tSqlFragment = $parser.Parse($tokens, [ref]$fragmentErrors)

$tSqlFragment
<# returns
Batches           : {Microsoft.SqlServer.TransactSql.ScriptDom.TSqlBatch,
                    Microsoft.SqlServer.TransactSql.ScriptDom.TSqlBatch,
                    Microsoft.SqlServer.TransactSql.ScriptDom.TSqlBatch}
StartOffset       : 0
FragmentLength    : 185
StartLine         : 1
StartColumn       : 1
FirstTokenIndex   : 0
LastTokenIndex    : 61
ScriptTokenStream : {Microsoft.SqlServer.TransactSql.ScriptDom.TSqlParserToken,
                    Microsoft.SqlServer.TransactSql.ScriptDom.TSqlParserToken,
                    Microsoft.SqlServer.TransactSql.ScriptDom.TSqlParserToken,
                    Microsoft.SqlServer.TransactSql.ScriptDom.TSqlParserToken...}
#>

$tokens
<# returns
TokenType : Use
Offset    : 0
Line      : 1
Column    : 1
Text      : USE

TokenType : WhiteSpace
Offset    : 3
Line      : 1
Column    : 4
Text      :

TokenType : Identifier
Offset    : 4
Line      : 1
Column    : 5
Text      : AdventureWorks2012

TokenType : Semicolon
Offset    : 22
Line      : 1
Column    : 23
Text      : ;

TokenType : WhiteSpace
Offset    : 23
Line      : 1
Column    : 24
Text      :


TokenType : Go
Offset    : 24
Line      : 2
Column    : 1
Text      : GO

TokenType : WhiteSpace
Offset    : 26
Line      : 2
Column    : 3
Text      :


TokenType : Select
Offset    : 27
Line      : 3
Column    : 1
Text      : SELECT

TokenType : WhiteSpace
Offset    : 33
Line      : 3
Column    : 7
Text      :

TokenType : Star
Offset    : 34
Line      : 3
Column    : 8
Text      : *

TokenType : WhiteSpace
Offset    : 35
Line      : 3
Column    : 9
Text      :


TokenType : From
Offset    : 36
Line      : 4
Column    : 1
Text      : FROM

TokenType : WhiteSpace
Offset    : 40
Line      : 4
Column    : 5
Text      :

TokenType : Identifier
Offset    : 41
Line      : 4
Column    : 6
Text      : Production

TokenType : Dot
Offset    : 51
Line      : 4
Column    : 16
Text      : .

TokenType : Identifier
Offset    : 52
Line      : 4
Column    : 17
Text      : Product

TokenType : WhiteSpace
Offset    : 59
Line      : 4
Column    : 24
Text      :


TokenType : Order
Offset    : 60
Line      : 5
Column    : 1
Text      : ORDER

TokenType : WhiteSpace
Offset    : 65
Line      : 5
Column    : 6
Text      :

TokenType : By
Offset    : 66
Line      : 5
Column    : 7
Text      : BY

TokenType : WhiteSpace
Offset    : 68
Line      : 5
Column    : 9
Text      :

TokenType : Identifier
Offset    : 69
Line      : 5
Column    : 10
Text      : Name

TokenType : WhiteSpace
Offset    : 73
Line      : 5
Column    : 14
Text      :

TokenType : Asc
Offset    : 74
Line      : 5
Column    : 15
Text      : ASC

TokenType : Semicolon
Offset    : 77
Line      : 5
Column    : 18
Text      : ;

TokenType : WhiteSpace
Offset    : 78
Line      : 5
Column    : 19
Text      :


TokenType : SingleLineComment
Offset    : 79
Line      : 6
Column    : 1
Text      : -- Alternate way.

TokenType : WhiteSpace
Offset    : 96
Line      : 6
Column    : 18
Text      :


TokenType : Use
Offset    : 97
Line      : 7
Column    : 1
Text      : USE

TokenType : WhiteSpace
Offset    : 100
Line      : 7
Column    : 4
Text      :

TokenType : Identifier
Offset    : 101
Line      : 7
Column    : 5
Text      : AdventureWorks2012

TokenType : Semicolon
Offset    : 119
Line      : 7
Column    : 23
Text      : ;

TokenType : WhiteSpace
Offset    : 120
Line      : 7
Column    : 24
Text      :


TokenType : Go
Offset    : 121
Line      : 8
Column    : 1
Text      : GO

TokenType : WhiteSpace
Offset    : 123
Line      : 8
Column    : 3
Text      :


TokenType : Select
Offset    : 124
Line      : 9
Column    : 1
Text      : SELECT

TokenType : WhiteSpace
Offset    : 130
Line      : 9
Column    : 7
Text      :

TokenType : Identifier
Offset    : 131
Line      : 9
Column    : 8
Text      : p

TokenType : Dot
Offset    : 132
Line      : 9
Column    : 9
Text      : .

TokenType : Star
Offset    : 133
Line      : 9
Column    : 10
Text      : *

TokenType : WhiteSpace
Offset    : 134
Line      : 9
Column    : 11
Text      :


TokenType : From
Offset    : 135
Line      : 10
Column    : 1
Text      : FROM

TokenType : WhiteSpace
Offset    : 139
Line      : 10
Column    : 5
Text      :

TokenType : Identifier
Offset    : 140
Line      : 10
Column    : 6
Text      : Production

TokenType : Dot
Offset    : 150
Line      : 10
Column    : 16
Text      : .

TokenType : Identifier
Offset    : 151
Line      : 10
Column    : 17
Text      : Product

TokenType : WhiteSpace
Offset    : 158
Line      : 10
Column    : 24
Text      :

TokenType : As
Offset    : 159
Line      : 10
Column    : 25
Text      : AS

TokenType : WhiteSpace
Offset    : 161
Line      : 10
Column    : 27
Text      :

TokenType : Identifier
Offset    : 162
Line      : 10
Column    : 28
Text      : p

TokenType : WhiteSpace
Offset    : 163
Line      : 10
Column    : 29
Text      :


TokenType : Order
Offset    : 164
Line      : 11
Column    : 1
Text      : ORDER

TokenType : WhiteSpace
Offset    : 169
Line      : 11
Column    : 6
Text      :

TokenType : By
Offset    : 170
Line      : 11
Column    : 7
Text      : BY

TokenType : WhiteSpace
Offset    : 172
Line      : 11
Column    : 9
Text      :

TokenType : Identifier
Offset    : 173
Line      : 11
Column    : 10
Text      : Name

TokenType : WhiteSpace
Offset    : 177
Line      : 11
Column    : 14
Text      :

TokenType : Asc
Offset    : 178
Line      : 11
Column    : 15
Text      : ASC

TokenType : Semicolon
Offset    : 181
Line      : 11
Column    : 18
Text      : ;

TokenType : WhiteSpace
Offset    : 182
Line      : 11
Column    : 19
Text      :


TokenType : Go
Offset    : 183
Line      : 12
Column    : 1
Text      : GO

TokenType : EndOfFile
Offset    : 185
Line      : 12
Column    : 3
Text      :
#>