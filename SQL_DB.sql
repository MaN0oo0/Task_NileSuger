-- Create database
CREATE DATABASE CourseManagementSystem;
GO

USE CourseManagementSystem;
GO

-- Create Role table
CREATE TABLE Role (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Create User table 
CREATE TABLE [User] (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Bio NVARCHAR(MAX) NULL,
    Specialization NVARCHAR(100) NULL,
    ProfilePicture NVARCHAR(255) NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Create UserRole junction table
CREATE TABLE UserRole (
    UserRoleID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    RoleID INT NOT NULL,
    AssignedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES [User](UserID) ON DELETE CASCADE,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
    CONSTRAINT UQ_UserRole UNIQUE (UserID, RoleID)
);

-- Create Course table 
CREATE TABLE Course (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    InstructorUserRoleID INT NOT NULL, -- References UserRole, ensuring the user has Instructor role
    Category NVARCHAR(50),
    Price DECIMAL(10, 2),
    Duration INT, -- in hours
    Level NVARCHAR(20),
    ThumbnailURL NVARCHAR(255),
    IsPublished BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (InstructorUserRoleID) REFERENCES UserRole(UserRoleID)
);

-- Create Enrollment table 
CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentUserRoleID INT NOT NULL, -- References UserRole, ensuring the user has Student role
    CourseID INT NOT NULL,
    EnrollmentDate DATETIME DEFAULT GETDATE(),
    CompletionStatus NVARCHAR(20) DEFAULT 'Not Started',
    CompletionPercentage DECIMAL(5, 2) DEFAULT 0,
    LastAccessed DATETIME,
    FOREIGN KEY (StudentUserRoleID) REFERENCES UserRole(UserRoleID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE,
    CONSTRAINT UQ_Enrollment UNIQUE (StudentUserRoleID, CourseID)
);

-- Create Lesson table
CREATE TABLE Lesson (
    LessonID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Content NVARCHAR(MAX),
    VideoURL NVARCHAR(255),
    Duration INT, -- in minutes
    SequenceNumber INT NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE
);

-- Create Assignment table
CREATE TABLE Assignment (
    AssignmentID INT PRIMARY KEY IDENTITY(1,1),
    LessonID INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    DueDate DATETIME,
    MaxScore INT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (LessonID) REFERENCES Lesson(LessonID) ON DELETE CASCADE
);

-- Create Submission table (references User directly, not through role)
CREATE TABLE Submission (
    SubmissionID INT PRIMARY KEY IDENTITY(1,1),
    AssignmentID INT NOT NULL,
    UserID INT NOT NULL, -- References User directly for submissions
    SubmissionDate DATETIME DEFAULT GETDATE(),
    Content NVARCHAR(MAX),
    FilePath NVARCHAR(255),
    Score DECIMAL(5, 2),
    Feedback NVARCHAR(MAX),
    Status NVARCHAR(20) DEFAULT 'Submitted',
    FOREIGN KEY (AssignmentID) REFERENCES Assignment(AssignmentID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- Insert default roles
INSERT INTO Role (RoleName, Description) VALUES 
('Admin', 'System administrator with full access'),
('Instructor', 'Course instructor who can create and manage courses'),
('Student', 'Regular user who can enroll in courses');

-- Create indexes for performance
CREATE INDEX IX_User_Email ON [User](Email);
CREATE INDEX IX_UserRole_UserID ON UserRole(UserID);
CREATE INDEX IX_UserRole_RoleID ON UserRole(RoleID);
CREATE INDEX IX_Course_Instructor ON Course(InstructorUserRoleID);
CREATE INDEX IX_Enrollment_Student ON Enrollment(StudentUserRoleID);
CREATE INDEX IX_Enrollment_Course ON Enrollment(CourseID);
CREATE INDEX IX_Lesson_Course ON Lesson(CourseID);
CREATE INDEX IX_Assignment_Lesson ON Assignment(LessonID);
CREATE INDEX IX_Submission_Assignment ON Submission(AssignmentID);
CREATE INDEX IX_Submission_User ON Submission(UserID);
