-- Student Relations
-- Student with Faculty
ALTER TABLE [Student] DROP CONSTRAINT [Student_Faculty_FK];

ALTER TABLE [Student]
ADD CONSTRAINT [Student_Faculty_FK]
FOREIGN KEY ([Faculty_ID]) 
REFERENCES [Faculty]([Faculty_ID])
ON UPDATE CASCADE;

-- Student's Certificates
ALTER TABLE [Certificates] DROP CONSTRAINT [Certificates_Student_FK];

ALTER TABLE [Certificates]
ADD CONSTRAINT [Certificates_Student_FK]
FOREIGN KEY ([Student_ID])
REFERENCES [Student]([Student_ID])
ON DELETE CASCADE;

-- Student's Employment
ALTER TABLE [Employment] DROP CONSTRAINT [Employment_Student_FK];

ALTER TABLE [Employment]
ADD CONSTRAINT [Employment_Student_FK]
FOREIGN KEY ([Student_ID])
REFERENCES [Student]([Student_ID])
ON DELETE CASCADE;

-- Student's Freelancing jobs 
ALTER TABLE [Freelancing_Jobs] DROP CONSTRAINT [Freelancing_Student_FK];

ALTER TABLE [Freelancing_Jobs]
ADD CONSTRAINT [Freelancing_Student_FK]
FOREIGN KEY ([Student_ID])
REFERENCES [Student]([Student_ID])
ON DELETE CASCADE;

-- Student_Eaxm when Student is deleted
ALTER TABLE [Student_Exam] DROP CONSTRAINT [Student_Exam_Student_FK];

ALTER TABLE [Student_Exam]
ADD CONSTRAINT [Student_Exam_Student_FK]
FOREIGN KEY ([Student_ID])
REFERENCES [Student]([Student_ID])
ON DELETE CASCADE;

-- Student_Eaxm_Questions when Student is deleted
ALTER TABLE [Student_Exam_Questions] DROP CONSTRAINT [Student_Exam_Questions_St_FK];

ALTER TABLE [Student_Exam_Questions]
ADD CONSTRAINT [Student_Exam_Questions_St_FK]
FOREIGN KEY ([Student_ID])
REFERENCES [Student]([Student_ID])
ON DELETE CASCADE;
-------------------------------------------------------------------------------------------------
-- Course Relations
-- Exams when Course is deleted or updated
ALTER TABLE [Exams] DROP CONSTRAINT [Exams_Course_FK];

ALTER TABLE [Exams]
ADD CONSTRAINT [Exams_Course_FK]
FOREIGN KEY ([Course_ID])
REFERENCES [Course]([Course_ID])
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Track_Courses when Course is deleted or updated
ALTER TABLE [Track_Courses] DROP CONSTRAINT [Track_Courses_Course_FK];

ALTER TABLE [Track_Courses]
ADD CONSTRAINT [Track_Courses_Course_FK]
FOREIGN KEY ([Course_ID])
REFERENCES [Course]([Course_ID])
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Instrucotrs_Courses when Course is deleted or updated
ALTER TABLE [Instructors_Courses] DROP CONSTRAINT [Instructors_Courses_CS_FK];

ALTER TABLE [Instructors_Courses]
ADD CONSTRAINT [Instructors_Courses_CS_FK]
FOREIGN KEY ([Course_ID])
REFERENCES [Course]([Course_ID])
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Questions when Course is deleted or updated
ALTER TABLE [Questions] DROP CONSTRAINT [Questions_Course_FK];

ALTER TABLE [Questions]
ADD CONSTRAINT [Questions_Course_FK]
FOREIGN KEY ([Course_ID])
REFERENCES [Course]([Course_ID])
ON DELETE CASCADE
ON UPDATE CASCADE;
-------------------------------------------------------------------------------------------------
-- Question Relations
-- Question_Choices when Question is deleted or updated

ALTER TABLE [Question_Choices] DROP CONSTRAINT [Question_Choices_Q_FK];

