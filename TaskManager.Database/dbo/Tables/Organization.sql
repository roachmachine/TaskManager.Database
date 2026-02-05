CREATE TABLE [dbo].[Organization] (
    [OrganizationID]   INT           IDENTITY (1, 1) NOT NULL,
    [OrganizationName] VARCHAR (100) NOT NULL,
    [IsActive]         BIT           NOT NULL DEFAULT 1,
    [CreateDate]       DATETIME      CONSTRAINT [DF_Organization_CreateDate] DEFAULT (getutcdate()) NOT NULL,
    [UpdateDate]       DATETIME      CONSTRAINT [DF_Organization_UpdateDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED ([OrganizationID] ASC),
    CONSTRAINT [UQ_Organization_OrganizationName] UNIQUE ([OrganizationName])
);

