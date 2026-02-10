CREATE TABLE [dbo].[TaskNotification]
(
    [TaskNotificationID] INT NOT NULL PRIMARY KEY IDENTITY,
    [RecurrenceID] INT NULL,
    [OffsetValue] INT NOT NULL, -- N minutes, hours, or days before task
    [OffsetType] NVARCHAR(10) NOT NULL, -- 'Minutes', 'Hours', 'Days'
    [IsEnabled] BIT NOT NULL DEFAULT 1,
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_TaskNotification_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_TaskNotification_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_TaskNotification_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [CreatedBy] INT NULL,
    [UpdatedBy] INT NULL,
    [RowVersion] ROWVERSION,  -- for optimistic concurrency
    CONSTRAINT [FK_TaskNotification_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskNotification_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskNotification_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskNotification_TaskRecurrence] FOREIGN KEY ([RecurrenceID]) REFERENCES [dbo].[TaskRecurrence]([RecurrenceID]) ON DELETE SET NULL,
    CONSTRAINT [CK_TaskNotification_OffsetValue] CHECK ([OffsetValue] > 0),
    CONSTRAINT [CK_TaskNotification_OffsetType] CHECK ([OffsetType] IN ('Minutes', 'Hours', 'Days')),
    CONSTRAINT [CK_TaskNotification_OffsetType_NotBlank] CHECK (LEN(LTRIM(RTRIM([OffsetType]))) > 0),
    CONSTRAINT [CK_TaskNotification_DeletedAt_RequiresIsDeleted] CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_TaskNotification_DeletedBy_RequiresIsDeleted] CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
)
GO

-- Filtered index for enabled and not deleted notifications by RecurrenceID
CREATE NONCLUSTERED INDEX [IX_TaskNotification_RecurrenceID_Enabled]
ON [dbo].[TaskNotification]([RecurrenceID])
WHERE [IsEnabled] = 1 AND [IsDeleted] = 0;
GO

-- =========================================================================
-- Trigger: TR_TaskNotification_UpdateAudit
-- Table:   [dbo].[TaskNotification]
-- Purpose:
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [TaskNotification] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- =========================================================================
CREATE TRIGGER [dbo].[TR_TaskNotification_UpdateAudit]
ON [dbo].[TaskNotification]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE tn
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[TaskNotification] tn
        INNER JOIN inserted i ON tn.TaskNotificationID = i.TaskNotificationID;
    END;
END;
GO
