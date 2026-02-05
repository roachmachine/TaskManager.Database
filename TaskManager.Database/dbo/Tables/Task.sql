CREATE TABLE [dbo].[UserTask]
(
	[UserTaskID] INT NOT NULL PRIMARY KEY IDENTITY, 
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
    CONSTRAINT [FK_UserTask_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_UserTask_TaskRecurrence] FOREIGN KEY ([RecurrenceID]) REFERENCES [dbo].[TaskRecurrence]([RecurrenceID]) ON DELETE SET NULL
)
GO

CREATE NONCLUSTERED INDEX [IX_UserTask_UserID] ON [dbo].[UserTask]([UserID]);
GO

CREATE NONCLUSTERED INDEX [IX_UserTask_RecurrenceID] ON [dbo].[UserTask]([RecurrenceID]) WHERE [RecurrenceID] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_UserTask_StartDate] ON [dbo].[UserTask]([StartDate]) WHERE [IsActive] = 1;