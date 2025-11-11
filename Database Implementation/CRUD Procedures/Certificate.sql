----- Certificate Table (CRUD Procedures)
-- Add new Certificate
CREATE PROCEDURE dbo.sp_Add_Certificate
    @Certificate_Name VARCHAR(60),
    @Provider VARCHAR(20),
    @Date DATE,
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @New_ID INT;

    -- 1. Check if student exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'Error: No student found with this ID.' AS Message;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Generate new Certificate_ID manually
    SELECT @New_ID = ISNULL(MAX(Certificate_ID), 0) + 1
    FROM dbo.Certificates;

    -- 3. Insert the new certificate
    INSERT INTO dbo.Certificates (Certificate_ID, Certificate_Name, Provider, [Date], Student_ID)
    VALUES (@New_ID, @Certificate_Name, @Provider, @Date, @Student_ID);

    COMMIT TRANSACTION;

    SELECT 'Certificate added successfully. New Certificate_ID = ' + CAST(@New_ID AS VARCHAR(10)) AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------
-- Get Certificate
CREATE PROCEDURE dbo.sp_Get_Certificates
    @Certificate_Name VARCHAR(60) = NULL,
    @Student_ID BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check existence
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Student_ID = @Student_ID)
    BEGIN
        SELECT 'Error: No Student found with this ID.' AS Message;
        RETURN;
    END

    -- 2. Return Certificates
    SELECT 
        c.Certificate_ID,
        c.Certificate_Name,
        c.Provider,
        c.[Date],
        c.Student_ID,
        s.Student_Name   
    FROM dbo.Certificates AS c
    JOIN dbo.Student AS s 
      ON c.Student_ID = s.Student_ID  
    WHERE
        (@Certificate_Name IS NULL OR c.Certificate_Name LIKE '%' + @Certificate_Name + '%')
        AND (@Student_ID IS NULL OR c.Student_ID = @Student_ID)
    ORDER BY c.[Date] DESC;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
------------------------------------------------------------
-- Update Certificate
CREATE PROCEDURE dbo.sp_Update_Certificate
    @Certificate_ID INT,
    @Certificate_Name VARCHAR(60),
    @Provider VARCHAR(20),
    @Date DATE,
    @Student_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Check if the certificate exists first
    IF NOT EXISTS (SELECT 1 FROM dbo.Certificates WHERE Certificate_ID = @Certificate_ID)
    BEGIN
        SELECT 'No certificate found with the provided ID.' AS Message;
        RETURN;
    END

    -- 2. Perform the update safely
    UPDATE dbo.Certificates
    SET
        Certificate_Name = @Certificate_Name,
        Provider = @Provider,
        [Date] = @Date,
        Student_ID = @Student_ID
    WHERE Certificate_ID = @Certificate_ID;

    -- 3. Give feedback
    IF @@ROWCOUNT > 0
        SELECT 'Certificate updated successfully.' AS Message;
    ELSE
        SELECT 'No changes were made (values may be identical).' AS Message;
END;
------------------------------------------------------------
-- Delete Certificate
CREATE PROCEDURE dbo.sp_Delete_Certificate
    @Certificate_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    -- 1. Check if the certificate exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Certificates WHERE Certificate_ID = @Certificate_ID)
    BEGIN
        SELECT 'No certificate found with the provided ID.' AS Message;
        RETURN;
    END

    -- 2. Delete the certificate
    DELETE FROM dbo.Certificates 
    WHERE Certificate_ID = @Certificate_ID;

    -- 3. Feedback
    IF @@ROWCOUNT > 0
        SELECT 'Certificate deleted successfully.' AS Message;
    ELSE
        SELECT 'Deletion failed (unexpected issue).' AS Message;
    END TRY

    BEGIN CATCH
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS LineNumber;
    END CATCH
END;
