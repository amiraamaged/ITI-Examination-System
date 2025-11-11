----- Course Table (CRUD Procedures)
-- Add Course 
CREATE PROCEDURE dbo.sp_Add_Course
    @Course_Name VARCHAR(100),
    @Topic_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    DECLARE @New_ID INT;

    -- 1. Check if the Topic exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Topic WHERE Topic_ID = @Topic_ID)
    BEGIN
        SELECT 'Error: No Topic found with this ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

     -- 2. Check for duplicates
        IF EXISTS (SELECT 1 FROM dbo.Course WHERE Course_Name = @Course_Name AND Topic_ID = @Topic_ID)
        BEGIN
            RAISERROR('Error: Course already exists under this topic.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

    -- 3. Generate new Course_ID manually
    SELECT @New_ID = ISNULL(MAX(Course_ID), 0) + 1
    FROM dbo.Course;

    -- 4. Insert the new course
    INSERT INTO dbo.Course (Course_ID, Course_Name, Topic_ID)
    VALUES (@New_ID, @Course_Name, @Topic_ID);

    COMMIT TRANSACTION;

    SELECT 'Course added successfully. New Course_ID = ' + CAST(@New_ID AS VARCHAR(10)) AS Message;
END;
--------------
-- Get Course 
CREATE PROCEDURE dbo.sp_Get_Course
    @Course_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. If no Course_ID provided, return all courses
    IF @Course_ID IS NULL
    BEGIN
        SELECT 
            c.Course_ID, 
            c.Course_Name, 
            c.Topic_ID, 
            t.Topic_Name
        FROM dbo.Course c
        LEFT JOIN dbo.Topic t ON c.Topic_ID = t.Topic_ID
        ORDER BY c.Course_ID;

        RETURN;
    END;

    -- 2. If specific Course_ID provided, check existence
    IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE Course_ID = @Course_ID)
    BEGIN
        SELECT 'Error: No course found with this Course_ID.' AS Message;
        RETURN;
    END;

    -- 3. Return single course info
    SELECT 
        c.Course_ID, 
        c.Course_Name, 
        c.Topic_ID, 
        t.Topic_Name
    FROM dbo.Course c
    LEFT JOIN dbo.Topic t ON c.Topic_ID = t.Topic_ID
    WHERE c.Course_ID = @Course_ID;
END;
-------------------
-- Update Course 
CREATE PROCEDURE dbo.sp_Update_Course
    @Course_ID INT,
    @Course_Name VARCHAR(100),
    @Topic_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    -- 1. Check if Course exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE Course_ID = @Course_ID)
    BEGIN
        SELECT 'Error: No course found with this ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Check if Topic exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Topic WHERE Topic_ID = @Topic_ID)
    BEGIN
        SELECT 'Error: No topic found with this ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Check for duplicate Course Name under same Topic
        IF EXISTS (SELECT 1 FROM dbo.Course 
                   WHERE Course_Name = @Course_Name 
                   AND Topic_ID = @Topic_ID 
                   AND Course_ID <> @Course_ID)
        BEGIN
            RAISERROR('Error: A course with this name already exists under this topic.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

    -- 4. Update the course
    UPDATE dbo.Course
    SET Course_Name = @Course_Name,
        Topic_ID = @Topic_ID
    WHERE Course_ID = @Course_ID;

    COMMIT TRANSACTION;

    SELECT 'Course updated successfully.' AS Message;
END;
-----------------------------
-- Delete Course 
CREATE PROCEDURE dbo.sp_Delete_Course
    @Course_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;
    -- 1. Check if Course exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE Course_ID = @Course_ID)
    BEGIN
        SELECT 'Error: No course found with this ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Delete the course
    DELETE FROM dbo.Course
    WHERE Course_ID = @Course_ID;

    COMMIT TRANSACTION;

    SELECT 'Course deleted successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
