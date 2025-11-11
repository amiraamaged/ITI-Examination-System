----- Question Table (CRUD Procedures)
-- Add Question 
CREATE PROCEDURE dbo.sp_Add_Question_With_Choices
    @Question_Type VARCHAR(10),
    @Question_Head VARCHAR(500),
    @Correct_Answer VARCHAR(200),
    @Course_ID INT,
    @Question_Mark INT,
    @Choices QuestionChoicesTableType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    DECLARE @New_Question_ID INT;
    DECLARE @New_Choice_ID INT;

    BEGIN TRY
        -- 1. Check if Course exists
        IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE Course_ID = @Course_ID)
        BEGIN
            RAISERROR('No course found with this Course_ID.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Validate Question_Type
        IF @Question_Type NOT IN ('MCQ', 'T/F')
        BEGIN
            RAISERROR('Question_Type must be either ''MCQ'' or ''T/F''.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 3. Validate Question_Mark
        IF @Question_Mark <> 2
        BEGIN
            RAISERROR('Question_Mark must be 2.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 4. Generate new Question_ID manually
        SELECT @New_Question_ID = ISNULL(MAX(Question_ID), 0) + 1 FROM dbo.Questions;

        -- 5. Insert the new question
        INSERT INTO dbo.Questions (Question_ID, Question_Type, Question_Head, Correct_Answer, Course_ID, Question_Mark)
        VALUES (@New_Question_ID, @Question_Type, @Question_Head, @Correct_Answer, @Course_ID, @Question_Mark);

        -- 6. Handle choices depending on question type
        IF @Question_Type = 'MCQ'
        BEGIN
            -- Validate 4 choices
            IF (SELECT COUNT(*) FROM @Choices) <> 4
            BEGIN
                RAISERROR('MCQ questions must have exactly 4 choices.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Validate only 1 correct answer
            IF (SELECT COUNT(*) FROM @Choices WHERE Is_Correct = 1) <> 1
            BEGIN
                RAISERROR('MCQ question must have exactly 1 correct choice.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Insert MCQ choices
            SELECT @New_Choice_ID = ISNULL(MAX(Choice_ID), 0) + 1 FROM dbo.Question_Choices;

            INSERT INTO dbo.Question_Choices (Choice_ID, Question_ID, Choice_Text, Is_Correct)
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @New_Choice_ID - 1,
                   @New_Question_ID,
                   Choice_Text,
                   Is_Correct
            FROM @Choices;
        END
        ELSE IF @Question_Type = 'T/F'
        BEGIN
            -- Insert True/False choices automatically
            SELECT @New_Choice_ID = ISNULL(MAX(Choice_ID), 0) + 1 FROM dbo.Question_Choices;

            INSERT INTO dbo.Question_Choices (Choice_ID, Question_ID, Choice_Text, Is_Correct)
            VALUES
            (@New_Choice_ID, @New_Question_ID, 'The sentence is True', CASE WHEN @Correct_Answer = 'True' THEN 1 ELSE 0 END),
            (@New_Choice_ID + 1, @New_Question_ID, 'The sentence is False', CASE WHEN @Correct_Answer = 'False' THEN 1 ELSE 0 END);
        END

        COMMIT TRANSACTION;
        SELECT 'Question added successfully. Question_ID = ' + CAST(@New_Question_ID AS VARCHAR(10)) AS Message;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------
-- Update Question
CREATE PROCEDURE dbo.sp_Update_Question
    @Question_ID INT,
    @Question_Type VARCHAR(50),
    @Question_Head VARCHAR(500),
    @Correct_Answer VARCHAR(200),
    @Course_ID INT,
    @Question_Mark INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check if Question exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Questions WHERE Question_ID = @Question_ID)
    BEGIN
        SELECT 'Error: No question found with this Question_ID.' AS Message;
        RETURN;
    END

    -- 2. Check if Course exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE Course_ID = @Course_ID)
    BEGIN
        SELECT 'Error: No course found with this Course_ID.' AS Message;
        RETURN;
    END

    -- 3. Validate Question_Type
    IF @Question_Type NOT IN ('MCQ', 'True/False')
    BEGIN
        SELECT 'Error: Question_Type must be either ''MCQ'' or ''True/False''.' AS Message;
        RETURN;
    END

    -- 4. Validate Question_Head and Correct_Answer
    IF @Question_Head IS NULL OR LTRIM(RTRIM(@Question_Head)) = ''
    BEGIN
        SELECT 'Error: Question_Head cannot be empty.' AS Message;
        RETURN;
    END

    IF @Correct_Answer IS NULL OR LTRIM(RTRIM(@Correct_Answer)) = ''
    BEGIN
        SELECT 'Error: Correct_Answer cannot be empty.' AS Message;
        RETURN;
    END

    -- 5. Validate Question_Mark
    IF @Question_Mark <> 0
    BEGIN
        SELECT 'Error: Question_Mark must be 2.' AS Message;
        RETURN;
    END

    -- 6. Update question
    UPDATE dbo.Questions
    SET Question_Type = @Question_Type,
        Question_Head = @Question_Head,
        Correct_Answer = @Correct_Answer,
        Course_ID = @Course_ID,
        Question_Mark = @Question_Mark
    WHERE Question_ID = @Question_ID;

    SELECT 'Question updated successfully.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
--------------------------------------------
-- Delete Question
CREATE PROCEDURE dbo.sp_Delete_Question
    @Question_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    -- 1. Check if the Question exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Questions WHERE Question_ID = @Question_ID)
    BEGIN
        SELECT 'Error: No question found with this Question_ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Delete related Student_Exam_Questions
    DELETE FROM dbo.Student_Exam_Questions
    WHERE Question_ID = @Question_ID

    -- 3. Delete related Exam_Questions
    DELETE FROM dbo.Exam_Questions
    WHERE Question_ID = @Question_ID;

    -- 4. Delete related Question_Choices
    DELETE FROM dbo.Question_Choices
    WHERE Question_ID = @Question_ID;

    -- 5. Finally, delete the Question itself
    DELETE FROM dbo.Questions
    WHERE Question_ID = @Question_ID;

    COMMIT TRANSACTION;
    SELECT 'Question and all related records deleted successfully.' AS Message;
END;

