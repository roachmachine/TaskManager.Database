CREATE TABLE [dbo].[Task]
(
	[TaskID] INT NOT NULL PRIMARY KEY IDENTITY, 
    [TaskName] VARCHAR(200) NOT NULL, 
    [TaskDescription] VARCHAR(1000) NULL,
    [LocalTime] TIME NOT NULL, -- User's intended local time (e.g., 3 PM)
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NULL,
    [UserID] INT NOT NULL, 
    [RecurrenceID] INT NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [UpdateDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [FK_Task_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_Task_TaskRecurrence] FOREIGN KEY ([RecurrenceID]) REFERENCES [dbo].[TaskRecurrence]([RecurrenceID]) ON DELETE SET NULL
)
GO

CREATE NONCLUSTERED INDEX [IX_Task_UserID] ON [dbo].[Task]([UserID]);
GO

CREATE NONCLUSTERED INDEX [IX_Task_RecurrenceID] ON [dbo].[Task]([RecurrenceID]) WHERE [RecurrenceID] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_Task_StartDate] ON [dbo].[Task]([StartDate]) WHERE [IsActive] = 1;