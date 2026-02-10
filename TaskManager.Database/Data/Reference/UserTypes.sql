SET IDENTITY_INSERT [dbo].[UserType] OFF;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [dbo].[User] ON;

-- Merge user type records defining the available user roles in the system
MERGE INTO dbo.[UserType] AS Target
USING (VALUES
    (1, 'System'),
    (2, 'Super User'),
    (3, 'Program Manager'),
    (4, 'Counselor'),
    (5, 'User')
) AS Source (UserTypeID, UserType)
ON Target.UserTypeID = Source.UserTypeID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (UserTypeID, UserType)
    VALUES (Source.UserTypeID, Source.UserType);

    SET IDENTITY_INSERT [dbo].[User] OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    -- Re-throw the error
    THROW;
END CATCH;