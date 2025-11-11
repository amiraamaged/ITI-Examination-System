----- Topic Table (CRUD Procedures)
-- Add new Topic
CREATE PROCEDURE dbo.sp_Add_Topic
    @Topic_ID INT,
    @Topic_Name VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check that the name is not empty
    IF (LTRIM(RTRIM(@Topic_Name)) = '')
    BEGIN
        SELECT 'Error: Topic name cannot be empty.' AS Message;
        RETURN;
    END;

    -- 2. Check that the name is not duplicated
    IF EXISTS (SELECT 1 FROM dbo.Topic WHERE Topic_Name = @Topic_Name)
    BEGIN
        SELECT 'Error: Topic name already exists.' AS Message;
        RETURN;
    END;

    -- 3. Verify that the ID has not been used before.
    IF EXISTS (SELECT 1 FROM dbo.Topic WHERE Topic_ID = @Topic_ID)
    BEGIN
        SELECT 'Error: Topic_ID already exists.' AS Message;
        RETURN;
    END;

    -- 4. Enter new topic
    INSERT INTO dbo.Topic (Topic_ID, Topic_Name)
    VALUES (@Topic_ID, @Topic_Name);


    SELECT 'Topic added successfully. ID = ' + CAST(@Topic_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
---------------------------------------------------
-- Get Topic
CREATE PROCEDURE dbo.sp_Get_Topic
    @Topic_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Require Topic_ID
    IF @Topic_ID IS NULL
    BEGIN
        SELECT 'Error: Topic_ID must be provided.' AS Message;
        RETURN;
    END

    -- 2. Check existence
    IF NOT EXISTS (SELECT 1 FROM dbo.Topic WHERE Topic_ID = @Topic_ID)
    BEGIN
        SELECT 'Error: No Topic found with this ID.' AS Message;
        RETURN;
    END

    -- 3. Return topic
    SELECT Topic_ID, Topic_Name
    FROM dbo.Topic
    WHERE Topic_ID = @Topic_ID;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
--------------------------------------------------
-- Update Topic 
CREATE PROCEDURE dbo.sp_Update_Topic
    @Topic_ID INT,
    @New_Topic_Name VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;
    -- 1. Check the Topic is exist
    IF NOT EXISTS (SELECT 1 FROM dbo.Topic WHERE Topic_ID = @Topic_ID)
    BEGIN
        SELECT 'Error: Topic not found.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- 2. Check Topic name is not empty
    IF @New_Topic_Name IS NULL OR LTRIM(RTRIM(@New_Topic_Name)) = ''
    BEGIN
        SELECT 'Error: Topic name cannot be NULL or empty.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- 3. Check Topic name is not duplicated
    IF EXISTS (SELECT 1 FROM dbo.Topic WHERE Topic_Name = @New_Topic_Name AND Topic_ID <> @Topic_ID)
    BEGIN
        SELECT 'Error: Topic name already exists.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- 4. Update the Topic
    UPDATE dbo.Topic
    SET Topic_Name = @New_Topic_Name
    WHERE Topic_ID = @Topic_ID;
    
    -- 5. Check the Update is done or not
    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 'Warning: No rows were updated. The data may already be identical.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    COMMIT TRANSACTION;

    SELECT 'Topic updated successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH

END;
----------------------------------------
-- Delete Topic 
-- No need for deleting any Topic