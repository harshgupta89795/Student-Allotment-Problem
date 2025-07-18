--STUDENT ALLOTMENT SQL PROBLEM

CREATE DATABASE University--Created a Seperate Database for Week 4 Task

CREATE TABLE StudentDetails--Created a StudentDetails table which exactly replicates the one in the Problem Statement.
(
	StudentId NVARCHAR(50) PRIMARY KEY,
	StudentName NVARCHAR(50),
	GPA FLOAT,
	Branch NVARCHAR(10),
	Section NVARCHAR(10)
);

CREATE TABLE SubjectDetails--Created a SubjectDetails table which exactly replicates the one in the Problem Statement.
(
	SubjectId NVARCHAR(50) PRIMARY KEY,
	SubjectName NVARCHAR(50),
	MaxSeats INT,
	RemainingSeats INT
);
INSERT INTO SubjectDetails (SubjectId, SubjectName, MaxSeats, RemainingSeats) VALUES--Inserted the data in the SubjectDetails table which exactly replicates the one in the Problem Statement.
('PO1491','Basics of Political Science',60,60),
('PO1492','Basics of Accounting',120,120),
('PO1493','Basics of Financial Markets',90,90),
('PO1494','Eco philosophy',60,60),
('PO1495','Automotive Trends',60,60);

CREATE TABLE  StudentPreference--Created a StudentPreference table which exactly replicates the one in the Problem Statement.
(
	StudentId NVARCHAR(50),--Here this is the Foreign Key From StudentDetails Table.
	SubjectId NVARCHAR(50),--Here this is the Foreign Key From SubjectDetails Table.
	Preference INT CHECK(Preference BETWEEN 1 AND 5),--As the there are 5 subject  given in the Problem Statement so it should be between 1-5.
	PRIMARY KEY(StudentId,Preference),
	FOREIGN KEY(StudentId)REFERENCES StudentDetails(StudentId),
	FOREIGN KEY(SubjectId)REFERENCES SubjectDetails(SubjectId)
);


/*Here, I have created a Procedure for the students by which they can enter their student id and their prefernces of subjects by entring the subject 
id in the order of the prefernce.*/
CREATE PROCEDURE Student_Preference_Procedure
@StudentId NVARCHAR(50),
@SUB1 NVARCHAR(50),
@SUB2 NVARCHAR(50),
@SUB3 NVARCHAR(50),
@SUB4 NVARCHAR(50),
@SUB5 NVARCHAR(50)
AS
BEGIN
	INSERT INTO StudentPreference--Here, I am inserting the data inthe StudentPreference table which will only includes the StudentId, SubjectId, Preference No. exactly which is in the Problem Statment.
	VALUES(@StudentId,@SUB1,1),
	(@StudentId,@SUB2,2),
	(@StudentId,@SUB3,3),
	(@StudentId,@SUB4,4),
	(@StudentId,@SUB5,5)
END


/*As a Student if you want to enter your preferences then enter your student_id with subject_id in the order of your preferences as i have inserted 
below some sample data for my observations and to check that whether the system is working efficiently.*/
EXEC Student_Preference_Procedure '159103036','PO1491','PO1492','PO1493','PO1494','PO1495'
EXEC Student_Preference_Procedure '159103037','PO1494','PO1491','PO1493','PO1492','PO1495'
EXEC Student_Preference_Procedure '159103038','PO1495','PO1492','PO1491','PO1494','PO1493'


CREATE TABLE Allotments--Here, I have created a table for the Students who have been alloted subject of their prefernce. 
(
	SubjectId NVARCHAR(50),
	StudentId NVARCHAR(50),
	FOREIGN KEY(SubjectId)REFERENCES SubjectDetails(SubjectId),
	FOREIGN KEY(StudentId)REFERENCES StudentDetails(StudentId)
);

CREATE Table UnallotedStudents--Here, I have created a table for the Students who havent got any subject alloted to them out of their 5 Preferences.
(
	StudentId NVARCHAR(50)
	FOREIGN KEY(StudentId)REFERENCES StudentDetails(StudentId)
);

