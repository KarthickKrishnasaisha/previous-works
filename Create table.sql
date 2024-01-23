CREATE TABLE Department (
    Department_ID SERIAL PRIMARY KEY,
    Department_Name TEXT NOT NULL
);

CREATE TABLE Faculty (
    Faculty_ID SERIAL PRIMARY KEY,
    First_Name TEXT NOT NULL,
    Last_Name TEXT NOT NULL,
    Department_ID INT NOT NULL,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE Course (
    Course_ID SERIAL PRIMARY KEY,
    Course_Name TEXT NOT NULL,
    Credits INT NOT NULL,
    Faculty_ID INT NOT NULL,
    FOREIGN KEY (Faculty_ID) REFERENCES Faculty(Faculty_ID)
);

CREATE TABLE Student (
    Student_ID SERIAL PRIMARY KEY,
    First_Name TEXT NOT NULL,
    Last_Name TEXT NOT NULL,
    Major TEXT,
    Enrollment_Year INT NOT NULL
);

CREATE TABLE Enrollment (
    Enrollment_ID SERIAL PRIMARY KEY,
    Student_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID)
);

CREATE TABLE Grade (
    Grade_ID SERIAL PRIMARY KEY,
    Grade TEXT NOT NULL,
    Student_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID)
);
