----- Department Table (CRUD Procedures)
-- Add Department
CREATE PROCEDURE dbo.sp_Add_Department
    @Dept_ID INT,
    @Dept_Name VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Check if Dept_ID already exists
    IF EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_ID = @Dept_ID)
    BEGIN
        SELECT 'Error: Dept_ID already exists.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Check if Dept_Name is empty or NULL
    IF @Dept_Name IS NULL OR LTRIM(RTRIM(@Dept_Name)) = ''
    BEGIN
        SELECT 'Error: Dept_Name cannot be empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Check length of Dept_Name
    IF LEN(@Dept_Name) > 200
    BEGIN
        SELECT 'Error: Dept_Name is too long. Maximum 200 characters allowed.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 4. Check if Dept_Name already exists
    IF EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_Name = @Dept_Name)
    BEGIN
        SELECT 'Error: Dept_Name already exists.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 5. Insert new department
    INSERT INTO dbo.Department (Dept_ID, Dept_Name)
    VALUES (@Dept_ID, @Dept_Name);

    COMMIT TRANSACTION;

    SELECT 'Department added successfully. Dept_ID = ' + CAST(@Dept_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
---------
-- Get Department
CREATE PROCEDURE dbo.sp_Get_Department
    @Dept_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Check if Dept_ID is valid
    IF @Dept_ID IS NULL
    BEGIN
        SELECT 'Error: Dept_ID must be provided.' AS Message;
        RETURN;
    END

    -- 2. Check if department exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_ID = @Dept_ID)
    BEGIN
        SELECT 'Error: No department found with this Dept_ID.' AS Message;
        RETURN;
    END

    -- 3. Return department info
    SELECT Dept_ID, Dept_Name
    FROM dbo.Department
    WHERE Dept_ID = @Dept_ID;

END;
-------------
-- Update Department
CREATE PROCEDURE dbo.sp_Update_Department
    @Dept_ID INT,
    @Dept_Name VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

    -- 1. Check if Dept_ID is valid
    IF @Dept_ID IS NULL
    BEGIN
        SELECT 'Error: Dept_ID must be provided.' AS Message;
        RETURN;
    END

    -- 2. Check if department exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_ID = @Dept_ID)
    BEGIN
        SELECT 'Error: No department found with this Dept_ID.' AS Message;
        RETURN;
    END

    -- 3. Check if Dept_Name is empty or NULL
    IF @Dept_Name IS NULL OR LTRIM(RTRIM(@Dept_Name)) = ''
    BEGIN
        SELECT 'Error: Dept_Name cannot be empty.' AS Message;
        RETURN;
    END

    -- 4. Check length of Dept_Name
    IF LEN(@Dept_Name) > 200
    BEGIN
        SELECT 'Error: Dept_Name is too long. Maximum 200 characters allowed.' AS Message;
        RETURN;
    END

    -- 5. Check if Dept_Name already exists (excluding current)
    IF EXISTS (SELECT 1 FROM dbo.Department WHERE Dept_Name = @Dept_Name AND Dept_ID <> @Dept_ID)
    BEGIN
        SELECT 'Error: Dept_Name already exists.' AS Message;
        RETURN;
    END

    -- 6. Update department
    UPDATE dbo.Department
    SET Dept_Name = @Dept_Name
    WHERE Dept_ID = @Dept_ID;

    SELECT 'Department updated successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
--------------------
-- Delete Department
-- No need for deleting any department