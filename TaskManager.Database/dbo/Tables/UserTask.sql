CREATE TABLE [dbo].[UserTask]
(
    [UserTaskID] INT NOT NULL PRIMARY KEY IDENTITY, 
    [TaskName] NVARCHAR(200) NOT NULL, 
    [TaskDescription] NVARCHAR(1000) NULL,
    [ImageUrl] NVARCHAR(500) NULL,
    [LocalTime] TIME NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NULL,
    [UserID] INT NOT NULL, 
    [RecurrenceID] INT NULL,
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_UserTask_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_UserTask_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_UserTask_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [CreatedBy] INT NOT NULL,
    [UpdatedBy] INT NOT NULL,
    [RowVersion] ROWVERSION,
    CONSTRAINT [FK_UserTask_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_UserTask_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_UserTask_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_UserTask_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User]([UserID]) ON DELETE CASCADE,
    CONSTRAINT [FK_UserTask_TaskRecurrence] FOREIGN KEY ([RecurrenceID]) REFERENCES [dbo].[TaskRecurrence]([RecurrenceID]) ON DELETE SET NULL,
    CONSTRAINT [CK_UserTask_TaskName_NotBlank] CHECK (LEN(LTRIM(RTRIM([TaskName]))) > 0),
    CONSTRAINT [CK_UserTask_EndDate_AfterStart] CHECK ([EndDate] IS NULL OR [EndDate] >= [StartDate]),
    CONSTRAINT [CK_UserTask_DeletedAt_RequiresIsDeleted] CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_UserTask_DeletedBy_RequiresIsDeleted] CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
)
GO

CREATE NONCLUSTERED INDEX [IX_UserTask_RecurrenceID] ON [dbo].[UserTask]([RecurrenceID]) WHERE [RecurrenceID] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_UserTask_UserID_Active]
ON [dbo].[UserTask]([UserID])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_UserTask_StartDate_Active]
ON [dbo].[UserTask]([StartDate])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_UserTask_EndDate_Active]
ON [dbo].[UserTask]([EndDate])
WHERE [IsDeleted] = 0 AND [EndDate] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_UserTask_UserID_StartDate_Includes]
ON [dbo].[UserTask]([UserID], [StartDate])
INCLUDE ([TaskName], [LocalTime], [EndDate], [RecurrenceID])
WHERE [IsDeleted] = 0;
GO

-- ============================================================================
-- Trigger: TR_UserTask_UpdateAudit
-- Table:   [dbo].[UserTask]
-- Purpose: 
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [UserTask] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- ============================================================================
CREATE TRIGGER [dbo].[TR_UserTask_UpdateAudit]
ON [dbo].[UserTask]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE ut
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[UserTask] ut
        INNER JOIN inserted i ON ut.UserTaskID = i.UserTaskID;
    END;
END;
GO
