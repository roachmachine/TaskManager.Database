CREATE TABLE [dbo].[TaskRecurrence]
(
    [RecurrenceID] INT NOT NULL PRIMARY KEY IDENTITY,
    [RecurrenceType] VARCHAR(20) NOT NULL, -- 'Daily', 'Weekly', 'Monthly', 'Custom'
    [IntervalDays] INT NOT NULL DEFAULT 1, -- Every N days (Daily: 1,2,3... Weekly: 7,14,21...)
    [RecurrenceEndDate] DATE NULL, -- NULL = no end date
    [CreatedDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [CK_TaskRecurrence_IntervalDays] CHECK ([IntervalDays] > 0),
    CONSTRAINT [CK_TaskRecurrence_RecurrenceType] CHECK ([RecurrenceType] IN ('Daily', 'Weekly', 'Monthly', 'Custom'))
)