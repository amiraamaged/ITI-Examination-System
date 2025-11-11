----- Instructor Table (CRUD Procedures)
-- Add new instructor
CREATE PROCEDURE dbo.sp_Add_Instructor
    @Instructor_ID BIGINT,
    @Instructor_Name VARCHAR(100),
    @Salary INT,
    @Gender VARCHAR(10),
    @Email VARCHAR(100),
    @Password VARCHAR(100),
    @Phone_Number VARCHAR(20),
    @Dept_ID INT,
    @Hire_Date DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
   -- 1. Validate National ID format (must be 14 digits)
   IF @Instructor_ID IS NULL OR LEN(@Instructor_ID) <> 14
   BEGIN
          SELECT 'Error: Invalid National ID.' AS Message;
          RETURN;
   END

    -- 2. Check if Instructor_ID already exists
    IF EXISTS (SELECT 1 FROM dbo.Instructor WHERE Instructor_ID = @Instructor_ID)
    BEGIN
        SELECT 'Error: Instructor_ID already exists.' AS Message;
        RETURN;
    END

    -- 3. Check if Department exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_ID = @Dept_ID)
    BEGIN
        SELECT 'Error: No department found with this Dept_ID.' AS Message;
        RETURN;
    END

    -- 4. Check if Email is unique
    IF EXISTS (SELECT 1 FROM dbo.Instructor WHERE Email = @Email)
    BEGIN
        SELECT 'Error: Email already exists.' AS Message;
        RETURN;
    END
    -- 5. Basic Data Validation
    IF @Salary <= 0
        BEGIN
            SELECT 'Error: Salary must be greater than 0.' AS Message;
            RETURN;
        END

        IF @Gender NOT IN ('Male', 'Female')
        BEGIN
            SELECT 'Error: Gender must be Male or Female.' AS Message;
            RETURN;
        END

        IF LEN(@Phone_Number) <> 11
        BEGIN
            SELECT 'Error: Invalid phone number, Please Enter an Egyptian phone number' AS Message;
            RETURN;
        END
    -- 7. Hash the password
        DECLARE @HashedPassword VARBINARY(64);
        SET @HashedPassword = HASHBYTES('SHA2_256', @Password);

    -- 8. Insert the new instructor
    INSERT INTO dbo.Instructor (Instructor_ID, Instructor_Name, Salary, Gender, Email, Password, Phone_Number, Dept_ID, Hire_Date)
    VALUES (@Instructor_ID, @Instructor_Name, @Salary, @Gender, @Email, CONVERT(VARCHAR(128), @HashedPassword, 2), @Phone_Number, @Dept_ID, @Hire_Date);


    SELECT 'Instructor added successfully. National ID = ' + @Instructor_ID AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
-----------------------------------------------------------------------------------------------
-- Get Instructor 
CREATE PROCEDURE dbo.sp_Get_Instructor
    @Instructor_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Validate input
    IF @Instructor_ID IS NULL OR LEN(@Instructor_ID) <> 14
    BEGIN
        SELECT 'Error: Invalid Instructor_ID.' AS Message;
        RETURN;
    END

    -- 2. Check if Instructor exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Instructor WHERE Instructor_ID = @Instructor_ID)
    BEGIN
        SELECT 'Error: No instructor found with this Instructor_ID.' AS Message;
        RETURN;
    END

    -- 3. Return Instructor Info with Department name
    SELECT 
        i.Instructor_ID,
        i.Instructor_Name,
        i.Salary,
        i.Gender,
        i.Email,
        i.Phone_Number,
        i.Dept_ID,
        d.Dept_Name,
        i.Hire_Date
    FROM dbo.Instructor i
    LEFT JOIN dbo.Department d 
        ON i.Dept_ID = d.Dept_ID
    WHERE i.Instructor_ID = @Instructor_ID;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
-----------
-- Update Instructor 
CREATE PROCEDURE dbo.sp_Update_Instructor
    @Instructor_ID INT,
    @Instructor_Name VARCHAR(100),
    @Salary INT,
    @Gender VARCHAR(10),
    @Email VARCHAR(100),
    @Password VARCHAR(255),
    @Phone_Number VARCHAR(20),
    @Dept_ID INT,
    @Hire_Date DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Validate inputs
        IF @Instructor_ID IS NULL OR LEN(@Instructor_ID) <> 14
        BEGIN
            SELECT 'Error: Invalid Instructor_ID.' AS Message;
            RETURN;
        END

        -- 2. Check if Instructor exists
        IF NOT EXISTS (SELECT 1 FROM dbo.Instructor WHERE Instructor_ID = @Instructor_ID)
        BEGIN
            SELECT 'Error: No instructor found with this Instructor_ID.' AS Message;
            RETURN;
        END

        -- 3. Check if Department exists
        IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_ID = @Dept_ID)
        BEGIN
            SELECT 'Error: No department found with this Dept_ID.' AS Message;
            RETURN;
        END

        -- 4. Check if Email already exists for another instructor
        IF EXISTS (SELECT 1 FROM dbo.Instructor WHERE Email = @Email AND Instructor_ID <> @Instructor_ID)
        BEGIN
            SELECT 'Error: Email already exists for another instructor.' AS Message;
            RETURN;
        END

        -- 5. Perform update
        UPDATE dbo.Instructor
        SET 
            Instructor_Name = @Instructor_Name,
            Salary = @Salary,
            Gender = @Gender,
            Email = @Email,
            Password = @Password,
            Phone_Number = @Phone_Number,
            Dept_ID = @Dept_ID,
            Hire_Date = @Hire_Date
        WHERE Instructor_ID = @Instructor_ID;

        SELECT 'Instructor updated successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
---------------
-- Delete Insructor
CREATE PROCEDURE dbo.sp_Delete_Instructor
    @Instructor_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check if Instructor exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Instructor WHERE Instructor_ID = @Instructor_ID)
    BEGIN
        SELECT 'Error: No instructor found with this Instructor_ID.' AS Message;
        RETURN;
    END

    -- 2. Delete instructor
    DELETE FROM dbo.Instructor
    WHERE Instructor_ID = @Instructor_ID;

    SELECT 'Instructor deleted successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;