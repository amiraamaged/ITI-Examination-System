-- Prevent deletion
-- Tracks
CREATE TRIGGER Prevent_Delete_From_Track
ON [Track]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting Tracks is not allowed', 16, 1);
    ROLLBACK TRANSACTION;
END;
---------------------------------------------------------------
-- Branches
CREATE TRIGGER Prevent_Delete_From_Branch
ON [Branch]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting Branches is not allowed', 16, 1);
    ROLLBACK TRANSACTION;
END;
---------------------------------------------------------------
-- Intakes
CREATE TRIGGER Prevent_Delete_From_Intake
ON [Intake]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting Intakes is not allowed', 16, 1);
    ROLLBACK TRANSACTION;
END;
---------------------------------------------------------------
-- Departments
CREATE TRIGGER Prevent_Delete_From_Department
ON [Department]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting Departments is not allowed', 16, 1);
    ROLLBACK TRANSACTION;
END;
---------------------------------------------------------------
-- Topics
CREATE TRIGGER Prevent_Delete_From_Topic
ON [Topic]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting Topics is not allowed', 16, 1);
    ROLLBACK TRANSACTION;
END;
---------------------------------------------------------------
-- Faculties
CREATE TRIGGER Prevent_Delete_From_Faculty
ON [Faculty]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting Facluties is not allowed', 16, 1);
    ROLLBACK TRANSACTION;
END;
---------------------------------------------------------------