----- Track Table (CRUD Procedures)
-- Add new Track
CREATE PROCEDURE dbo.sp_Add_Track
    @Track_ID INT,
    @Track_Name VARCHAR(200),
    @Total_Hours INT,
    @Dept_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Check required values
    IF @Track_ID IS NULL OR @Track_ID <= 0
    BEGIN
        SELECT 'Error: Track_ID must be a positive integer.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF LTRIM(RTRIM(ISNULL(@Track_Name, ''))) = ''
    BEGIN
        SELECT 'Error: Track_Name cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @Total_Hours IS NULL OR @Total_Hours < 200
    BEGIN
        SELECT 'Error: Total_Hours must be at least 200 hours.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @Dept_ID IS NULL OR @Dept_ID <= 0
    BEGIN
        SELECT 'Error: Dept_ID must be a positive integer.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Check if Track already exists
    IF EXISTS (SELECT 1 FROM dbo.Track WHERE Track_ID = @Track_ID)
    BEGIN
        SELECT 'Error: Track_ID already exists.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Track WHERE Track_Name = @Track_Name)
    BEGIN
        SELECT 'Error: Track_Name already exists.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Validate Dept_ID existence in Department table
    IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_ID = @Dept_ID)
    BEGIN
        SELECT 'Error: Invalid Dept_ID — department not found.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 4️. Business rule check
    IF @Total_Hours >= 1000
    BEGIN
        SELECT 'Error: Total_Hours seems unrealistically high.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 5. Insert new Track
    INSERT INTO dbo.Track (Track_ID, Track_Name, Total_Hours, Dept_ID)
    VALUES (@Track_ID, @Track_Name, @Total_Hours, @Dept_ID);

    COMMIT TRANSACTION;

    SELECT 'Track added successfully. Track_ID = ' + CAST(@Track_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
--------------------------------------------------------------
-- Get Track
CREATE PROCEDURE dbo.sp_Get_Track
    @Track_ID INT = NULL,
    @Track_Name VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate input
    IF (@Track_ID IS NULL OR @Track_ID <= 0) AND 
       (@Track_Name IS NULL OR LTRIM(RTRIM(@Track_Name)) = '')
    BEGIN
        SELECT 'Error: You must provide either Track_ID or Track_Name.' AS Message;
        RETURN;
    END

    -- 2. Retrieve track details
    IF @Track_ID IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Track WHERE Track_ID = @Track_ID)
        BEGIN
            SELECT 'Error: No track found with this ID.' AS Message;
            RETURN;
        END

        SELECT * FROM dbo.Track WHERE Track_ID = @Track_ID;
        SELECT 'Track retrieved successfully by ID.' AS Message;
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Track WHERE Track_Name = @Track_Name)
        BEGIN
            SELECT 'Error: No track found with this Name.' AS Message;
            RETURN;
        END

        SELECT * FROM dbo.Track WHERE Track_Name = @Track_Name;
        SELECT 'Track retrieved successfully by Name.' AS Message;
    END
END;
--------------------------------------------------------------
-- Update Track
CREATE PROCEDURE dbo.sp_Update_Track
    @Track_ID INT,
    @Track_Name VARCHAR(200),
    @New_Track_Name VARCHAR(200) = NULL,
    @New_Total_Hours INT = NULL,
    @New_Dept_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Old_Dept_ID INT;

    -- 1. Validate input
    IF @Track_ID IS NULL OR @Track_ID <= 0
    BEGIN
        SELECT 'Error: Invalid Track_ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @Track_Name IS NULL OR LTRIM(RTRIM(@Track_Name)) = ''
    BEGIN
        SELECT 'Error: Track_Name cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Check if track exists and get its current Dept_ID
    SELECT @Old_Dept_ID = Dept_ID
    FROM dbo.Track
    WHERE Track_ID = @Track_ID AND Track_Name = @Track_Name;

    IF @Old_Dept_ID IS NULL
    BEGIN
        SELECT 'Error: No track found with this ID and Name.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Ensure current department still exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_ID = @Old_Dept_ID)
    BEGIN
        SELECT 'Error: Department linked to this track does not exist.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 4. Validate new Dept_ID if provided
    IF @New_Dept_ID IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_ID = @New_Dept_ID)
        BEGIN
            SELECT 'Error: New Department ID does not exist.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END

    -- 5. Validate new values
    IF @New_Track_Name IS NOT NULL AND LTRIM(RTRIM(@New_Track_Name)) = ''
    BEGIN
        SELECT 'Error: New Track name cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @New_Total_Hours IS NOT NULL AND @New_Total_Hours <= 0
    BEGIN
        SELECT 'Error: Total hours must be positive.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 6. Perform update
    UPDATE dbo.Track
    SET 
        Track_Name = ISNULL(@New_Track_Name, Track_Name),
        Total_Hours = ISNULL(@New_Total_Hours, Total_Hours),
        Dept_ID = ISNULL(@New_Dept_ID, Dept_ID)
    WHERE Track_ID = @Track_ID;

    COMMIT TRANSACTION;

    SELECT 'Track updated successfully. '
        + 'Old Dept_ID = ' + CAST(@Old_Dept_ID AS VARCHAR(10))
        + ', New Dept_ID = ' + ISNULL(CAST(@New_Dept_ID AS VARCHAR(10)), 'unchanged')
        + ', Track_ID = ' + CAST(@Track_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
-----------------------------------------
-- Delete Track 
-- No need for deleting any track