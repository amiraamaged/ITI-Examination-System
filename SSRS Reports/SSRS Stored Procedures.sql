--------------------------------------------------------------------------------------------------
-- 1) Stored Procedure returns the students information according to Department No parameter --
--------------------------------------------------------------------------------------------------
CREATE PROCEDURE Get_Students_By_Department
    @Dept_ID INT
AS
BEGIN
    SELECT 
        s.Student_ID,
        s.Student_Name,
        s.Gender,
        s.Phone_Number,
        s.Birthdate,
        s.Email,
        s.Governorate,
        s.Graduation_Year,
        s.GPA,
        d.Dept_Name AS [Department Name],
        t.Track_Name,
        i.Intake_Name,
        b.Branch_Name
    FROM Student s
    INNER JOIN Intake_Track_Branch itb 
        ON s.Intake_Track_Branch_ID = itb.Intake_Track_Branch_ID
    INNER JOIN Track t 
        ON itb.Track_ID = t.Track_ID
    INNER JOIN Intake i
        ON itb.Intake_ID = i.Intake_ID
    INNER JOIN Branch b
        ON itb.Branch_ID = b.Branch_ID
    INNER JOIN Department d 
        ON t.Dept_ID = d.Dept_ID
    WHERE d.Dept_ID = @Dept_ID;
END;
GO

-- EXEC Get_Students_By_Department @Dept_ID = 4000;

--------------------------------------------------------------------------------------------------
-- 2) Stored Procedure takes the student ID and returns the grades of the student in all courses. % --
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetStudentGrades
    @StudentID BIGINT
AS
BEGIN
    SELECT 
        s.Student_ID,
        s.Student_Name,
        c.Course_Name,
        e.Title AS Exam_Title,
        e.Total_Marks,
        se.Student_Score,
        CAST((SUM(CAST(se.Student_Score AS DECIMAL(5,2))) OVER (PARTITION BY c.Course_Name)
             / SUM(e.Total_Marks) OVER (PARTITION BY c.Course_Name) * 100) AS DECIMAL(5,2)) AS Total_Percentage_Per_Course,
        se.Exam_Status
    FROM Student AS s
    INNER JOIN Student_Exam AS se
        ON s.Student_ID = se.Student_ID
    INNER JOIN Exams AS e
        ON se.Exam_ID = e.Exam_ID
    INNER JOIN Course AS c
        ON e.Course_ID = c.Course_ID
    WHERE s.Student_ID = @StudentID;
END;

-- EXEC GetStudentGrades @StudentID = 13642482516707;

--------------------------------------------------------------------------------------------------
-- 3) Stored Procedure takes the instructor ID and returns the name of the courses that he teaches and the number of students per course. --
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetInstructorCoursesWithStudentCount
    @InstructorID BIGINT
AS
BEGIN
    SELECT 
        i.Instructor_ID,
        i.Instructor_Name,
        c.Course_Name,
        COUNT(DISTINCT s.Student_ID) AS Number_of_Students
    FROM Instructor AS i
    INNER JOIN Instructors_Courses AS ic
        ON i.Instructor_ID = ic.Instructor_ID
    INNER JOIN Course AS c
        ON ic.Course_ID = c.Course_ID
    INNER JOIN Department AS d
        ON i.Dept_ID = d.Dept_ID
    INNER JOIN Track AS t
        ON t.Dept_ID = d.Dept_ID
    INNER JOIN Intake_Track_Branch AS itb
        ON itb.Track_ID = t.Track_ID
    INNER JOIN Student AS s
        ON s.Intake_Track_Branch_ID = itb.Intake_Track_Branch_ID
    WHERE i.Instructor_ID = @InstructorID
    GROUP BY i.Instructor_ID, i.Instructor_Name, c.Course_Name;
END;

-- EXEC GetInstructorCoursesWithStudentCount @InstructorID = 2735;

--------------------------------------------------------------------------------------------------
-- 4) Stored Proceedure takes course ID and returns its topics  
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetTopicCourses
    @TopicID INT
AS
BEGIN
    SELECT 
        T.Topic_ID,
        T.Topic_Name,
        C.Course_Name
    FROM 
        Topic T
        INNER JOIN Course C
            ON T.Topic_ID = C.Topic_ID
    WHERE 
        T.Topic_ID = @TopicID;
END;

-- EXEC GetTopicCourses @TopicID = 1500;

--------------------------------------------------------------------------------------------------
-- 5) Stored Procedure that takes exam number and returns the Questions in it and choices 
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE GetExamQuestionsAndChoices
    @ExamID BIGINT
AS
BEGIN
    SELECT 
        E.Exam_ID,
        Q.Question_ID,
        Q.Question_Type,
        Q.Question_Head,
        Q.Question_Mark,
        QC.Choice_Text,
        QC.Is_Correct
    FROM Exams E
    INNER JOIN Exam_Questions EQ 
        ON E.Exam_ID = EQ.Exam_ID
    INNER JOIN Questions Q 
        ON EQ.Question_ID = Q.Question_ID
    LEFT JOIN Question_Choices QC 
        ON Q.Question_ID = QC.Question_ID
    WHERE E.Exam_ID = @ExamID
    ORDER BY Q.Question_ID, QC.Choice_ID;
END;

-- EXEC GetExamQuestionsAndChoices @ExamID = 1;

--------------------------------------------------------------------------------------------------
-- 6) Stored Procedure takes exam number and the student ID then returns the Questions in this exam with the student answers. 
--------------------------------------------------------------------------------------------------

CREATE PROCEDURE Get_Exam_Questions_With_Student_Answers
    @Exam_ID BIGINT,
    @Student_ID BIGINT
AS
BEGIN
    SELECT 
        s.Student_Name,
        e.Title AS Exam_Title,
        q.Question_Head,
        q.Correct_Answer,
        qc.Choice_Text AS Student_Choice,
        seq.Ques_Mark,
        seq.Is_Correct
    FROM Student_Exam_Questions AS seq
    JOIN Questions AS q
        ON seq.Question_ID = q.Question_ID
    JOIN Question_Choices AS qc
        ON seq.Selected_Choice_ID = qc.Choice_ID
    JOIN Student AS s
        ON seq.Student_ID = s.Student_ID
    JOIN Exams AS e
        ON seq.Exam_ID = e.Exam_ID
    WHERE seq.Exam_ID = @Exam_ID
      AND seq.Student_ID = @Student_ID;
END;

-- EXEC Get_Exam_Questions_With_Student_Answers @Exam_ID = 823, @Student_ID = 13642482519366;