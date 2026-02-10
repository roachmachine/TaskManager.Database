/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

PRINT 'Post-Deployment Script Started'

:r .\Reference\UserTypes.sql
:r .\Reference\User.sql

--------------------------
--Bootstrap the table
--------------------------
PRINT 'Seeding initial data for UserType and User tables...'

UPDATE [dbo].[UserType] 
SET CreatedBy = 1, UpdatedBy = 1 

-- Set CreatedBy and UpdatedBy to NOT NULL after seeding initial data
ALTER TABLE [dbo].[UserType]
ALTER COLUMN CreatedBy INT NOT NULL;

ALTER TABLE [dbo].[UserType]
ALTER COLUMN UpdatedBy INT NOT NULL;

ALTER TABLE [dbo].[User]
ALTER COLUMN CreatedBy INT NOT NULL;

ALTER TABLE [dbo].[User]
ALTER COLUMN UpdatedBy INT NOT NULL;

PRINT 'Initial data seeding completed successfully.'

PRINT 'Post-Deployment Script Ended'
