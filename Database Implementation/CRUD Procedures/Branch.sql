----- Branch Table (CRUD Procedures)
-- Add new Branch
CREATE PROCEDURE dbo.sp_Add_Branch
    @Branch_ID INT,
    @Branch_Name VARCHAR(100),
    @Location VARCHAR(100),
    @Launching_Year INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Validate inputs
    IF @Branch_ID IS NULL OR @Branch_ID <= 0
    BEGIN
        SELECT 'Error: Invalid Branch_ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @Branch_Name IS NULL OR LTRIM(RTRIM(@Branch_Name)) = ''
    BEGIN
        SELECT 'Error: Branch_Name cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @Location IS NULL OR LTRIM(RTRIM(@Location)) = ''
    BEGIN
        SELECT 'Error: Location cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @Launching_Year IS NULL OR @Launching_Year > YEAR(GETDATE())
    BEGIN
        SELECT 'Error: Launching_Year cannot be in the future or empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Check if Branch already exists
    IF EXISTS (SELECT 1 FROM dbo.Branch WHERE Branch_ID = @Branch_ID OR Branch_Name = @Branch_Name)
    BEGIN
        SELECT 'Error: Branch with the same ID or Name already exists.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Insert new branch
    INSERT INTO dbo.Branch (Branch_ID, Branch_Name, Location, Launching_Year)
    VALUES (@Branch_ID, @Branch_Name, @Location, @Launching_Year);

    COMMIT TRANSACTION;
    SELECT 'Branch added successfully. Branch ID = ' + CAST(@Branch_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------
-- Get Branch
CREATE PROCEDURE dbo.sp_Get_Branch
    @Branch_ID INT = NULL,
    @Branch_Name VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    -- 1. Input validation
    IF (@Branch_ID IS NULL OR @Branch_ID <= 0) AND 
       (@Branch_Name IS NULL OR LTRIM(RTRIM(@Branch_Name)) = '')
    BEGIN
        SELECT 'Error: You must provide either Branch_ID or Branch_Name.' AS Message;
        RETURN;
    END

    -- 2. Retrieve branch details
    IF @Branch_ID IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Branch WHERE Branch_ID = @Branch_ID)
        BEGIN
            SELECT 'Error: No branch found with this ID.' AS Message;
            RETURN;
        END

        SELECT * FROM dbo.Branch WHERE Branch_ID = @Branch_ID;
        SELECT 'Branch retrieved successfully by ID.' AS Message;
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Branch WHERE Branch_Name = @Branch_Name)
        BEGIN
            SELECT 'Error: No branch found with this Name.' AS Message;
            RETURN;
        END

        SELECT * FROM dbo.Branch WHERE Branch_Name = @Branch_Name;
        SELECT 'Branch retrieved successfully by Name.' AS Message;
    END
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
-------
-- Update Branch
CREATE PROCEDURE dbo.sp_Update_Branch 
    @Branch_ID INT,
    @Branch_Name VARCHAR(100),
    @New_Branch_Name VARCHAR(100) = NULL,
    @New_Location VARCHAR(100) = NULL,
    @New_Launching_Year DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Validate input
    IF @Branch_ID IS NULL OR @Branch_ID <= 0
    BEGIN
        SELECT 'Error: Invalid Branch_ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @Branch_Name IS NULL OR LTRIM(RTRIM(@Branch_Name)) = ''
    BEGIN
        SELECT 'Error: Branch_Name cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Ensure branch exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Branch WHERE Branch_ID = @Branch_ID AND Branch_Name = @Branch_Name)
    BEGIN
        SELECT 'Error: No branch found with this ID and Name.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Validate new values
    IF @New_Branch_Name IS NOT NULL AND LTRIM(RTRIM(@New_Branch_Name)) = ''
    BEGIN
        SELECT 'Error: New Branch name cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @New_Location IS NOT NULL AND LTRIM(RTRIM(@New_Location)) = ''
    BEGIN
        SELECT 'Error: New Location cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @New_Launching_Year IS NOT NULL AND @New_Launching_Year > GETDATE()
    BEGIN
        SELECT 'Error: Launching year cannot be in the future.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 4. Perform update
    UPDATE dbo.Branch
    SET 
        Branch_Name = ISNULL(@New_Branch_Name, Branch_Name),
        Location = ISNULL(@New_Location, Location),
        Launching_Year = ISNULL(@New_Launching_Year, Launching_Year)
    WHERE Branch_ID = @Branch_ID;

    COMMIT TRANSACTION;
    SELECT 'Branch updated successfully. Branch ID = ' + CAST(@Branch_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------
-- Delete Branch
-- No need for deleting any branch