-- Exam Generation
CREATE PROCEDURE sp_Generate_Exam
    @Course_Name VARCHAR(100),
    @Exam_Date DATE,
    @Start_Time TIME(7),
    @End_Time TIME(7),
    @No_TF INT,
    @No_MCQ INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @Course_ID INT,
        @Exam_ID BIGINT,
        @Exam_Title VARCHAR(150),
        @Total_Marks INT,
        @No_Questions INT,
        @Now DATETIME = GETDATE();

    -- 1. Validate Course Name
    SELECT @Course_ID = Course_ID 
    FROM Course 
    WHERE Course_Name = @Course_Name;

    IF @Course_ID IS NULL
    BEGIN
        RAISERROR('Course name is invalid or does not exist.', 16, 1);
        RETURN;
    END

    -- 2. Validate Exam Date (cannot be in the past)
    IF @Exam_Date < CAST(@Now AS DATE)
    BEGIN
        RAISERROR('Exam date cannot be in the past.', 16, 1);
        RETURN;
    END

    -- 3. Validate Exam Time (if same day, start time must be after current time)
    IF @Exam_Date = CAST(@Now AS DATE) AND @Start_Time < CAST(@Now AS TIME)
    BEGIN
        RAISERROR('Exam start time cannot be in the past.', 16, 1);
        RETURN;
    END

    -- 4. Validate Exam Duration (cannot exceed 2 hours)
    IF DATEDIFF(MINUTE, @Start_Time, @End_Time) > 120
    BEGIN
        RAISERROR('Exam duration cannot exceed 2 hours.', 16, 1);
        RETURN;
    END

    -- 5. Validate Questions Count (max 25)
    SET @No_Questions = @No_TF + @No_MCQ;
    IF @No_Questions > 25
    BEGIN
        RAISERROR('Total number of questions cannot exceed 25.', 16, 1);
        RETURN;
    END

    -- 6. Generate new Exam_ID
    SELECT @Exam_ID = ISNULL(MAX(Exam_ID), 0) + 1 FROM Exams;

    -- 7. Build Exam Title
    SET @Exam_Title = @Course_Name + ' Exam';

    -- 8. Total Marks = number of questions (assume each 1 mark)
    SET @Total_Marks = @No_Questions * 2;

    -- 9. Insert Exam
    INSERT INTO Exams (Exam_ID, Title, Total_Marks, Exam_Date, No_Questions, Start_Time, End_Time, Course_ID)
    VALUES (@Exam_ID, @Exam_Title, @Total_Marks, @Exam_Date, @No_Questions, @Start_Time, @End_Time, @Course_ID);

    -- 10. Insert random True/False questions
    INSERT INTO Exam_Questions (Exam_ID, Question_ID)
    SELECT TOP (@No_TF) @Exam_ID, Question_ID
    FROM Questions
    WHERE Course_ID = @Course_ID AND Question_Type = 'T/F'
    ORDER BY NEWID();

    -- 11. Insert random MCQ questions
    INSERT INTO Exam_Questions (Exam_ID, Question_ID)
    SELECT TOP (@No_MCQ) @Exam_ID, Question_ID
    FROM Questions
    WHERE Course_ID = @Course_ID AND Question_Type = 'MCQ'
    ORDER BY NEWID();

    -- 12. Return summary
    SELECT 
        @Exam_ID AS Exam_ID,
        @Exam_Title AS Exam_Title,
        @Course_Name AS Course_Name,
        @No_TF AS No_TF_Questions,
        @No_MCQ AS No_MCQ_Questions,
        @No_Questions AS Total_Questions,
        @Exam_Date AS Exam_Date,
        @Start_Time AS Start_Time,
        @End_Time AS End_Time;
END;

-- EXEC sp_Generate_Exam @Course_Name = 'Introduction to Programming using C', @Exam_Date = '2025-11-02', 
--                       @Start_Time = '16:54:00', @End_Time = '18:00:00', @No_TF = 2, @No_MCQ = 3;