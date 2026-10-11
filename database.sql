CREATE DATABASE IF NOT EXISTS interntrack;
USE interntrack;
-- If a users table already exists and login/register work, keep it.
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    company VARCHAR(100) NOT NULL,
    role VARCHAR(100) NOT NULL,
    deadline DATE NULL,
    status VARCHAR(30) NOT NULL,
    application_link VARCHAR(500) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_applications_user_id ON applications(user_id);

CREATE TABLE IF NOT EXISTS interviews (
    interview_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    round_name VARCHAR(100) NOT NULL,
    interview_date DATE NOT NULL,
    interview_time TIME NOT NULL,
    interview_mode VARCHAR(20) NOT NULL,
    preparation_notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_interviews_user_schedule (user_id, interview_date, interview_time)
);

CREATE TABLE IF NOT EXISTS follow_ups (
    follow_up_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    due_date DATE NOT NULL,
    notes TEXT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_follow_ups_user_due (user_id, due_date, completed)
);
