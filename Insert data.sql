-- Inserting into Department
INSERT INTO Department (Department_Name) 
VALUES ('Computer Science'), ('Mathematics'), ('Physics');

-- Inserting into Faculty
INSERT INTO Faculty (First_Name, Last_Name, Department_ID) 
VALUES ('Jane', 'Smith', 1), ('Alice', 'Johnson', 2), ('Bob', 'Williams', 3);

-- Inserting into Course
INSERT INTO Course (Course_Name, Credits, Faculty_ID) 
VALUES ('Database Systems', 4, 1), ('Calculus', 4, 2), ('Quantum Mechanics', 3, 3);

-- Inserting into Student
INSERT INTO Student (First_Name, Last_Name, Major, Enrollment_Year) 
VALUES ('John', 'Doe', 'Computer Science', 2023), ('Mike', 'Taylor', 'Mathematics', 2022), ('Sarah', 'Moore', 'Physics', 2023);

-- Inserting into Enrollment
INSERT INTO Enrollment (Student_ID, Course_ID) 
VALUES (1, 1), (2, 2), (3, 3);

-- Inserting into Grade
INSERT INTO Grade (Grade, Student_ID, Course_ID) 
VALUES ('A', 1, 1), ('B', 2, 2), ('A', 3, 3);

