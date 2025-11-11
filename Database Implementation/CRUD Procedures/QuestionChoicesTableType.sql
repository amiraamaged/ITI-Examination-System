-- Table-Valued Parameter for Question Choices
CREATE TYPE QuestionChoicesTableType AS TABLE
(
    Choice_Text VARCHAR(200) NOT NULL,
    Is_Correct BIT NOT NULL
);
