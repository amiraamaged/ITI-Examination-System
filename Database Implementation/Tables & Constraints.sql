CREATE DATABASE ITI_System

  CREATE TABLE [Student] (
	[Student_ID] BIGINT NOT NULL,
	[Student_Name] VARCHAR(60) NOT NULL,
	[Gender] VARCHAR(6) NOT NULL,
	[Phone_Number] VARCHAR(11) NOT NULL,
	[Birthdate] DATE NOT NULL,
	[Email] VARCHAR(100) UNIQUE NOT NULL,
	[Password] VARCHAR(255) NOT NULL,
	[Governorate] VARCHAR(15) NOT NULL,
	[Graduation_Year] INT NOT NULL,
	[GPA] decimal(3,2) NOT NULL,
	[Faculty_ID] INT NOT NULL,
	[Intake_Track_Branch_ID] INT NOT NULL,
	PRIMARY KEY ([Student_ID])
);

CREATE TABLE [Certificates] (
	[Certificate_ID] INT NOT NULL,
	[Certificate_Name] VARCHAR(60) NOT NULL,
	[Provider] VARCHAR(20) NOT NULL,
	[Date] DATE NOT NULL,
	[Student_ID] BIGINT NOT NULL,
	PRIMARY KEY ([Certificate_ID])
);

CREATE TABLE [Freelancing_Jobs] (
	[Freelancing_Job_ID] INT NOT NULL,
	[Platform] VARCHAR(15) NOT NULL,
	[Date] DATE NOT NULL,
	[Income_USD] DECIMAL(10,2) NOT NULL,
	[Duration] INT NOT NULL,
	[Student_ID] BIGINT NOT NULL,
	PRIMARY KEY ([Freelancing_Job_ID])
);

CREATE TABLE [Employment] (
	[Employment_ID] INT NOT NULL,
	[Type] VARCHAR(10) NOT NULL,
	[Company] VARCHAR(50),
	[Job_Title] VARCHAR(max),
	[Salary] INT NOT NULL,
	[Start_Date] DATE NOT NULL,
	[Student_ID] BIGINT NOT NULL UNIQUE,
	PRIMARY KEY ([Employment_ID])
);

CREATE TABLE [Faculty] (
	[Faculty_ID] INT NOT NULL,
	[Faculty_Name] VARCHAR(100) NOT NULL,
	[University] VARCHAR(50) NOT NULL,
	PRIMARY KEY ([Faculty_ID])
);

CREATE TABLE [Track] (
	[Track_ID] INT NOT NULL,
	[Track_Name] VARCHAR(60) NOT NULL,
	[Total_Hours] INT NOT NULL,
	[Dept_ID] INT NOT NULL,
	PRIMARY KEY ([Track_ID])
);

CREATE TABLE [Intake] (
	[Intake_ID] INT NOT NULL,
	[Intake_Name] VARCHAR(15) NOT NULL,
	[Start_Date] DATE NOT NULL,
	[End_Date] DATE NOT NULL,
	PRIMARY KEY ([Intake_ID])
);

CREATE TABLE [Branch] (
	[Branch_ID] INT NOT NULL,
	[Branch_Name] VARCHAR(20) NOT NULL,
	[Location] VARCHAR(25) NOT NULL,
	[Launching_Year] VARCHAR(4),
	PRIMARY KEY ([Branch_ID])
);

CREATE TABLE [Intake_Track_Branch] (
	[Intake_Track_Branch_ID] INT NOT NULL,
	[Intake_ID] INT NOT NULL,
	[Track_ID] INT NOT NULL,
	[Branch_ID] INT NOT NULL,
	PRIMARY KEY ([Intake_Track_Branch_ID])
);

CREATE TABLE [Instructor] (
	[Instructor_ID] BIGINT NOT NULL,
	[Instructor_Name] VARCHAR(60) NOT NULL,
	[Gender] VARCHAR(6) NOT NULL,
	[Salary] DECIMAL(10,2) NOT NULL,
	[Email] VARCHAR(100) UNIQUE NOT NULL,
	[Password] VARCHAR(255) NOT NULL,
	[Phone_Number] VARCHAR(11) NOT NULL,
	[Hire_Date] DATE NOT NULL,
	[Dept_ID] INT NOT NULL,
	PRIMARY KEY ([Instructor_ID])
);

