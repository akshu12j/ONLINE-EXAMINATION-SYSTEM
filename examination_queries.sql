
USE OnlineExaminationSystem;

-- 1. Display all students
SELECT * FROM Students;

-- 2. Display all exams
SELECT * FROM Exams;

-- 3. Display all questions
SELECT * FROM Questions;

-- 4. Display all exam attempts
SELECT * FROM ExamAttempts;

-- 5. Display all submitted answers
SELECT * FROM Answers;

-- 6. Display student details with exam details
SELECT
    S.student_id,
    S.student_name,
    E.exam_name,
    EA.attempt_id,
    EA.status
FROM Students S
JOIN ExamAttempts EA
    ON S.student_id = EA.student_id
JOIN Exams E
    ON EA.exam_id = E.exam_id;

-- 7. Display marks obtained by each student
SELECT
    S.student_name,
    E.exam_name,
    EA.attempt_id,
    R.total_marks,
    EA.status
FROM Students S
JOIN ExamAttempts EA
    ON S.student_id = EA.student_id
JOIN Exams E
    ON EA.exam_id = E.exam_id
LEFT JOIN Results R
    ON EA.attempt_id = R.attempt_id;

-- 8. Count attempts for each exam
SELECT
    E.exam_name,
    COUNT(EA.attempt_id) AS total_attempts
FROM Exams E
LEFT JOIN ExamAttempts EA
    ON E.exam_id = EA.exam_id
GROUP BY E.exam_id, E.exam_name;

-- 9. Check status of a particular attempt
SELECT *
FROM ExamAttempts
WHERE attempt_id = 1;

-- 10. Finish an exam attempt
CALL FinishExam(1);

-- 11. Display result of attempt 1
SELECT *
FROM Results
WHERE attempt_id = 1;
