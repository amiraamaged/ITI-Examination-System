--INDEXES

CREATE INDEX IX_Student_Email ON Student (Email);
CREATE INDEX IX_Student_Email ON Instructor (Email);

CREATE INDEX IX_Student_Intake_Track_Branch_ID ON Student (Intake_Track_Branch_ID);

CREATE INDEX IX_Certificates_Student_ID ON Certificates (Student_ID);
CREATE INDEX IX_Employment_Student_ID ON Employment (Student_ID);
CREATE INDEX IX_Freelancing_Jobs_Student_ID ON Freelancing_Jobs (Student_ID);

CREATE INDEX IX_Track_Dept_ID ON Track (Dept_ID);

CREATE INDEX IX_ITB_Intake_ID ON Intake_Track_Branch (Intake_ID);
CREATE INDEX IX_ITB_Track_ID ON Intake_Track_Branch (Track_ID);
CREATE INDEX IX_ITB_Branch_ID ON Intake_Track_Branch (Branch_ID);

CREATE INDEX IX_Instructors_Courses_Instructor_ID ON Instructors_Courses (Instructor_ID);
CREATE INDEX IX_Instructors_Courses_Course_ID ON Instructors_Courses (Course_ID);

CREATE INDEX IX_Instructor_Dept_ID ON Instructor (Dept_ID);

----------------------------------------------------------------
CREATE INDEX IX_Exams_Course_ID ON Exams (Course_ID);

CREATE INDEX IX_Questions_Course_ID ON Questions (Course_ID);
CREATE INDEX IX_Questions_Type ON Questions (Question_Type);

CREATE INDEX IX_Choices_Question_ID ON Question_Choices (Question_ID);

CREATE INDEX IX_Exam_Questions_Exam_ID ON Exam_Questions (Exam_ID);
CREATE INDEX IX_Exam_Questions_Question_ID ON Exam_Questions (Question_ID);

CREATE INDEX IX_Student_Exam_Student_ID ON Student_Exam (Student_ID);
CREATE INDEX IX_Student_Exam_Exam_ID ON Student_Exam (Exam_ID);

CREATE INDEX IX_Student_Exam_Questions_Student_ID ON Student_Exam_Questions (Student_ID);
CREATE INDEX IX_Student_Exam_Questions_Exam_ID ON Student_Exam_Questions (Exam_ID);
CREATE INDEX IX_Student_Exam_Questions_Question_ID ON Student_Exam_Questions (Question_ID);
CREATE INDEX IX_Student_Exam_Questions_Choice_ID ON Student_Exam_Questions (Selected_Choice_ID);


--EXEC sp_helpindex 'Student'