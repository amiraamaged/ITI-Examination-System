-- Start Exam
CREATE PROCEDURE sp_Start_Exam
    @Exam_ID BIGINT,
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @Exam_Date DATE,
        @Start_Time TIME(7),
        @End_Time TIME(7);

    -- Check if exam exists
    IF NOT EXISTS (SELECT 1 FROM Exams WHERE Exam_ID = @Exam_ID)
    BEGIN
        RAISERROR('Exam not found. Please check the Exam ID.', 16, 1);
        RETURN;
    END

    -- Check if student already started or submitted the exam
    IF EXISTS (SELECT 1 FROM Student_Exam WHERE Exam_ID = @Exam_ID AND Student_ID = @Student_ID)
    BEGIN
        RAISERROR('You have already taken or started this exam.', 16, 1);
        RETURN;
    END

    -- Get exam date and time details
    SELECT 
        @Exam_Date = Exam_Date,
        @Start_Time = Start_Time,
        @End_Time = End_Time
    FROM Exams
    WHERE Exam_ID = @Exam_ID;

    -- Check if today is the exam date
    IF CAST(GETDATE() AS DATE) <> @Exam_Date
    BEGIN
        RAISERROR('Exam is not scheduled for today.', 16, 1);
        RETURN;
    END

    -- Check if exam has started
    IF CAST(GETDATE() AS TIME(7)) < @Start_Time
    BEGIN
        RAISERROR('Exam has not started yet.', 16, 1);
        RETURN;
    END

    -- Check if exam time is over
    IF CAST(GETDATE() AS TIME(7)) > @End_Time
    BEGIN
        RAISERROR('Exam time is over. You cannot start now.', 16, 1);
        RETURN;
    END

    -- If all checks passed, return questions and choices
    SELECT 
        q.Question_ID,
        q.Question_Type,
        q.Question_Head,
        qc.Choice_ID,
        qc.Choice_Text
    FROM Exam_Questions eq
    INNER JOIN Questions q ON eq.Question_ID = q.Question_ID
    INNER JOIN Question_Choices qc ON q.Question_ID = qc.Question_ID
    WHERE eq.Exam_ID = @Exam_ID
    ORDER BY q.Question_ID;

END;

-- EXEC sp_Start_Exam @Exam_ID = 825, @Student_ID = 13642482516707;