CREATE TABLE [dbo].[TaskRecurrence]
(
    [RecurrenceID] INT NOT NULL PRIMARY KEY IDENTITY,
    [RecurrenceType] NVARCHAR(20) NOT NULL,
    [IntervalDays] INT NOT NULL DEFAULT 1,
    [RecurrenceEndDate] DATE NULL,
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_TaskRecurrence_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_TaskRecurrence_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_TaskRecurrence_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [CreatedBy] INT NOT NULL,
    [UpdatedBy] INT NOT NULL,
    [RowVersion] ROWVERSION,
    CONSTRAINT [FK_TaskRecurrence_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskRecurrence_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskRecurrence_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [CK_TaskRecurrence_IntervalDays] CHECK ([IntervalDays] > 0),
    CONSTRAINT [CK_TaskRecurrence_RecurrenceType] CHECK ([RecurrenceType] IN ('Daily', 'Weekly', 'Monthly', 'Custom')),
    CONSTRAINT [CK_TaskRecurrence_RecurrenceType_NotBlank] CHECK (LEN(LTRIM(RTRIM([RecurrenceType]))) > 0),
    CONSTRAINT [CK_TaskRecurrence_DeletedAt_RequiresIsDeleted] CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_TaskRecurrence_DeletedBy_RequiresIsDeleted] CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
)
GO

CREATE NONCLUSTERED INDEX [IX_TaskRecurrence_Active]
ON [dbo].[TaskRecurrence]([RecurrenceID])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_TaskRecurrence_EndDate_Active]
ON [dbo].[TaskRecurrence]([RecurrenceEndDate])
WHERE [IsDeleted] = 0 AND [RecurrenceEndDate] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_TaskRecurrence_Type_Active]
ON [dbo].[TaskRecurrence]([RecurrenceType])
INCLUDE ([IntervalDays], [RecurrenceEndDate])
WHERE [IsDeleted] = 0;
GO

-- =========================================================================
-- Trigger: TR_TaskRecurrence_UpdateAudit
-- Table:   [dbo].[TaskRecurrence]
-- Purpose: 
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [TaskRecurrence] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- =========================================================================
CREATE TRIGGER [dbo].[TR_TaskRecurrence_UpdateAudit]
ON [dbo].[TaskRecurrence]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE tr
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[TaskRecurrence] tr
        INNER JOIN inserted i ON tr.RecurrenceID = i.RecurrenceID;
    END;
END;
GO
