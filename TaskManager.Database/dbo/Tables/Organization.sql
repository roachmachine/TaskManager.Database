CREATE TABLE [dbo].[Organization] (
    [OrganizationID]   INT           IDENTITY (1, 1) NOT NULL,
    [OrganizationName] NVARCHAR (100) NOT NULL,
    [ImageUrl] NVARCHAR(500) NULL,
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_Organization_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt]        DATETIME2(3)  NOT NULL CONSTRAINT [DF_Organization_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt]        DATETIME2(3)  NOT NULL CONSTRAINT [DF_Organization_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [RowVersion]       ROWVERSION,  -- for optimistic concurrency
    [CreatedBy]        INT NOT NULL,
    [UpdatedBy]        INT NOT NULL,
    CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED ([OrganizationID] ASC),
    CONSTRAINT [FK_Organization_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_Organization_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_Organization_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [CK_Organization_OrganizationName_NotBlank] CHECK (LEN(LTRIM(RTRIM([OrganizationName]))) > 0),
    CONSTRAINT [CK_Organization_DeletedAt_RequiresIsDeleted] CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_Organization_DeletedBy_RequiresIsDeleted] CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
);

GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Organization_OrganizationName_Active]
ON [dbo].[Organization]([OrganizationName])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_Organization_OrganizationName_Active]
ON [dbo].[Organization]([OrganizationName])
WHERE [IsDeleted] = 0;
GO

-- ============================================================================
-- Trigger: TR_Organization_UpdateAudit
-- Table:   [dbo].[Organization]
-- Purpose: 
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [Organization] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- ============================================================================
CREATE TRIGGER [dbo].[TR_Organization_UpdateAudit]
ON [dbo].[Organization]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE o
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[Organization] o
        INNER JOIN inserted i ON o.OrganizationID = i.OrganizationID;
    END;
END;
GO
