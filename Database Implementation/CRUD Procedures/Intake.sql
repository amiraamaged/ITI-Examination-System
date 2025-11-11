----- Intake Table (CRUD Procedures)
-- Add new Intake
CREATE PROCEDURE dbo.sp_Add_Intake
    @Intake_ID INT,
    @Intake_Name VARCHAR(60),
    @Start_Date DATE,
    @End_Date DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Validate required fields
    IF @Intake_ID IS NULL OR @Intake_Name IS NULL OR @Start_Date IS NULL OR @End_Date IS NULL
    BEGIN
        SELECT 'Error: All fields (Intake_ID, Intake_Name, Start_Date, End_Date) are required.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Check for duplicate Intake_ID
    IF EXISTS (SELECT 1 FROM dbo.Intake WHERE Intake_ID = @Intake_ID)
    BEGIN
        SELECT 'Error: Intake_ID already exists.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Check for duplicate Intake_Name
    IF EXISTS (SELECT 1 FROM dbo.Intake WHERE Intake_Name = @Intake_Name)
    BEGIN
        SELECT 'Error: Intake_Name already exists.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 4. Check name format "Round X - YYYY"
    IF @Intake_Name NOT LIKE 'Round [1-3] - [1-2][0-9][0-9][0-9]'
    BEGIN
        SELECT 'Error: Intake_Name must follow the format "Round X - YYYY" (e.g., Round 1 - 2024).' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 5. Validate date order
    IF @End_Date <= @Start_Date
    BEGIN
        SELECT 'Error: End_Date must be after Start_Date.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 6. Validate 4-month period
    IF DATEDIFF(MONTH, @Start_Date, @End_Date) <> 4
    BEGIN
        SELECT 'Error: Intake period must be exactly 4 months.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 7. Insert record
    INSERT INTO dbo.Intake (Intake_ID, Intake_Name, Start_Date, End_Date)
    VALUES (@Intake_ID, @Intake_Name, @Start_Date, @End_Date);

    COMMIT TRANSACTION;

    SELECT 'Intake added successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
--------------------------------------------------
-- Get Intake
CREATE PROCEDURE dbo.sp_Get_Intake
    @Intake_ID INT = NULL,
    @Intake_Name VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validation: ensure one search criteria is provided
    IF (@Intake_ID IS NULL OR @Intake_ID <= 0) AND (LTRIM(RTRIM(ISNULL(@Intake_Name, ''))) = '')
    BEGIN
        SELECT 'Error: You must provide either a valid Intake_ID or a non-empty Intake_Name.' AS Message;
        RETURN;
    END

    -- 2. Search by ID (if provided)
    IF @Intake_ID IS NOT NULL AND @Intake_ID > 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Intake WHERE Intake_ID = @Intake_ID)
        BEGIN
            SELECT 'Error: No intake found with this ID.' AS Message;
            RETURN;
        END

        SELECT 
            Intake_ID,
            Intake_Name,
            Start_Date,
            End_Date
        FROM dbo.Intake
        WHERE Intake_ID = @Intake_ID;

    END

    -- 3. Search by Name (if provided)
    IF LTRIM(RTRIM(@Intake_Name)) <> ''
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Intake WHERE Intake_Name = @Intake_Name)
        BEGIN
            SELECT 'Error: No intake found with this name.' AS Message;
            RETURN;
        END

        SELECT 
            Intake_ID,
            Intake_Name,
            Start_Date,
            End_Date
        FROM dbo.Intake
        WHERE Intake_Name = @Intake_Name;

    END
END;
--------------------------------------------------
-- Update Intake
CREATE PROCEDURE dbo.sp_Update_Intake
    @Intake_ID INT,
    @Intake_Name VARCHAR(60),
    @Start_Date DATE,
    @End_Date DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Check if Intake_ID exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Intake WHERE Intake_ID = @Intake_ID)
    BEGIN
        SELECT 'Error: No intake found with this ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Check if Intake_Name already exists for another record
    IF EXISTS (SELECT 1 FROM dbo.Intake WHERE Intake_Name = @Intake_Name AND Intake_ID <> @Intake_ID)
    BEGIN
        SELECT 'Error: Another intake already uses this name.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Check name format "Round X - YYYY"
    IF @Intake_Name NOT LIKE 'Round [1-3] - [1-2][0-9][0-9][0-9]'
    BEGIN
        SELECT 'Error: Intake_Name must follow the format "Round X - YYYY" (e.g., Round 1 - 2024).' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 4. Validate date order
    IF @End_Date <= @Start_Date
    BEGIN
        SELECT 'Error: End_Date must be after Start_Date.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 5. Validate 4-month period
    IF DATEDIFF(MONTH, @Start_Date, @End_Date) <> 4
    BEGIN
        SELECT 'Error: Intake period must be exactly 4 months.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 6. Perform the update
    UPDATE dbo.Intake
    SET 
        Intake_Name = @Intake_Name,
        Start_Date = @Start_Date,
        End_Date = @End_Date
    WHERE Intake_ID = @Intake_ID;

    COMMIT TRANSACTION;

    SELECT 'Intake updated successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
--------------------------------------------------------
-- Delete Intake
-- No need for deleting any Intake