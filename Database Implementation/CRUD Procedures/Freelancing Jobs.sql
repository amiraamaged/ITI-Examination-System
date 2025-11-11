----- Freelancing_jobs Table (CRUD Procedures)
-- Add new Freelancing_job
CREATE PROCEDURE dbo.sp_Add_FreelancingJob
    @Platform VARCHAR(15),
    @Date DATE,
    @Income_USD DECIMAL(10,2),
    @Duration INT,
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    DECLARE @Freelancing_Job_ID INT;

    -- 1. Validate Student_ID
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'The provided Student_ID does not exist.' AS Message;
        RETURN;
    END

    -- 2. Auto-generate ID
    SELECT @Freelancing_Job_ID = ISNULL(MAX(Freelancing_Job_ID), 0) + 1
    FROM dbo.Freelancing_Jobs;

    -- 3. Insert new job record
    INSERT INTO dbo.Freelancing_Jobs (Freelancing_Job_ID, Platform, [Date], Income_USD, Duration, Student_ID)
    VALUES (@Freelancing_Job_ID, @Platform, @Date, @Income_USD, @Duration, @Student_ID);

    SELECT 'Freelancing job added successfully with ID ' + CAST(@Freelancing_Job_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------
-- Get Freelancing job 
CREATE PROCEDURE dbo.sp_Get_FreelancingJob
    @Freelancing_Job_ID INT = NULL,
    @Platform VARCHAR(15) = NULL,
    @Student_ID BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Check existence
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'Error: No Student found with this ID.' AS Message;
        RETURN;
    END

    -- 2. Return Freelancing_Jobs
    SELECT 
        f.*,
        s.Student_Name
    FROM dbo.Freelancing_Jobs AS f
    INNER JOIN dbo.Student AS s
        ON f.Student_ID = s.Student_ID
    WHERE
        (@Freelancing_Job_ID IS NULL OR f.Freelancing_Job_ID = @Freelancing_Job_ID)
        AND (@Platform IS NULL OR f.Platform LIKE '%' + @Platform + '%')
        AND (@Student_ID IS NULL OR f.Student_ID = @Student_ID)
    ORDER BY f.[Date] DESC;
END;
------------------------------------------------------------
-- Update Freelancing job
CREATE PROCEDURE dbo.sp_Update_FreelancingJob
    @Freelancing_Job_ID INT,
    @Platform VARCHAR(15),
    @Date DATE,
    @Income_USD DECIMAL(10,2),
    @Duration INT,
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Validate that the job exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Freelancing_Jobs WHERE Freelancing_Job_ID = @Freelancing_Job_ID)
    BEGIN
        SELECT 'No freelancing job found with the provided ID.' AS Message;
        RETURN;
    END

    -- 2. Validate that the student exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'The provided Student_ID does not exist.' AS Message;
        RETURN;
    END

    -- 3. Perform the update
    UPDATE dbo.Freelancing_Jobs
    SET
        Platform = @Platform,
        [Date] = @Date,
        Income_USD = @Income_USD,
        Duration = @Duration,
        Student_ID = @Student_ID
    WHERE Freelancing_Job_ID = @Freelancing_Job_ID;

    -- 4. Give feedback
    IF @@ROWCOUNT > 0
        SELECT 'Freelancing job updated successfully.' AS Message;
    ELSE
        SELECT 'No changes made (values might be identical).' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------
-- Delete Freelancing job
CREATE PROCEDURE dbo.sp_Delete_FreelancingJob
    @Freelancing_Job_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check if job exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Freelancing_Jobs WHERE Freelancing_Job_ID = @Freelancing_Job_ID)
    BEGIN
        SELECT 'No freelancing job found with the provided ID.' AS Message;
        RETURN;
    END

    -- 2. Perform deletion
    DELETE FROM dbo.Freelancing_Jobs
    WHERE Freelancing_Job_ID = @Freelancing_Job_ID;

    -- 3. Confirm deletion
    IF @@ROWCOUNT > 0
        SELECT 'Freelancing job deleted successfully.' AS Message;
    ELSE
        SELECT 'No job was deleted.' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;