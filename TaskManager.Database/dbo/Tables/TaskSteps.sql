CREATE TABLE [dbo].[TaskSteps]
(
	[TaskStepID] INT NOT NULL PRIMARY KEY IDENTITY, 
    [TaskID] INT NOT NULL, 
    [StepTitle] VARCHAR(200) NOT NULL, 
    [StepDescription] VARCHAR(1000) NULL, 
    [StepOrder] INT NOT NULL DEFAULT 1,
    [IsCompleted] BIT NOT NULL DEFAULT 0,
    [CompletedDate] DATETIME NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [UpdateDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [FK_TaskSteps_Task] FOREIGN KEY ([TaskID]) REFERENCES [dbo].[Task]([TaskID]) ON DELETE CASCADE,
    CONSTRAINT [UQ_TaskSteps_Task_Order] UNIQUE ([TaskID], [StepOrder]),
    CONSTRAINT [CK_TaskSteps_StepOrder] CHECK ([StepOrder] > 0)
)
GO

CREATE NONCLUSTERED INDEX [IX_TaskSteps_TaskID] ON [dbo].[TaskSteps]([TaskID], [StepOrder]);
