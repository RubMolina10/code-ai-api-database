/* ============================================================
   CODE INTELLIGENCE
   DATABASE INSTALLATION SCRIPT

   Database: CodeAI
   Engine: SQL Server
   ============================================================ */


USE master;
GO


/* ============================================================
   CREATE DATABASE
   ============================================================ */

IF DB_ID('CodeAI') IS NULL
BEGIN

    CREATE DATABASE CodeAI;

END;
GO


USE CodeAI;
GO



/* ============================================================
   PROJECTS
   ============================================================ */

IF OBJECT_ID('dbo.Projects', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Projects
    (
        Id INT IDENTITY(1,1) NOT NULL,

        Name NVARCHAR(200) NOT NULL,

        Description NVARCHAR(MAX) NULL,

        ProjectType NVARCHAR(50) NOT NULL,

        Provider NVARCHAR(50) NOT NULL,

        RepositoryUrl NVARCHAR(1000) NULL,

        LocalPath NVARCHAR(1000) NULL,

        DefaultBranch NVARCHAR(200) NULL,

        Active BIT NOT NULL
            CONSTRAINT DF_Projects_Active
            DEFAULT 1,

        DateCreated DATETIME2 NOT NULL
            CONSTRAINT DF_Projects_DateCreated
            DEFAULT SYSDATETIME(),

        DateUpdated DATETIME2 NULL,


        CONSTRAINT PK_Projects
            PRIMARY KEY (Id)
    );

END;
GO



/* ============================================================
   PROJECT TECHNOLOGIES
   ============================================================ */

IF OBJECT_ID('dbo.ProjectTechnologies', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.ProjectTechnologies
    (
        Id INT IDENTITY(1,1) NOT NULL,

        ProjectId INT NOT NULL,

        Technology NVARCHAR(100) NOT NULL,


        CONSTRAINT PK_ProjectTechnologies
            PRIMARY KEY (Id),


        CONSTRAINT FK_ProjectTechnologies_Projects
            FOREIGN KEY (ProjectId)
            REFERENCES dbo.Projects(Id)
            ON DELETE CASCADE
    );

END;
GO



/* ============================================================
   REPOSITORIES
   ============================================================ */

IF OBJECT_ID('dbo.Repositories', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Repositories
    (
        Id INT IDENTITY(1,1) NOT NULL,

        ProjectId INT NOT NULL,

        Name NVARCHAR(200) NULL,

        Provider NVARCHAR(50) NOT NULL,

        RepositoryUrl NVARCHAR(1000) NOT NULL,

        DefaultBranch NVARCHAR(200) NULL,

        Active BIT NOT NULL
            CONSTRAINT DF_Repositories_Active
            DEFAULT 1,

        DateCreated DATETIME2 NOT NULL
            CONSTRAINT DF_Repositories_DateCreated
            DEFAULT SYSDATETIME(),


        CONSTRAINT PK_Repositories
            PRIMARY KEY (Id),


        CONSTRAINT FK_Repositories_Projects
            FOREIGN KEY (ProjectId)
            REFERENCES dbo.Projects(Id)
    );

END;
GO



/* ============================================================
   BRANCHES
   ============================================================ */

IF OBJECT_ID('dbo.Branches', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Branches
    (
        Id INT IDENTITY(1,1) NOT NULL,

        RepositoryId INT NOT NULL,

        Name NVARCHAR(200) NOT NULL,

        Sha NVARCHAR(100) NULL,

        IsProtected BIT NOT NULL
            CONSTRAINT DF_Branches_IsProtected
            DEFAULT 0,

        DateCreated DATETIME2 NOT NULL
            CONSTRAINT DF_Branches_DateCreated
            DEFAULT SYSDATETIME(),


        CONSTRAINT PK_Branches
            PRIMARY KEY (Id),


        CONSTRAINT FK_Branches_Repositories
            FOREIGN KEY (RepositoryId)
            REFERENCES dbo.Repositories(Id)
            ON DELETE CASCADE
    );

END;
GO



/* ============================================================
   COMMITS
   ============================================================ */

IF OBJECT_ID('dbo.Commits', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Commits
    (
        Id BIGINT IDENTITY(1,1) NOT NULL,

        RepositoryId INT NOT NULL,

        BranchId INT NULL,

        Sha NVARCHAR(100) NOT NULL,

        Message NVARCHAR(MAX) NULL,

        AuthorName NVARCHAR(300) NULL,

        AuthorEmail NVARCHAR(300) NULL,

        AuthorLogin NVARCHAR(200) NULL,

        CommitDate DATETIME2 NULL,

        Url NVARCHAR(1000) NULL,

        DateCreated DATETIME2 NOT NULL
            CONSTRAINT DF_Commits_DateCreated
            DEFAULT SYSDATETIME(),


        CONSTRAINT PK_Commits
            PRIMARY KEY (Id),


        CONSTRAINT FK_Commits_Repositories
            FOREIGN KEY (RepositoryId)
            REFERENCES dbo.Repositories(Id),


        CONSTRAINT FK_Commits_Branches
            FOREIGN KEY (BranchId)
            REFERENCES dbo.Branches(Id)
    );

END;
GO



/* ============================================================
   ANALYSIS RUNS
   ============================================================ */

IF OBJECT_ID('dbo.AnalysisRuns', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.AnalysisRuns
    (
        Id BIGINT IDENTITY(1,1) NOT NULL,

        ProjectId INT NOT NULL,

        RepositoryId INT NULL,

        BranchId INT NULL,

        CommitId BIGINT NULL,

        AnalysisType NVARCHAR(50) NOT NULL,

        Keyword NVARCHAR(500) NULL,

        Status NVARCHAR(30) NOT NULL,

        BranchName NVARCHAR(200) NULL,

        CommitSha NVARCHAR(100) NULL,

        ModelName NVARCHAR(100) NULL,

        CodeHealth INT NULL,

        RiskLevel NVARCHAR(30) NULL,

        BuildSuccess BIT NULL,

        TestsSuccess BIT NULL,

        Summary NVARCHAR(MAX) NULL,

        ErrorMessage NVARCHAR(MAX) NULL,

        StartedAt DATETIME2 NULL,

        CompletedAt DATETIME2 NULL,

        DateCreated DATETIME2 NOT NULL
            CONSTRAINT DF_AnalysisRuns_DateCreated
            DEFAULT SYSDATETIME(),


        CONSTRAINT PK_AnalysisRuns
            PRIMARY KEY (Id),


        CONSTRAINT FK_AnalysisRuns_Projects
            FOREIGN KEY (ProjectId)
            REFERENCES dbo.Projects(Id),


        CONSTRAINT FK_AnalysisRuns_Repositories
            FOREIGN KEY (RepositoryId)
            REFERENCES dbo.Repositories(Id),


        CONSTRAINT FK_AnalysisRuns_Branches
            FOREIGN KEY (BranchId)
            REFERENCES dbo.Branches(Id),


        CONSTRAINT FK_AnalysisRuns_Commits
            FOREIGN KEY (CommitId)
            REFERENCES dbo.Commits(Id),


        CONSTRAINT CK_AnalysisRuns_CodeHealth
            CHECK
            (
                CodeHealth IS NULL
                OR
                (
                    CodeHealth >= 0
                    AND
                    CodeHealth <= 100
                )
            )
    );

END;
GO



/* ============================================================
   ANALYSIS FILES
   ============================================================ */

IF OBJECT_ID('dbo.AnalysisFiles', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.AnalysisFiles
    (
        Id BIGINT IDENTITY(1,1) NOT NULL,

        AnalysisRunId BIGINT NOT NULL,

        FilePath NVARCHAR(1000) NOT NULL,

        ChangeType NVARCHAR(50) NULL,

        LinesAdded INT NOT NULL
            CONSTRAINT DF_AnalysisFiles_LinesAdded
            DEFAULT 0,

        LinesRemoved INT NOT NULL
            CONSTRAINT DF_AnalysisFiles_LinesRemoved
            DEFAULT 0,

        DateCreated DATETIME2 NOT NULL
            CONSTRAINT DF_AnalysisFiles_DateCreated
            DEFAULT SYSDATETIME(),


        CONSTRAINT PK_AnalysisFiles
            PRIMARY KEY (Id),


        CONSTRAINT FK_AnalysisFiles_AnalysisRuns
            FOREIGN KEY (AnalysisRunId)
            REFERENCES dbo.AnalysisRuns(Id)
            ON DELETE CASCADE
    );

END;
GO



/* ============================================================
   FINDINGS
   ============================================================ */

IF OBJECT_ID('dbo.Findings', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Findings
    (
        Id BIGINT IDENTITY(1,1) NOT NULL,

        AnalysisRunId BIGINT NOT NULL,

        Severity NVARCHAR(30) NOT NULL,

        Category NVARCHAR(150) NULL,

        Title NVARCHAR(500) NOT NULL,

        Description NVARCHAR(MAX) NULL,

        Suggestion NVARCHAR(MAX) NULL,

        FilePath NVARCHAR(1000) NULL,

        LineNumber INT NULL,

        Status NVARCHAR(30) NOT NULL
            CONSTRAINT DF_Findings_Status
            DEFAULT 'New',

        DateCreated DATETIME2 NOT NULL
            CONSTRAINT DF_Findings_DateCreated
            DEFAULT SYSDATETIME(),

        DateResolved DATETIME2 NULL,


        CONSTRAINT PK_Findings
            PRIMARY KEY (Id),


        CONSTRAINT FK_Findings_AnalysisRuns
            FOREIGN KEY (AnalysisRunId)
            REFERENCES dbo.AnalysisRuns(Id)
            ON DELETE CASCADE,


        CONSTRAINT CK_Findings_Severity
            CHECK
            (
                Severity IN
                (
                    'Critical',
                    'High',
                    'Medium',
                    'Low'
                )
            ),


        CONSTRAINT CK_Findings_Status
            CHECK
            (
                Status IN
                (
                    'New',
                    'Resolved'
                )
            )
    );

END;
GO



/* ============================================================
   INDEXES
   ============================================================ */


/*
 * PROJECTS
 */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_Projects_Active'
        AND
        object_id =
            OBJECT_ID('dbo.Projects')
)
BEGIN

    CREATE INDEX IX_Projects_Active
        ON dbo.Projects
        (
            Active
        );

END;
GO



/*
 * PROJECT TECHNOLOGIES
 */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_ProjectTechnologies_ProjectId'
        AND
        object_id =
            OBJECT_ID(
                'dbo.ProjectTechnologies'
            )
)
BEGIN

    CREATE INDEX IX_ProjectTechnologies_ProjectId
        ON dbo.ProjectTechnologies
        (
            ProjectId
        );

END;
GO



/*
 * REPOSITORIES
 */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_Repositories_ProjectId'
        AND
        object_id =
            OBJECT_ID(
                'dbo.Repositories'
            )
)
BEGIN

    CREATE INDEX IX_Repositories_ProjectId
        ON dbo.Repositories
        (
            ProjectId
        );

END;
GO



/*
 * BRANCHES
 */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_Branches_RepositoryId'
        AND
        object_id =
            OBJECT_ID(
                'dbo.Branches'
            )
)
BEGIN

    CREATE INDEX IX_Branches_RepositoryId
        ON dbo.Branches
        (
            RepositoryId
        );

END;
GO



/*
 * COMMITS
 */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_Commits_Repository_Sha'
        AND
        object_id =
            OBJECT_ID(
                'dbo.Commits'
            )
)
BEGIN

    CREATE INDEX IX_Commits_Repository_Sha
        ON dbo.Commits
        (
            RepositoryId,
            Sha
        );

END;
GO



/*
 * ANALYSIS RUNS
 */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_AnalysisRuns_ProjectId'
        AND
        object_id =
            OBJECT_ID(
                'dbo.AnalysisRuns'
            )
)
BEGIN

    CREATE INDEX IX_AnalysisRuns_ProjectId
        ON dbo.AnalysisRuns
        (
            ProjectId
        );

END;
GO



IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_AnalysisRuns_CommitSha'
        AND
        object_id =
            OBJECT_ID(
                'dbo.AnalysisRuns'
            )
)
BEGIN

    CREATE INDEX IX_AnalysisRuns_CommitSha
        ON dbo.AnalysisRuns
        (
            CommitSha
        );

END;
GO



IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_AnalysisRuns_Status'
        AND
        object_id =
            OBJECT_ID(
                'dbo.AnalysisRuns'
            )
)
BEGIN

    CREATE INDEX IX_AnalysisRuns_Status
        ON dbo.AnalysisRuns
        (
            Status
        );

END;
GO



/*
 * ANALYSIS FILES
 */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_AnalysisFiles_AnalysisRunId'
        AND
        object_id =
            OBJECT_ID(
                'dbo.AnalysisFiles'
            )
)
BEGIN

    CREATE INDEX IX_AnalysisFiles_AnalysisRunId
        ON dbo.AnalysisFiles
        (
            AnalysisRunId
        );

END;
GO



/*
 * FINDINGS
 */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_Findings_AnalysisRunId'
        AND
        object_id =
            OBJECT_ID(
                'dbo.Findings'
            )
)
BEGIN

    CREATE INDEX IX_Findings_AnalysisRunId
        ON dbo.Findings
        (
            AnalysisRunId
        );

END;
GO



IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE
        name = 'IX_Findings_Status_Severity'
        AND
        object_id =
            OBJECT_ID(
                'dbo.Findings'
            )
)
BEGIN

    CREATE INDEX IX_Findings_Status_Severity
        ON dbo.Findings
        (
            Status,
            Severity
        );

END;
GO



/* ============================================================
   INSTALLATION COMPLETE
   ============================================================ */

PRINT '==========================================';
PRINT 'CodeAI database installed successfully.';
PRINT '==========================================';
GO