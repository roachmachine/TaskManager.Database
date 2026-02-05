# Task Manager Database Schema :file_folder:

## Overview :pushpin:
SQL Server Database Project for a task management application with support for recurring tasks, notifications, and multi-tenant organization structure.
Includes major functionality to support daylight savings time and crossing time zones.

## Database Schema :bricks:

### Core Tables :jigsaw:

#### **Organization** :office:
Root-level entity for multi-tenant support.
- Primary Key: `OrganizationID`
- Unique constraint on `OrganizationName`
- Supports soft-delete via `IsActive`

#### **Program** :toolbox:
Programs belong to Organizations.
- Primary Key: `ProgramID`
- Foreign Key: `OrganizationID`
- Unique constraint on `ProgramName` per organization
- Supports soft-delete via `IsActive`

#### **UserType** :technologist:
Defines user roles (e.g., Admin, Standard User, Manager).
- Primary Key: `UserTypeID`
- Unique constraint on `UserType`

#### **User** :bust_in_silhouette:
Application users with organization/program membership.
- Primary Key: `UserID`
- Foreign Keys: `UserTypeID`, `OrganizationID`, `ProgramID`
- Unique constraint on `Email`
- Stores user's current `TimeZoneID` for location-aware task notifications
- Supports soft-delete via `IsActive`
- Email field supports up to 255 characters

### Task Management Tables :white_check_mark:

#### **Task** :memo:
Core task entity.
- Primary Key: `TaskID`
- Foreign Keys: `UserID`, `RecurrenceID` (nullable)
- Stores `LocalTime` for task execution (time-only, uses User's timezone)
- Optional `TaskDescription` for detailed information
- `StartDate` and optional `EndDate` for task scheduling
- Supports soft-delete via `IsActive`
- Indexed on `UserID`, `RecurrenceID`, and `StartDate`

#### **TaskSteps** :receipt:
Sub-tasks or checklist items for a Task.
- Primary Key: `TaskStepID`
- Foreign Key: `TaskID` (CASCADE delete)
- `StepOrder` determines display sequence
- Tracks completion status via `IsCompleted` and `CompletedDate`
- Unique constraint on `TaskID` + `StepOrder`

#### **TaskRecurrence** :repeat:
Defines recurrence patterns for tasks.
- Primary Key: `RecurrenceID`
- `RecurrenceType`: Daily, Weekly, Monthly, Custom
- `IntervalDays`: Number of days between occurrences
- Optional `RecurrenceEndDate` (NULL = no end)
- CHECK constraint ensures valid recurrence types and positive intervals

#### **TaskRecurrenceDays** :calendar:
Specifies which days tasks recur (for weekly patterns).
- Primary Key: `RecurrenceDayID`
- Foreign Key: `RecurrenceID` (CASCADE delete)
- `DayOfWeek`: 0=Sunday through 6=Saturday
- `WeekNumber`: Supports multi-week patterns (e.g., Week 1: Monday, Week 2: Wednesday)
- Unique constraint on `RecurrenceID` + `DayOfWeek` + `WeekNumber`

#### **TaskNotification** :bell:
Defines notification timing for recurring tasks.
- Primary Key: `TaskNotificationID`
- Foreign Key: `RecurrenceID` (CASCADE delete)
- `OffsetValue` + `OffsetType`: Specifies notification time (e.g., 15 Minutes, 2 Hours, 1 Days before)
- `IsEnabled`: Toggle notifications on/off
- Supports multiple notifications per recurrence
- CHECK constraint ensures valid offset types

## Timezone Handling :globe_with_meridians:

### Design Philosophy :bulb:
Tasks are stored with **user's intended local time** and calculated dynamically based on the user's current timezone. This ensures notifications fire at the correct local time even when:
- User travels to a different timezone
- Daylight Saving Time transitions occur

### Implementation :gear:
1. **User.TimeZoneID** - Stores user's current timezone (e.g., 'Eastern Standard Time', 'Pacific Standard Time')
2. **Task.LocalTime** - Stores intended time (e.g., 3:00 PM)
3. **Application Logic** - Converts local time to UTC based on user's timezone for notification scheduling

### Example :white_check_mark:
**User in New York (EST):**
- Creates task: "Alert at 3 PM"
- Stored as: `LocalTime = 15:00:00`, User has `TimeZoneID = 'Eastern Standard Time'`

**Before DST (Winter):**
- 3 PM EST = 8 PM UTC ? Alert fires at 8 PM UTC

**After DST (Summer):**
- 3 PM EDT = 7 PM UTC ? Alert fires at 7 PM UTC

**User travels to Los Angeles:**
- Updates `User.TimeZoneID = 'Pacific Standard Time'`
- Alert now fires at 3 PM PST/PDT (user's new local time)

## Recurrence Pattern Examples :repeat:

### Daily Tasks :calendar:
```sql
RecurrenceType = 'Daily'
IntervalDays = 1  -- Every day
IntervalDays = 2  -- Every other day
```

### Weekly Tasks :spiral_calendar:
```sql
-- Every Monday
RecurrenceType = 'Weekly'
IntervalDays = 7
TaskRecurrenceDays: DayOfWeek = 1, WeekNumber = 1

-- Every Tuesday and Friday
RecurrenceType = 'Weekly'
IntervalDays = 7
TaskRecurrenceDays: 
  - DayOfWeek = 2, WeekNumber = 1
  - DayOfWeek = 5, WeekNumber = 1

-- Every other week on Monday
RecurrenceType = 'Weekly'
IntervalDays = 14
TaskRecurrenceDays: DayOfWeek = 1, WeekNumber = 1
```

### Complex Patterns :test_tube:
```sql
-- Week 1: Monday, Week 2: Wednesday (repeating every 2 weeks)
RecurrenceType = 'Weekly'
IntervalDays = 14
TaskRecurrenceDays:
  - DayOfWeek = 1, WeekNumber = 1
  - DayOfWeek = 3, WeekNumber = 2
```

## Indexes :zap:

Performance indexes are created on:
- All foreign key columns
- Frequently queried columns (UserName, StartDate)
- Filtered indexes on active records only (WHERE IsActive = 1)
- Composite indexes for common query patterns

## Data Integrity :lock:

### Foreign Key Cascade Rules :link:
- **TaskSteps ? Task**: CASCADE delete (steps deleted with task)
- **TaskRecurrenceDays ? TaskRecurrence**: CASCADE delete
- **TaskNotification ? TaskRecurrence**: CASCADE delete
- **Task ? TaskRecurrence**: SET NULL (task remains if recurrence deleted)

### CHECK Constraints :test_tube:
- `DayOfWeek` between 0-6
- `WeekNumber` > 0
- `IntervalDays` > 0
- `OffsetValue` > 0
- `RecurrenceType` in valid set
- `OffsetType` in valid set

### Soft Delete :broom:
All major entities support soft-delete via `IsActive` flag:
- Organization
- Program
- User
- Task

## Audit Trail :clock3:
All tables include:
- `CreateDate` - UTC timestamp of record creation
- `UpdateDate` - UTC timestamp of last modification

## Building the Database :toolbox:
1. Open solution in Visual Studio
2. Build the database project
3. Publish to target SQL Server instance

## Notes :memo:
- All timestamps stored in UTC
- User timezone conversion handled in application layer
- Email field supports RFC-compliant email addresses (up to 255 chars)
- Task names support up to 200 characters
- Designed for SQL Server 2016+
