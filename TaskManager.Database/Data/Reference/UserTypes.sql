-- Merge user type records defining the available user roles in the system
MERGE INTO dbo.[UserType] AS Target
USING (VALUES
    (1, 'Super User'),
    (2, 'Program Manager'),
    (3, 'Counselor'),
    (4, 'User')
) AS Source (UserTypeID, UserType)
ON Target.UserTypeID = Source.UserTypeID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (UserTypeID, UserType)
    VALUES (Source.UserTypeID, Source.UserType);