CREATE TABLE [Department] (
	[Dept_ID] INT NOT NULL,
	[Dept_Name] VARCHAR(60) NOT NULL,
	PRIMARY KEY ([Dept_ID])
);

CREATE TABLE [Topic] (
	[Topic_ID] INT NOT NULL,
	[Topic_Name] VARCHAR(50) NOT NULL,
	PRIMARY KEY ([Topic_ID])
);

CREATE TABLE [Course] (
	[Course_ID] INT NOT NULL,
	[Course_Name] VARCHAR(100) NOT NULL,
	[Topic_ID] INT NOT NULL,
	PRIMARY KEY ([Course_ID])
);
CREATE TABLE [Track_Courses] (
	[Track_ID] INT NOT NULL,
	[Course_ID] INT NOT NULL,
	[Hours] INT NOT NULL,
	PRIMARY KEY ([Track_ID], [Course_ID])
);

CREATE TABLE [Instructors_Courses] (
	[Instructor_ID] BIGINT NOT NULL,
	[Course_ID] INT NOT NULL,
	PRIMARY KEY ([Instructor_ID], [Course_ID])
);
CREATE TABLE [Exams] (
	[Exam_ID] BIGINT NOT NULL,
	[Title] VARCHAR(max) NOT NULL,
	[Total_Marks] INT NOT NULL,
	[Exam_Date] DATE NOT NULL,
	[No_Questions] INT NOT NULL,
	[Start_Time] TIME(7) NOT NULL,
	[End_Time] TIME(7) NOT NULL,
	[Course_ID] INT NOT NULL,
	PRIMARY KEY ([Exam_ID])
);

CREATE TABLE [Questions] (
	[Question_ID] INT NOT NULL,
	[Question_Type] VARCHAR(3) NOT NULL,
	[Question_Head] VARCHAR(max) NOT NULL,
	[Correct_Answer] VARCHAR(max) NOT NULL,
	[Course_ID] INT NOT NULL,
	[Question_Mark] INT NOT NULL,
	PRIMARY KEY ([Question_ID])
);

CREATE TABLE [Question_Choices] (
	[Choice_ID] INT NOT NULL,
	[Question_ID] INT NOT NULL,
	[Choice_Text] NVARCHAR(max) NOT NULL,
	[Is_Correct] BIT NOT NULL,
	PRIMARY KEY ([Choice_ID])
);

CREATE TABLE [Exam_Questions] (
	[Exam_ID] BIGINT NOT NULL,
	[Question_ID] INT NOT NULL,
	PRIMARY KEY ([Exam_ID], [Question_ID])
);

CREATE TABLE [Student_Exam] (
	[Student_ID] BIGINT NOT NULL,
	[Exam_ID] BIGINT NOT NULL,
	[Student_Score] INT NOT NULL,
	[Submission_Time] TIME(7) NOT NULL,
	[Exam_Status] VARCHAR(15) NOT NULL,
	PRIMARY KEY ([Student_ID], [Exam_ID])
);

CREATE TABLE [Student_Exam_Questions] (
	[Student_ID] BIGINT NOT NULL,
	[Exam_ID] BIGINT NOT NULL,
	[Question_ID] INT NOT NULL,
	[Selected_Choice_ID] INT NOT NULL,
	[Ques_Mark] INT NOT NULL,
	[Is_Correct] BIT NOT NULL,
	PRIMARY KEY ([Student_ID], [Exam_ID], [Question_ID])
);


ALTER TABLE [Student] ADD CONSTRAINT [Student_Faculty_FK] FOREIGN KEY ([Faculty_ID]) REFERENCES [Faculty]([Faculty_ID]);
ALTER TABLE [Student] ADD CONSTRAINT [Student_ITB_FK] FOREIGN KEY ([Intake_Track_Branch_ID]) REFERENCES [Intake_Track_Branch]([Intake_Track_Branch_ID]);

ALTER TABLE [Employment] ADD CONSTRAINT [Employment_Student_FK] FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]);
ALTER TABLE [Freelancing_Jobs] ADD CONSTRAINT [Freelancing_Student_FK] FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]);
ALTER TABLE [Certificates] ADD CONSTRAINT [Certificates_Student_FK] FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]);

