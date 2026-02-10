CREATE TABLE [dbo].[TaskRecurrenceDays]
(
    [RecurrenceDayID] INT NOT NULL PRIMARY KEY IDENTITY,
    [RecurrenceID] INT NOT NULL,
    [DayOfWeek] INT NOT NULL, -- 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday
    [WeekNumber] INT NOT NULL DEFAULT 1,
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_TaskRecurrenceDays_IsDeleted] DEFAULT 0,
    [DeletedAt] DATETIME2(3) NULL,
    [DeletedBy] INT NULL,
    [CreatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_TaskRecurrenceDays_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_TaskRecurrenceDays_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    [CreatedBy] INT NOT NULL,
    [UpdatedBy] INT NOT NULL,
    [RowVersion] ROWVERSION,
    CONSTRAINT [FK_TaskRecurrenceDays_CreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskRecurrenceDays_UpdatedBy_User] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskRecurrenceDays_DeletedBy_User] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_TaskRecurrenceDays_TaskRecurrence] FOREIGN KEY ([RecurrenceID]) REFERENCES [dbo].[TaskRecurrence]([RecurrenceID]) ON DELETE CASCADE,
    CONSTRAINT [CK_TaskRecurrenceDays_DayOfWeek] CHECK ([DayOfWeek] BETWEEN 0 AND 6),
    CONSTRAINT [CK_TaskRecurrenceDays_WeekNumber] CHECK ([WeekNumber] > 0),
    CONSTRAINT [CK_TaskRecurrenceDays_DeletedAt_RequiresIsDeleted] CHECK ([DeletedAt] IS NULL OR [IsDeleted] = 1),
    CONSTRAINT [CK_TaskRecurrenceDays_DeletedBy_RequiresIsDeleted] CHECK ([DeletedBy] IS NULL OR [IsDeleted] = 1)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_TaskRecurrenceDays_Recurrence_Day_Week_Active]
ON [dbo].[TaskRecurrenceDays]([RecurrenceID], [DayOfWeek], [WeekNumber])
WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_TaskRecurrenceDays_RecurrenceID] 
ON [dbo].[TaskRecurrenceDays]([RecurrenceID], [WeekNumber], [DayOfWeek])
WHERE [IsDeleted] = 0;
GO

-- ============================================================
-- Trigger: TR_TaskRecurrenceDays_UpdateAudit
-- Table:   [dbo].[TaskRecurrenceDays]
-- Purpose: 
--   Automatically updates the [UpdatedAt] timestamp whenever a row is modified.
--   This ensures audit trail accuracy without requiring application-level logic.
--
-- Behavior:
--   - Fires AFTER UPDATE operations on the [TaskRecurrenceDays] table.
--   - Sets [UpdatedAt] to the current UTC time for all modified rows.
--
-- Notes:
--   - [UpdatedBy] should still be set explicitly by the application layer.
--   - Uses SYSUTCDATETIME() to maintain consistency with CreatedAt default.
-- ============================================================
CREATE TRIGGER [dbo].[TR_TaskRecurrenceDays_UpdateAudit]
ON [dbo].[TaskRecurrenceDays]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT UPDATE([UpdatedAt])
    BEGIN
        UPDATE trd
        SET UpdatedAt = SYSUTCDATETIME()
        FROM [dbo].[TaskRecurrenceDays] trd
        INNER JOIN inserted i ON trd.RecurrenceDayID = i.RecurrenceDayID;
    END;
END;
GO
