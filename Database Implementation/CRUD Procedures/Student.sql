----- Student Table (CRUD Procedures)
-- Add new Student
CREATE PROCEDURE dbo.sp_Add_Student
    @Student_ID BIGINT,
    @Student_Name VARCHAR(60),
    @Gender VARCHAR(6),
    @Phone_Number VARCHAR(11),
    @Birth_Date DATE,
    @Email VARCHAR(100),
    @Password VARCHAR(255),
    @Governorate VARCHAR(15),
    @Graduation_Year INT,
    @GPA DECIMAL(3,2),
    @Faculty_ID INT,
    @Intake_Track_Branch_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Validate National ID format (must be 14 digits)
        IF @Student_ID IS NULL OR LEN(@Student_ID) <> 14
        BEGIN
            SELECT 'Error: Invalid National ID.' AS Message;
            RETURN;
        END

        -- 2. Check for duplicate Student_ID or Email before inserting
        IF EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
        BEGIN
            SELECT 'Student ID already exists.' AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Student WHERE Email = @Email)
        BEGIN
            SELECT 'Email already exists.' AS Message;
            RETURN;
        END

        -- 3. Hash the password
        DECLARE @HashedPassword VARBINARY(64);
        SET @HashedPassword = HASHBYTES('SHA2_256', @Password);


        -- 4. Insert new student record
        INSERT INTO dbo.Student (
            Student_ID, Student_Name, Gender, Phone_Number, Birthdate, Email, Password, Governorate, 
            Graduation_Year, GPA, Faculty_ID, Intake_Track_Branch_ID)

        VALUES (@Student_ID, @Student_Name, @Gender, @Phone_Number, @Birth_Date, @Email, CONVERT(VARCHAR(128), @HashedPassword, 2), @Governorate,
            @Graduation_Year, @GPA, @Faculty_ID, @Intake_Track_Branch_ID);

        SELECT 'Student added successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------
-- Get Student
CREATE PROCEDURE dbo.sp_Get_Student
    @Student_ID BIGINT = NULL,
    @Student_Name VARCHAR(60) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Validate input
    IF @Student_ID IS NULL OR LEN(@Student_ID) <> 14
    BEGIN
        SELECT 'Error: Invalid Student_ID.' AS Message;
        RETURN;
    END

    -- 2. Check if Student exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'Error: No student found with this Student_ID.' AS Message;
        RETURN;
    END

    -- 3. Return Student Info with Track name
    SELECT 
        ST.Student_ID, ST.Student_Name, ST.Gender,
        ST.Governorate, T.Track_Name
    FROM dbo.Student AS ST
    JOIN dbo.Intake_Track_Branch AS ITB
      ON ST.Intake_Track_Branch_ID = ITB.Intake_Track_Branch_ID
    JOIN Track AS T
      ON ITB.Track_ID = T.Track_ID
    WHERE
        (@Student_ID IS NULL OR ST.Student_ID = @Student_ID)
        AND
        (@Student_Name IS NULL OR ST.Student_Name = @Student_Name);
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------------
-- Update Student
CREATE PROCEDURE dbo.sp_Update_Student
    @Student_ID BIGINT,
    @Student_Name VARCHAR(60),
    @Gender VARCHAR(6),
    @Phone_Number VARCHAR(11),
    @Birth_Date DATE,
    @Email VARCHAR(100),
    @Password VARCHAR(255),
    @Governorate VARCHAR(15),
    @Graduation_Year INT,
    @GPA DECIMAL(3,2),
    @Faculty_ID INT,
    @Intake_Track_Branch_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check if the student exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'Student ID not found.' AS Message;
        RETURN;
    END

    -- 2. Update the student record
    UPDATE dbo.Student
    SET
        Student_Name = @Student_Name,
        Gender = @Gender,
        Phone_Number = @Phone_Number,
        Birthdate = @Birth_Date,
        Email = @Email,
        Password = @Password,
        Governorate = @Governorate,
        Graduation_Year = @Graduation_Year,
        GPA = @GPA,
        Faculty_ID = @Faculty_ID,
        Intake_Track_Branch_ID = @Intake_Track_Branch_ID
    WHERE Student_ID = @Student_ID;

    -- 3. Confirm success
    SELECT 'Student record updated successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------
CREATE PROCEDURE dbo.sp_Delete_Student
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;
    -- 1. Check if the student exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'No student found with this ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Delete from parent table
    DELETE FROM dbo.Student WHERE Student_ID = @Student_ID;

    COMMIT TRANSACTION;

    SELECT 'Student and all related records deleted successfully.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;