ALTER TABLE [Question_Choices]
ADD CONSTRAINT [Question_Choices_Q_FK]
FOREIGN KEY ([Question_ID])
REFERENCES [Questions]([Question_ID])
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Exam_Questions when Question is deleted or updated
ALTER TABLE [Exam_Questions] DROP CONSTRAINT [Exam_Questions_Q_FK];

ALTER TABLE [Exam_Questions]
ADD CONSTRAINT [Exam_Questions_Q_FK]
FOREIGN KEY ([Question_ID])
REFERENCES [Questions]([Question_ID])
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Student_Exam_Questions when Question is deleted or updated
ALTER TABLE [Student_Exam_Questions] DROP CONSTRAINT [Student_Exam_Questions_Q_FK];

ALTER TABLE [Student_Exam_Questions]
ADD CONSTRAINT [Student_Exam_Questions_Q_FK]
FOREIGN KEY ([Question_ID])
REFERENCES [Questions]([Question_ID])
ON DELETE CASCADE
ON UPDATE CASCADE;
-------------------------------------------------------------------------------------------------
-- Instructor Relations
-- Instructor_Department when department is updated
ALTER TABLE [Instructor] DROP CONSTRAINT [Instructor_Department_FK];

ALTER TABLE [Instructor]
ADD CONSTRAINT [Instructor_Department_FK]
FOREIGN KEY ([Dept_ID])
REFERENCES [Department]([Dept_ID])
ON UPDATE CASCADE;

-- Instructors_Courses when instrucotr is deleted or updated
ALTER TABLE [Instructors_Courses] DROP CONSTRAINT [Instructors_Courses_Ins_FK];

ALTER TABLE [Instructors_Courses]
ADD CONSTRAINT [Instructors_Courses_Ins_FK]
FOREIGN KEY ([Instructor_ID])
REFERENCES [Instructor]([Instructor_ID])
ON DELETE CASCADE
ON UPDATE CASCADE;
-------------------------------------------------------------------------------------------------
-- Track Relations
-- Track when department is updated
ALTER TABLE [Track] DROP CONSTRAINT [Track_Department_FK];

ALTER TABLE [Track]
ADD CONSTRAINT [Track_Department_FK]
FOREIGN KEY ([Dept_ID])
REFERENCES [Department]([Dept_ID])
ON UPDATE CASCADE;

-- Track_Courses when track is updated
ALTER TABLE [Track_Courses] DROP CONSTRAINT [Track_Courses_Track_FK];

ALTER TABLE [Track_Courses]
ADD CONSTRAINT [Track_Courses_Track_FK]
FOREIGN KEY ([Track_ID])
REFERENCES [Track]([Track_ID])
ON UPDATE CASCADE;

-- Intake_Track_Branch when track is updated
ALTER TABLE [Intake_Track_Branch] DROP CONSTRAINT [ITB_Track_FK];

ALTER TABLE [Intake_Track_Branch]
ADD CONSTRAINT [ITB_Track_FK]
FOREIGN KEY ([Track_ID])
REFERENCES [Track]([Track_ID])
ON UPDATE CASCADE;
-------------------------------------------------------------------------------------------------
-- Branch Relations
-- Intake_Track_Branch when branch is updated
ALTER TABLE [Intake_Track_Branch] DROP CONSTRAINT [ITB_Branch_FK];

ALTER TABLE [Intake_Track_Branch]
ADD CONSTRAINT [ITB_Branch_FK]
FOREIGN KEY ([Branch_ID])
REFERENCES [Branch]([Branch_ID])
ON UPDATE CASCADE;
-------------------------------------------------------------------------------------------------
-- Intake Relations
-- Intake_Track_Branch when Intake is updated
ALTER TABLE [Intake_Track_Branch] DROP CONSTRAINT [ITB_Intake_FK];

ALTER TABLE [Intake_Track_Branch]
ADD CONSTRAINT [ITB_Intake_FK]
FOREIGN KEY ([Intake_ID])
REFERENCES [Intake]([Intake_ID])
ON UPDATE CASCADE;