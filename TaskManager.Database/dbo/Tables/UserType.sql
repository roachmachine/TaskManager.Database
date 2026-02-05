CREATE TABLE [dbo].[UserType] (
    [UserTypeID] INT NOT NULL,
    [UserType]   VARCHAR (50) NOT NULL,
    [CreateDate] DATETIME     CONSTRAINT [DF_UserType_CreateDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_UserType] PRIMARY KEY CLUSTERED ([UserTypeID] ASC),
    CONSTRAINT [UQ_UserType_UserType] UNIQUE ([UserType])
);

