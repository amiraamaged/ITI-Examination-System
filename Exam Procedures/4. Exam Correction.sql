-- Exam Correction
CREATE PROCEDURE sp_Correct_Exam
    @Exam_ID BIGINT,
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CorrectAnswers INT = 0;
    DECLARE @TotalScore INT = 0;

    -- 1. Check if exam exists
    IF NOT EXISTS (SELECT 1 FROM Exams WHERE Exam_ID = @Exam_ID)
    BEGIN
        RAISERROR('Exam not found.', 16, 1);
        RETURN;
    END

    -- 2. Check if student submitted the exam
    IF NOT EXISTS (
        SELECT 1 FROM Student_Exam 
        WHERE Exam_ID = @Exam_ID 
          AND Student_ID = @Student_ID 
          AND Exam_Status IN ('Submitted', 'Auto-Submitted')
    )
    BEGIN
        RAISERROR('Exam not submitted or not found for this student.', 16, 1);
        RETURN;
    END

    -- 3. Check if already graded
    IF EXISTS (
        SELECT 1 FROM Student_Exam 
        WHERE Exam_ID = @Exam_ID 
          AND Student_ID = @Student_ID 
          AND Exam_Status = 'Graded'
    )
    BEGIN
        RAISERROR('This exam has already been graded.', 16, 1);
        RETURN;
    END

    -- 4. Update each question's correctness and mark
    UPDATE seq
    SET 
        seq.Is_Correct = 
            CASE WHEN qc.Is_Correct = 1 THEN 1 ELSE 0 END,
        seq.Ques_Mark = 
            CASE WHEN qc.Is_Correct = 1 THEN 2 ELSE 0 END
    FROM Student_Exam_Questions seq
    INNER JOIN Question_Choices qc 
        ON seq.Selected_Choice_ID = qc.Choice_ID
    WHERE seq.Exam_ID = @Exam_ID
      AND seq.Student_ID = @Student_ID;

    -- 5. Count correct answers
    SELECT 
        @CorrectAnswers = COUNT(*)
    FROM Student_Exam_Questions
    WHERE Exam_ID = @Exam_ID
      AND Student_ID = @Student_ID
      AND Is_Correct = 1;

    -- 6. Calculate total score (2 marks per correct question)
    SET @TotalScore = @CorrectAnswers * 2;

    -- 7. Update Student_Exam table
    UPDATE Student_Exam
    SET 
        Student_Score = @TotalScore,
        Exam_Status = 'Graded'
    WHERE Exam_ID = @Exam_ID
      AND Student_ID = @Student_ID;

    -- 8. Return total score
    SELECT @TotalScore AS Final_Score;
END;

