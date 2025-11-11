----- Employment Table (CRUD Procedures)
-- Add new Employment
CREATE PROCEDURE dbo.sp_Add_Employment
    @Type VARCHAR(10),
    @Company VARCHAR(50),
    @Job_Title VARCHAR(MAX),
    @Salary INT,
    @Start_Date DATE,
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    DECLARE @New_ID INT;

    -- 1. Generate new Employment_ID automatically
    SELECT @New_ID = ISNULL(MAX(Employment_ID), 0) + 1
    FROM dbo.Employment;

    -- 2. Check that the student exists before inserting
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'No student found with the given Student_ID.' AS Message;
        RETURN;
    END;

    -- 3. Insert the new employment record
    INSERT INTO dbo.Employment (Employment_ID, Type, Company, Job_Title, Salary, Start_Date, Student_ID)
    VALUES (@New_ID, @Type, @Company, @Job_Title, @Salary, @Start_Date, @Student_ID);

    -- 4. Confirm success
    SELECT 'Employment record added successfully. New Employment_ID = ' + CAST(@New_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------
-- Get Employment
CREATE PROCEDURE dbo.sp_Get_Employment
    @Employment_ID INT = NULL,
    @Company VARCHAR(50) = NULL,
    @Student_ID BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        E.*,
        S.Student_Name
    FROM dbo.Employment AS E
    INNER JOIN dbo.Student AS S 
        ON E.Student_ID = S.Student_ID
    WHERE
        (@Employment_ID IS NULL OR E.Employment_ID = @Employment_ID)
        AND (@Company IS NULL OR E.Company LIKE '%' + @Company + '%')
        AND (@Student_ID IS NULL OR E.Student_ID = @Student_ID)
    ORDER BY E.Start_Date DESC;
END;
------------------------------------------------------------
-- Update Employment
CREATE PROCEDURE dbo.sp_Update_Employment
    @Employment_ID INT,
    @Type VARCHAR(10),
    @Company VARCHAR(50),
    @Job_Title VARCHAR(MAX),
    @Salary INT,
    @Start_Date DATE,
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check if the Employment record exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employment WHERE Employment_ID = @Employment_ID)
    BEGIN
        SELECT 'No employment record found with the provided Employment_ID.' AS Message;
        RETURN;
    END;

    -- 2. Validate Student_ID before updating
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'Invalid Student_ID. Update cancelled.' AS Message;
        RETURN;
    END;

    -- 3. Perform the update
    UPDATE dbo.Employment
    SET
        Type = @Type,
        Company = @Company,
        Job_Title = @Job_Title,
        Salary = @Salary,
        Start_Date = @Start_Date,
        Student_ID = @Student_ID
  WHERE Employment_ID = @Employment_ID;

    -- 5. Confirm success
    IF @@ROWCOUNT > 0
        SELECT 'Employment record updated successfully.' AS Message;
    ELSE
        SELECT 'Update failed or no changes were made.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
---------------------------------------------
-- Delete Employment
CREATE PROCEDURE dbo.sp_Delete_Employment
    @Employment_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check if employment record exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employment WHERE Employment_ID = @Employment_ID)
    BEGIN
        SELECT 'No employment record found with the provided ID.' AS Message;
        RETURN;
    END;

    -- Step 2: Perform the deletion
    DELETE FROM dbo.Employment
    WHERE Employment_ID = @Employment_ID;

    -- Step 3: Confirm deletion
    IF @@ROWCOUNT > 0
        SELECT 'Employment record deleted successfully.' AS Message;
    ELSE
        SELECT 'Deletion failed. No record was removed.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;