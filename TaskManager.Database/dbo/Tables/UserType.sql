CREATE TABLE [dbo].[UserType] (
    [UserTypeID] INT NOT NULL IDENTITY(1,1),
    [UserType]   NVARCHAR (50) NOT NULL,
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_UserType_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_UserType_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_UserType_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [CreatedBy] INT NULL,
    [UpdatedBy] INT NULL,
    [RowVersion] ROWVERSION,  -- for optimistic concurrency
    CONSTRAINT [PK_UserType] PRIMARY KEY CLUSTERED ([UserTypeID] ASC),
    CONSTRAINT [FK_UserType_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_UserType_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_UserType_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [CK_UserType_UserType_NotBlank] CHECK (LEN(LTRIM(RTRIM([UserType]))) > 0),
    CONSTRAINT [CK_UserType_DeletedAt_RequiresIsDeleted] CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_UserType_DeletedBy_RequiresIsDeleted] CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
);

GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_UserType_UserType_Active]
ON [dbo].[UserType]([UserType])
WHERE [IsDeleted] = 0;
GO

-- ============================================================================
-- Trigger: TR_UserType_UpdateAudit
-- Table:   [dbo].[UserType]
-- Purpose: 
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [UserType] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- ============================================================================
CREATE TRIGGER [dbo].[TR_UserType_UpdateAudit]
ON [dbo].[UserType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE ut
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[UserType] ut
        INNER JOIN inserted i ON ut.UserTypeID = i.UserTypeID;
    END;
END;
GO

