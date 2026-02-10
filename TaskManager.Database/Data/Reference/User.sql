SET IDENTITY_INSERT [dbo].[UserType] OFF;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [dbo].[User] ON;

    MERGE [dbo].[User] AS target
    USING (VALUES
        (1, N'System', N'system@example.com', 1, NULL, N'UTC', SYSUTCDATETIME(), SYSUTCDATETIME(), NULL, NULL),
        (2, N'admin@example.com', N'admin@example.com', 2, NULL, N'UTC', SYSUTCDATETIME(), SYSUTCDATETIME(), NULL, NULL)
    ) AS source ([UserID], [UserName], [Email], [UserTypeID], [OrgProgramID], [TimeZoneID], [CreatedAt], [UpdatedAt], [CreatedBy], [UpdatedBy])
    ON target.[UserID] = source.[UserID]
    WHEN NOT MATCHED THEN
        INSERT ([UserID], [UserName], [Email], [UserTypeID], [OrgProgramID], [TimeZoneID], [CreatedAt], [UpdatedAt], [CreatedBy], [UpdatedBy])
        VALUES (source.[UserID], source.[UserName], source.[Email], source.[UserTypeID], source.[OrgProgramID], source.[TimeZoneID], source.[CreatedAt], source.[UpdatedAt], source.[CreatedBy], source.[UpdatedBy]);

    SET IDENTITY_INSERT [dbo].[User] OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    -- Re-throw the error
    THROW;
END CATCH;
