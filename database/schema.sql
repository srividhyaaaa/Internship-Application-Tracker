CREATE DATABASE IF NOT EXISTS internship_tracker
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE internship_tracker;

CREATE TABLE IF NOT EXISTS applications (
    id BIGINT NOT NULL AUTO_INCREMENT,
    company_name VARCHAR(150) NOT NULL,
    role_name VARCHAR(150) NOT NULL,
    deadline DATE NOT NULL,
    priority VARCHAR(10) NOT NULL,
    status VARCHAR(20) NOT NULL,
    application_link VARCHAR(2048) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT chk_applications_priority CHECK (priority IN ('High', 'Medium', 'Low')),
    CONSTRAINT chk_applications_status CHECK (
        status IN ('Applied', 'Assessment', 'Interview', 'Offer', 'Rejected', 'Withdrawn')
    )
) ENGINE=InnoDB;
