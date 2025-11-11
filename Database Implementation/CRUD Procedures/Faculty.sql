----- Faculty Table (CRUD Procedures)
-- Add new Faculty
CREATE PROCEDURE dbo.sp_Add_Faculty
    @Faculty_Name VARCHAR(100),
    @University VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @New_ID INT;

    -- 1. Check for duplicates
    IF EXISTS (
        SELECT 1 FROM dbo.Faculty
        WHERE Faculty_Name = @Faculty_Name AND University = @University)
    BEGIN
        SELECT 'Faculty already exists for this university. No new record added.' AS Message;
        RETURN;
    END;

    -- 2. Generate new Faculty_ID
    SELECT @New_ID = ISNULL(MAX(Faculty_ID), 0) + 1
    FROM dbo.Faculty;

    -- 3. Insert new record
    INSERT INTO dbo.Faculty (Faculty_ID, Faculty_Name, University)
    VALUES (@New_ID, @Faculty_Name, @University);

    -- 4. Confirm success
    SELECT 'Faculty added successfully. New Faculty_ID = ' + CAST(@New_ID AS VARCHAR(10)) AS Message;
END;
------------------------------------------------------------
-- Get Faculty
CREATE PROCEDURE dbo.sp_Get_Faculty
    @Faculty_ID INT = NULL,
    @Faculty_Name VARCHAR(100) = NULL,
    @University VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Faculty_ID,
        Faculty_Name,
        University
    FROM dbo.Faculty
    WHERE
        (@Faculty_ID IS NULL OR Faculty_ID = @Faculty_ID)
        AND (@Faculty_Name IS NULL OR Faculty_Name LIKE '%' + @Faculty_Name + '%')
        AND (@University IS NULL OR University LIKE '%' + @University + '%')
    ORDER BY University, Faculty_Name;
END;
------------------------------------------------------------
-- Update Faculty
CREATE PROCEDURE dbo.sp_Update_Faculty
    @Faculty_ID INT,
    @Faculty_Name VARCHAR(100),
    @University VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check if Faculty_ID exists
    IF EXISTS (SELECT 1 FROM dbo.Faculty WHERE Faculty_ID = @Faculty_ID)
    BEGIN
        UPDATE dbo.Faculty
        SET 
            Faculty_Name = @Faculty_Name,
            University = @University
        WHERE Faculty_ID = @Faculty_ID;

        SELECT 'Faculty record updated successfully.' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No faculty found with the provided Faculty_ID.' AS Message;
    END
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------
-- Delete Faculty
-- No need for deleting any faculty