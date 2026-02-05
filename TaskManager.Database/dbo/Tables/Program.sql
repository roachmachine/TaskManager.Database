CREATE TABLE [dbo].[Program]
(
	[ProgramID] INT NOT NULL PRIMARY KEY IDENTITY,
	[ProgramName] VARCHAR(100) NOT NULL,
	[OrganizationID] INT NOT NULL,
	[IsActive] BIT NOT NULL DEFAULT 1,
	[CreateDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
	[UpdateDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
	CONSTRAINT [FK_Program_Organization] FOREIGN KEY ([OrganizationID]) REFERENCES [dbo].[Organization]([OrganizationID]),
	CONSTRAINT [UQ_Program_Name_Organization] UNIQUE ([ProgramName], [OrganizationID])
)
GO

CREATE NONCLUSTERED INDEX [IX_Program_OrganizationID] ON [dbo].[Program]([OrganizationID]) WHERE [IsActive] = 1;
