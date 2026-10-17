
CREATE DATABASE IF NOT EXISTS OnlineExaminationSystem;
USE OnlineExaminationSystem;

CREATE TABLE IF NOT EXISTS Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS Exams (
    exam_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS Questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT,
    question_text VARCHAR(255) NOT NULL,
    marks INT NOT NULL DEFAULT 1,
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id)
);

CREATE TABLE IF NOT EXISTS ExamAttempts (
    attempt_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    exam_id INT,
    status VARCHAR(20) DEFAULT 'In Progress',
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id)
);

CREATE TABLE IF NOT EXISTS Answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT,
    question_id INT,
    answer_text VARCHAR(255),
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (attempt_id) REFERENCES ExamAttempts(attempt_id),
    FOREIGN KEY (question_id) REFERENCES Questions(question_id)
);

CREATE TABLE IF NOT EXISTS Results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT UNIQUE,
    total_marks INT DEFAULT 0,
    result_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (attempt_id) REFERENCES ExamAttempts(attempt_id)
);

DROP PROCEDURE IF EXISTS FinishExam;

DELIMITER //

CREATE PROCEDURE FinishExam(IN p_attempt_id INT)
BEGIN
    DECLARE v_total_marks INT DEFAULT 0;
    DECLARE v_exam_id INT;
    DECLARE v_affected_rows INT DEFAULT 0;

    START TRANSACTION;

    SELECT exam_id
    INTO v_exam_id
    FROM ExamAttempts
    WHERE attempt_id = p_attempt_id
      AND status = 'In Progress'
    FOR UPDATE;

    SELECT COALESCE(SUM(
        CASE
            WHEN A.is_correct = TRUE THEN Q.marks
            ELSE 0
        END
    ), 0)
    INTO v_total_marks
    FROM Answers A
    JOIN Questions Q
        ON A.question_id = Q.question_id
    WHERE A.attempt_id = p_attempt_id
      AND Q.exam_id = v_exam_id;

    UPDATE ExamAttempts
    SET status = 'Completed'
    WHERE attempt_id = p_attempt_id
      AND status = 'In Progress';

    SET v_affected_rows = ROW_COUNT();

    IF v_affected_rows = 1 THEN
        INSERT INTO Results (attempt_id, total_marks)
        VALUES (p_attempt_id, v_total_marks);
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END //

DELIMITER ;
