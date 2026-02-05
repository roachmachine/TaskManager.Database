CREATE TABLE [dbo].[TaskNotification]
(
    [TaskNotificationID] INT NOT NULL PRIMARY KEY IDENTITY,
    [RecurrenceID] INT NOT NULL,
    [OffsetValue] INT NOT NULL, -- N minutes, hours, or days before task
    [OffsetType] VARCHAR(10) NOT NULL, -- 'Minutes', 'Hours', 'Days'
    [IsEnabled] BIT NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [FK_TaskNotification_TaskRecurrence] FOREIGN KEY ([RecurrenceID]) REFERENCES [dbo].[TaskRecurrence]([RecurrenceID]) ON DELETE CASCADE,
    CONSTRAINT [CK_TaskNotification_OffsetValue] CHECK ([OffsetValue] > 0),
    CONSTRAINT [CK_TaskNotification_OffsetType] CHECK ([OffsetType] IN ('Minutes', 'Hours', 'Days'))
)
GO

CREATE NONCLUSTERED INDEX [IX_TaskNotification_RecurrenceID] ON [dbo].[TaskNotification]([RecurrenceID]) WHERE [IsEnabled] = 1;