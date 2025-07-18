# Student-Allotment-Problem

This project implements a Student Subject Allotment System using SQL Server. It simulates a real-world university scenario where students choose their preferred subjects and are allotted one based on their GPA and preference order, with subject seat limits in place.

---

## 📂 Project Structure

The project includes the following SQL components:

- `StudentDetails` table – Student master data with GPA
- `SubjectDetails` table – Subjects with max and remaining seats
- `StudentPreference` table – Students' ranked subject preferences
- `Allotments` table – Stores students who successfully got a subject
- `UnallotedStudents` table – Stores students who couldn't be allotted
- Stored Procedures:
  - `Student_Preference_Procedure` – Insert preferences for a student
  - `Alloting_Subjects` – Logic to allot students based on GPA and preferences

---

## ⚙️ Technologies Used

- SQL Server Management Studio (SSMS)
- T-SQL (Procedures, Cursors, Joins)
- Relational Database Design

---

## 🧠 Logic Summary

- Students provide up to 5 subject preferences.
- Allocation is GPA-based: higher GPA students are given priority.
- A student is assigned their highest-ranked preference that has available seats.
- If none of the preferred subjects have seats, the student is added to the `UnallotedStudents` table.
- Remaining seat counts in `SubjectDetails` are updated accordingly.

---

## ▶️ How It Works

1. **Create and Populate Tables:**
   - Define student and subject tables.
   - Insert subject data.

2. **Add Student Preferences:**
   - Use the procedure `Student_Preference_Procedure` to insert preferences.

3. **Run Allotment Logic:**
   - Execute `Alloting_Subjects` procedure to start the allocation.

4. **View Results:**
   - `SELECT * FROM Allotments` – See which subject each student got.
   - `SELECT * FROM UnallotedStudents` – See who didn’t get a subject.
   - `SELECT * FROM SubjectDetails` – Check updated seat counts.

## 📌 Sample Execution

sql
EXEC Student_Preference_Procedure '159103036','PO1491','PO1492','PO1493','PO1494','PO1495';
EXEC Alloting_Subjects;
