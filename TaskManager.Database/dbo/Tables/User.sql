CREATE TABLE [dbo].[User] (
    [UserID]     INT          IDENTITY (1, 1) NOT NULL,
    [UserName]   NVARCHAR (100) NOT NULL,
    [Email]      NVARCHAR (255) NOT NULL,
    [UserTypeID] INT          NOT NULL,
    [OrgProgramID]  INT          NULL,
    [TimeZoneID] NVARCHAR(50)  NOT NULL DEFAULT 'UTC',
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_User_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt] DATETIME2(3)  NOT NULL CONSTRAINT [DF_User_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt] DATETIME2(3)  NOT NULL CONSTRAINT [DF_User_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [CreatedBy] INT NULL,
    [UpdatedBy] INT NULL,
    [RowVersion] ROWVERSION,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [FK_User_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_User_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_User_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_User_UserType] FOREIGN KEY ([UserTypeID]) REFERENCES [dbo].[UserType]([UserTypeID]) ON DELETE NO ACTION,
    CONSTRAINT [FK_User_OrgProgram] FOREIGN KEY ([OrgProgramID]) REFERENCES [dbo].[OrgProgram]([OrgProgramID]) ON DELETE SET NULL,
    CONSTRAINT [CK_User_UserName_NotBlank] CHECK (LEN(LTRIM(RTRIM([UserName]))) > 0),
    CONSTRAINT [CK_User_Email_NotBlank] CHECK (LEN(LTRIM(RTRIM([Email]))) > 0),
    CONSTRAINT [CK_User_TimeZoneID_NotBlank] CHECK (LEN(LTRIM(RTRIM([TimeZoneID]))) > 0),
    CONSTRAINT [CK_User_DeletedAt_RequiresIsDeleted] CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_User_DeletedBy_RequiresIsDeleted] CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_User_Email_Active]
ON [dbo].[User]([Email])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_User_OrgProgramID] 
ON [dbo].[User]([OrgProgramID])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_User_UserTypeID] 
ON [dbo].[User]([UserTypeID])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_User_UserName_Active]
ON [dbo].[User]([UserName])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_User_Email_Active]
ON [dbo].[User]([Email])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_User_OrgProgramID_Active]
ON [dbo].[User]([OrgProgramID])
WHERE [IsDeleted] = 0 AND [OrgProgramID] IS NOT NULL;
GO

-- ============================================================================
-- Trigger: TR_User_UpdateAudit
-- Table:   [dbo].[User]
-- Purpose: 
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [User] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- ============================================================================
CREATE TRIGGER [dbo].[TR_User_UpdateAudit]
ON [dbo].[User]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE u
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[User] u
        INNER JOIN inserted i ON u.UserID = i.UserID;
    END;
END;
GO
