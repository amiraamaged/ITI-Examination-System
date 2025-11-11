----- Exam table CRUD Procedures
-- Update exam
CREATE PROCEDURE dbo.Update_Exam
    @Exam_ID INT,
    @Title VARCHAR(100),
    @Course_ID INT,
    @Total_Marks INT,
    @No_Questions INT,
    @Exam_Date DATE,
    @Start_Time TIME,
    @End_Time TIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    -- Validate: Exam must exist
    IF NOT EXISTS (SELECT 1 FROM dbo.Exams WHERE Exam_ID = @Exam_ID)
    BEGIN
        SELECT 'Error: Exam not found.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Validate: Course must exist
    IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE Course_ID = @Course_ID)
    BEGIN
        SELECT 'Error: Invalid Course_ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Validate: Exam date range (must be within ±1 year from today)
    IF @Exam_Date < GETDATE()
    BEGIN
        SELECT 'Error: Exam date cannot be in the past.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Validate: Start time must be before End time
    IF @Start_Time >= @End_Time
    BEGIN
        SELECT 'Error: Start_Time must be before End_Time.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Validate: Number of questions cannot exceed 25
    IF @No_Questions > 25 
    BEGIN
        SELECT 'Error: Total number of questions cannot exceed 25.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Update the exam details
    UPDATE dbo.Exams
    SET 
        Title = @Title,
        Course_ID = @Course_ID,
        Total_Marks = @Total_Marks,
        No_Questions = @No_Questions,
        Exam_Date = @Exam_Date,
        Start_Time = @Start_Time,
        End_Time = @End_Time
    WHERE Exam_ID = @Exam_ID;

    COMMIT TRANSACTION;
    SELECT 'Exam updated successfully.' AS Message;
END;
----------------
-- Get exam
CREATE PROCEDURE dbo.Get_Exam_By_ID
    @Exam_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate that exam exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Exams WHERE Exam_ID = @Exam_ID)
    BEGIN
        SELECT 'Error: Exam not found.' AS Message;
        RETURN;
    END;

    -- Retrieve exam details (formatted)
    SELECT 
        Exam_ID,
        Course_ID,
        Title,
        Total_Marks,
        No_Questions,
        CONVERT(VARCHAR(10), Exam_Date, 101) AS Exam_Date,
        LEFT(CONVERT(VARCHAR(8), Start_Time, 108), 5) AS Start_Time,
        LEFT(CONVERT(VARCHAR(8), End_Time, 108), 5) AS End_Time 
    FROM dbo.Exams
    WHERE Exam_ID = @Exam_ID;

    SELECT 'Exam data retrieved successfully.' AS Message;
END;
-------------------------------
-- Delete exam
CREATE PROCEDURE dbo.Delete_Exam
    @Exam_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Step 1: Validate exam existence
        IF NOT EXISTS (SELECT 1 FROM dbo.Exams WHERE Exam_ID = @Exam_ID)
        BEGIN
            SELECT 'Error: Exam not found.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Step 2: Delete from lowest-level related table (Student_Exam_Questions)
        DELETE FROM dbo.Student_Exam_Questions
        WHERE Exam_ID = @Exam_ID;

        SELECT 'Deleted all student answers related to this exam (Student_Exam_Questions).' AS Message;

        -- Step 3: Delete from Exam_Questions (questions linked to the exam)
        DELETE FROM dbo.Exam_Questions
        WHERE Exam_ID = @Exam_ID;

        SELECT 'Deleted all question links related to this exam (Exam_Questions).' AS Message;

        -- Step 4: Delete from Student_Exam (students’ exam records)
        DELETE FROM dbo.Student_Exam
        WHERE Exam_ID = @Exam_ID;

        SELECT 'Deleted all student exam records related to this exam (Student_Exam).' AS Message;

        -- Step 5: Finally delete the Exam itself
        DELETE FROM dbo.Exams
        WHERE Exam_ID = @Exam_ID;

        SELECT 'Exam and all related data deleted successfully.' AS Message;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'Error occurred while deleting exam data: ' + ERROR_MESSAGE() AS Message;
    END CATCH;
END;

