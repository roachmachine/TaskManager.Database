CREATE TABLE [dbo].[OrgProgram]
(
    [OrgProgramID] INT NOT NULL IDENTITY(1,1) CONSTRAINT [PK_OrgProgram] PRIMARY KEY,
    [ProgramName] NVARCHAR(100) NOT NULL,
    [ImageUrl] NVARCHAR(500) NULL,
    [OrganizationID] INT NOT NULL,
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_OrgProgram_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_OrgProgram_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_OrgProgram_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [RowVersion] ROWVERSION,
    [CreatedBy] INT NOT NULL,
    [UpdatedBy] INT NOT NULL,
    CONSTRAINT [FK_OrgProgram_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_OrgProgram_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_OrgProgram_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_OrgProgram_Organization] 
        FOREIGN KEY ([OrganizationID]) 
        REFERENCES [dbo].[Organization]([OrganizationID])
        ON DELETE CASCADE,
    CONSTRAINT [CK_OrgProgram_ProgramName_NotBlank] 
        CHECK (LEN(LTRIM(RTRIM([ProgramName]))) > 0),
    CONSTRAINT [CK_OrgProgram_DeletedAt_RequiresIsDeleted] 
        CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_OrgProgram_DeletedBy_RequiresIsDeleted] 
        CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_OrgProgram_Name_Organization_Active]
ON [dbo].[OrgProgram]([ProgramName], [OrganizationID])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_OrgProgram_OrganizationID_Active]
ON [dbo].[OrgProgram]([OrganizationID])
WHERE [IsDeleted] = 0;
GO

-- ============================================================================
-- Trigger: TR_OrgProgram_UpdateAudit
-- Table:   [dbo].[OrgProgram]
-- Purpose: 
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [OrgProgram] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- ============================================================================
CREATE TRIGGER [dbo].[TR_OrgProgram_UpdateAudit]
ON [dbo].[OrgProgram]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE op
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[OrgProgram] op
        INNER JOIN inserted i ON op.OrgProgramID = i.OrgProgramID;
    END;
END;
GO