ALTER TABLE [Intake_Track_Branch] ADD CONSTRAINT [ITB_Intake_FK] FOREIGN KEY ([Intake_ID]) REFERENCES [Intake]([Intake_ID]);
ALTER TABLE [Intake_Track_Branch] ADD CONSTRAINT [ITB_Track_FK] FOREIGN KEY ([Track_ID]) REFERENCES [Track]([Track_ID]);
ALTER TABLE [Intake_Track_Branch] ADD CONSTRAINT [ITB_Branch_FK] FOREIGN KEY ([Branch_ID]) REFERENCES [Branch]([Branch_ID]);

ALTER TABLE [Track] ADD CONSTRAINT [Track_Department_FK] FOREIGN KEY ([Dept_ID]) REFERENCES [Department]([Dept_ID]);

ALTER TABLE [Course] ADD CONSTRAINT [Course_Topic_FK] FOREIGN KEY ([Topic_ID]) REFERENCES [Topic]([Topic_ID]);

ALTER TABLE [Track_Courses] ADD CONSTRAINT [Track_Courses_Track_FK] FOREIGN KEY ([Track_ID]) REFERENCES [Track]([Track_ID]);
ALTER TABLE [Track_Courses] ADD CONSTRAINT [Track_Courses_Course_FK] FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]);

ALTER TABLE [Instructor] ADD CONSTRAINT [Instructor_Department_FK] FOREIGN KEY ([Dept_ID]) REFERENCES [Department]([Dept_ID]);

ALTER TABLE [Instructors_Courses] ADD CONSTRAINT [Instructors_Courses_Ins_FK] FOREIGN KEY ([Instructor_ID]) REFERENCES [Instructor]([Instructor_ID]);
ALTER TABLE [Instructors_Courses] ADD CONSTRAINT [Instructors_Courses_CS_FK] FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]);

ALTER TABLE [Exams] ADD CONSTRAINT [Exams_Course_FK] FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]);

ALTER TABLE [Questions] ADD CONSTRAINT [Questions_Course_FK] FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]);

ALTER TABLE [Question_Choices] ADD CONSTRAINT [Question_Choices_Q_FK] FOREIGN KEY ([Question_ID]) REFERENCES [Questions]([Question_ID]);

ALTER TABLE [Exam_Questions] ADD CONSTRAINT [Exam_Questions_Exam_FK] FOREIGN KEY ([Exam_ID]) REFERENCES [Exams]([Exam_ID]);
ALTER TABLE [Exam_Questions] ADD CONSTRAINT [Exam_Questions_Q_FK] FOREIGN KEY ([Question_ID]) REFERENCES [Questions]([Question_ID]);

ALTER TABLE [Student_Exam] ADD CONSTRAINT [Student_Exam_Student_FK] FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]);
ALTER TABLE [Student_Exam] ADD CONSTRAINT [Student_Exam_Exam_FK] FOREIGN KEY ([Exam_ID]) REFERENCES [Exams]([Exam_ID]);

ALTER TABLE [Student_Exam_Questions] ADD CONSTRAINT [Student_Exam_Questions_St_FK] FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]);
ALTER TABLE [Student_Exam_Questions] ADD CONSTRAINT [Student_Exam_Questions_Exam_FK] FOREIGN KEY ([Exam_ID]) REFERENCES [Exams]([Exam_ID]);
ALTER TABLE [Student_Exam_Questions] ADD CONSTRAINT [Student_Exam_Questions_Q_FK] FOREIGN KEY ([Question_ID]) REFERENCES [Questions]([Question_ID]);
ALTER TABLE [Student_Exam_Questions] ADD CONSTRAINT [Student_Exam_Questions_Choice_FK] FOREIGN KEY ([Selected_Choice_ID]) REFERENCES [Question_Choices]([Choice_ID]);


ALTER TABLE [Student_Exam] ADD CONSTRAINT [Exam_Status_Check] CHECK (Exam_Status IN ('Not Started', 'In Progress', 'Submitted', 'Graded'))
ALTER TABLE [Employment] ADD CONSTRAINT [Employment_Type_Check] CHECK (Type IN ('Internship', 'Part-time', 'Full-time', 'Freelancer'))
ALTER TABLE [Questions] ADD CONSTRAINT [Question_Type_Check] CHECK (Question_Type IN ('T/F', 'MCQ'))


ALTER TABLE [Student_Exam] ADD CONSTRAINT [Default_Exam_Status] DEFAULT 'Not Started' FOR [Exam_Status];
ALTER TABLE [Student_Exam_Questions]ADD CONSTRAINT [Default_Is_Correct] DEFAULT 0 FOR [Is_Correct];