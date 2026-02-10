CREATE TABLE [dbo].[TaskSteps]
(
    [TaskStepID] INT NOT NULL PRIMARY KEY IDENTITY, 
    [UserTaskID] INT NOT NULL, 
    [StepTitle] NVARCHAR(200) NOT NULL, 
    [StepDescription] NVARCHAR(1000) NULL, 
    [ImageUrl] NVARCHAR(500) NULL,
    [StepOrder] INT NOT NULL DEFAULT 1,
    [IsCompleted] BIT NOT NULL DEFAULT 0,
    [CompletedDate] DATETIME2(3) NULL,
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_TaskSteps_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_TaskSteps_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_TaskSteps_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [CreatedBy] INT NOT NULL,
    [UpdatedBy] INT NOT NULL,
    [RowVersion] ROWVERSION,
    CONSTRAINT [FK_TaskSteps_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskSteps_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskSteps_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskSteps_UserTask] FOREIGN KEY ([UserTaskID]) REFERENCES [dbo].[UserTask]([UserTaskID]) ON DELETE CASCADE,
    CONSTRAINT [CK_TaskSteps_StepOrder] CHECK ([StepOrder] > 0),
    CONSTRAINT [CK_TaskSteps_StepTitle_NotBlank] CHECK (LEN(LTRIM(RTRIM([StepTitle]))) > 0),
    CONSTRAINT [CK_TaskSteps_CompletedDate_Required] CHECK ([IsCompleted] = 0 OR [CompletedDate] IS NOT NULL),
    CONSTRAINT [CK_TaskSteps_DeletedAt_RequiresIsDeleted] CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_TaskSteps_DeletedBy_RequiresIsDeleted] CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_TaskSteps_UserTask_Order_Active]
ON [dbo].[TaskSteps]([UserTaskID], [StepOrder])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_TaskSteps_UserTaskID_Active]
ON [dbo].[TaskSteps]([UserTaskID])
WHERE [IsCompleted] = 0 AND [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_TaskSteps_UserTaskID_Completed]
ON [dbo].[TaskSteps]([UserTaskID], [CompletedDate])
WHERE [IsCompleted] = 1 AND [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_TaskSteps_UserTaskID_Order]
ON [dbo].[TaskSteps]([UserTaskID], [StepOrder])
INCLUDE ([StepTitle], [IsCompleted])
WHERE [IsDeleted] = 0;
GO

-- ============================================================================
-- Trigger: TR_TaskSteps_UpdateAudit
-- Table:   [dbo].[TaskSteps]
-- Purpose: 
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [TaskSteps] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- ============================================================================
CREATE TRIGGER [dbo].[TR_TaskSteps_UpdateAudit]
ON [dbo].[TaskSteps]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE ts
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[TaskSteps] ts
        INNER JOIN inserted i ON ts.TaskStepID = i.TaskStepID;
    END;
END;
GO
