-- Submit Exam (Exam Answers)
CREATE PROCEDURE sp_Submit_Exam
    @Exam_ID BIGINT,
    @Student_ID BIGINT,
    @Answers StudentAnswersTableType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Check if student already submitted
    IF EXISTS (SELECT 1 FROM Student_Exam WHERE Exam_ID = @Exam_ID AND Student_ID = @Student_ID)
    BEGIN
        RAISERROR('You have already submitted this exam.', 16, 1);
        RETURN;
    END

    -- 2. Insert new record into Student_Exam
    INSERT INTO Student_Exam (Exam_ID, Student_ID, Student_Score, Submission_Time, Exam_Status)
    VALUES (@Exam_ID, @Student_ID, 0, CAST(GETDATE() AS TIME(7)), 'Submitted');

    -- 3. Insert student answers into Student_Exam_Questions
    INSERT INTO Student_Exam_Questions (Student_ID, Exam_ID, Question_ID, Selected_Choice_ID, Ques_Mark)
    SELECT 
        @Student_ID,
        @Exam_ID,
        Question_ID,
        Selected_Choice_ID,
        0
    FROM @Answers;

    SELECT 'Exam Submitted Successfully'

END;
