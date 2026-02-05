CREATE TABLE [dbo].[User] (
    [UserID]     INT          IDENTITY (1, 1) NOT NULL,
    [UserName]   VARCHAR (100) NOT NULL,
    [Email]      VARCHAR (255) NOT NULL,
    [UserTypeID] INT          NOT NULL,
    [OrganizationID] INT      NULL,
    [ProgramID]  INT          NULL,
    [TimeZoneID] VARCHAR(50)  NOT NULL DEFAULT 'UTC', -- User's current timezone
    [IsActive]   BIT          NOT NULL DEFAULT 1,
    [CreateDate] DATETIME     CONSTRAINT [DF_User_CreateDate] DEFAULT (getutcdate()) NOT NULL,
    [UpdateDate] DATETIME     CONSTRAINT [DF_User_UpdateDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [FK_User_UserType] FOREIGN KEY ([UserTypeID]) REFERENCES [dbo].[UserType]([UserTypeID]),
    CONSTRAINT [FK_User_Organization] FOREIGN KEY ([OrganizationID]) REFERENCES [dbo].[Organization]([OrganizationID]),
    CONSTRAINT [FK_User_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program]([ProgramID]),
    CONSTRAINT [UQ_User_Email] UNIQUE ([Email])
);
GO

CREATE NONCLUSTERED INDEX [IX_User_OrganizationID] ON [dbo].[User]([OrganizationID]);
GO

CREATE NONCLUSTERED INDEX [IX_User_ProgramID] ON [dbo].[User]([ProgramID]);
GO

CREATE NONCLUSTERED INDEX [IX_User_UserTypeID] ON [dbo].[User]([UserTypeID]);
GO

CREATE NONCLUSTERED INDEX [IX_User_UserName] ON [dbo].[User]([UserName]) WHERE [IsActive] = 1;