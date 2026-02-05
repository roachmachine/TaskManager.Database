CREATE TABLE [dbo].[TaskRecurrenceDays]
(
    [RecurrenceDayID] INT NOT NULL PRIMARY KEY IDENTITY,
    [RecurrenceID] INT NOT NULL,
    [DayOfWeek] INT NOT NULL, -- 0=Sunday, 1=Monday, 2=Tuesday, ... 6=Saturday
    [WeekNumber] INT NOT NULL DEFAULT 1, -- Which week in the cycle (1, 2, 3, etc.)
    CONSTRAINT [FK_TaskRecurrenceDays_TaskRecurrence] FOREIGN KEY ([RecurrenceID]) REFERENCES [dbo].[TaskRecurrence]([RecurrenceID]) ON DELETE CASCADE,
    CONSTRAINT [UQ_TaskRecurrenceDays_Recurrence_Day_Week] UNIQUE ([RecurrenceID], [DayOfWeek], [WeekNumber]),
    CONSTRAINT [CK_TaskRecurrenceDays_DayOfWeek] CHECK ([DayOfWeek] BETWEEN 0 AND 6),
    CONSTRAINT [CK_TaskRecurrenceDays_WeekNumber] CHECK ([WeekNumber] > 0)
)
GO

CREATE NONCLUSTERED INDEX [IX_TaskRecurrenceDays_RecurrenceID] ON [dbo].[TaskRecurrenceDays]([RecurrenceID], [WeekNumber], [DayOfWeek]);