--This is the main logic behind the whole Student Allotment System--
CREATE PROCEDURE Alloting_Subjects--Here, I am creating a Procedure to allot each student witha subject of their prefernce
AS
BEGIN
	DECLARE allot CURSOR FOR--Here, I am DECLARING A CURSOR with the name allot--
	--Here I have used CURSOR BECAUSE I WANT TO CHECK DATA ROW BY ROW AND I DONT WANT TO DO BULK PROCESSING OF DATA.
	--HERE I WANT TO PROCESS DATA ROW BY ROW BY CHECKING THE STUDENT ID WITH THEIR CORRESPONDING GPA WHICH AS BEEN ORDERED IN THE DESCENDING ORDER.
	SELECT StudentId
	FROM StudentDetails
	ORDER BY GPA DESC,StudentId ASC--IF THERE ARE MORE THANONE STUDENT WITH SAME GPA THEN THE ORDERING WILL BE DONE BY THEIR STUDENT ID.

	DECLARE @id NVARCHAR(50)

	OPEN allot;--HERE I HAVE OPENED THE CURSOR
	FETCH NEXT FROM allot --THIS LINE FETCHES THE NEXT DATA FROM THE TABLE AND STORES IT INSIDE THE VARIABLE i.e @id
	INTO @id;

	WHILE @@FETCH_STATUS=0-- THIS WHILE LOOP CHECKS THAT WHETHER IS THERE ANY ROW TO BE PROCESSED i.e IS THERE ANY ROW TO BE CHECKED OR NOT 
	BEGIN
		DECLARE @seats_left INT;--TO STORE THE NUMBER OF SEATS LEFT FOR A CORRESPONDING SUBJECT
		DECLARE @subject_id NVARCHAR(50);
		DECLARE @status BIT=0;--TO CHECK WHETHER A STUDENT HAS BEEN ALLOTED A SUBJECT OR NOT.HERE 0 INDICATES NO SUBJECT ALLOTED AND 1 INDICATES ALLOTED.
		DECLARE @preference INT=1;--HERE I HAVE SEETED THE PREFERNCE TO 1 AS STUDENTS PREFERENCES OF THEIR SUBJECT TO BE ALLOTED.

		WHILE @preference<=5 AND @status=0/*THIS CONDITION CHECKS THAT THE STUDENT'S PREFERNCE SHOULD BE BETWEEN 1-5 AND THE STUDENT HASN'T GOT ANY 
		SUBJECT ALLOTED TO THEM i.e @status=0 */
		BEGIN
			SELECT @subject_id=SubjectId--SELECTING AND STORING THE SUBJECT ID CORRESPONDING TO THE STUDENTS FIRST PREFERENCE AND AND HIS/HER STUDENT ID
			FROM StudentPreference
			WHERE Preference=@preference AND StudentId=@id;

			SELECT @seats_left=RemainingSeats--AFTER GETTING THE SUBJECT ID ABOVE WE WILL NOW CHECK THE NUMBER OF SEATS LEFT IN THAT SUBJECT.
			FROM SubjectDetails
			WHERE SubjectId=@subject_id

			IF @seats_left>0--CHECKING IF THERE ARE ANY SEATS LEFT
			BEGIN
				INSERT INTO Allotments--IF SEATS ARE LEFT THEN WE WILL INSERT INTO THE ALLOTMENTS TABLE
				VALUES(@subject_id,@id);

				UPDATE SubjectDetails/*AND WE WILL UPDATE THE UPDATED NUMBER OF SEATS LEFT BY DECREMENTING IT WITH 1 CORRESPONDING TO THE SUBJECT 
				ALLOTED TO THE STUDENT */
				SET RemainingSeats=RemainingSeats-1
				WHERE SubjectId=@subject_id;

				SET @status=1;--HERE I HAVE UPDATED THE STATUS OF ALLOTMENT OF STUDENT TO 1.
			END
		SET @preference=@preference+1;/*IF THE NUMBER OF SEATS ARE NOT >0 THEN IT MEANS THAT THERE NO SEATS LEFT FOR THE SUBJECT OF STUDENTS PREFERENCE
		AND SO IF THE PREFERENCE WAS THEN 1 NOW WE WILL CHECK THE SECOND PREFERENCE IF THERE IS ANY SEAT LEFT IN IT AND SO ON.*/
		END;

	IF @status=0--THIS MEANS AFTER CHECKING ALL THE STUDENTS PREFERENCES ,THEN IF THE STUDENT HASN'T BEEN ALLOTED ANY SUBJECT 
	BEGIN
		INSERT INTO UnallotedStudents--THEN THE STUDENT ID WILL BE INSERTED INTO THE Unalloted Students Table.
		VALUES(@id);
	END
	FETCH NEXT FROM allot INTO @id;--THIS LINE WILL AGAIN FETCH THE ENTRY FROM THE STUDENT TABLE TO CHECK AND ALLOT.
	END;

	CLOSE allot;--HERE AFTER COMPLETING THE ALLOTMENT PROCEDURE WE ARE CLOSING THE CURSOR.
	DEALLOCATE allot;
END

EXEC Alloting_Subjects;--HERE I AM EXECUTING THE PROCEDURE TO ALLOT.

SELECT * FROM Allotments--TO SEE ALL THE Alloted Students table with their SubjectID

SELECT * FROM UnallotedStudents--TO SEE ALL THE UNALLOTED STUDENTS.

SELECT * FROM SubjectDetails--AND NOW HERE IF YOU CHECK THE SubjectDetails table the number of seats are updated and are not equal to the initial ones.

