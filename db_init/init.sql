           -- Create database
CREATE DATABASE IF NOT EXISTS shopping_list;
USE shopping_list;

-- Create user table
CREATE TABLE IF NOT EXISTS user (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(80) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- Create family table
CREATE TABLE IF NOT EXISTS family (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80) NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(id)
);

-- Create family_members association table
CREATE TABLE IF NOT EXISTS family_members (
    user_id INTEGER NOT NULL,
    family_id INTEGER NOT NULL,
    PRIMARY KEY (user_id, family_id),
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (family_id) REFERENCES family(id)
);

-- Create shopping_list table
CREATE TABLE IF NOT EXISTS shopping_list (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80) NOT NULL,
    family_id INTEGER NOT NULL,
    creator_id INTEGER NOT NULL,
    FOREIGN KEY (family_id) REFERENCES family(id),
    FOREIGN KEY (creator_id) REFERENCES user(id)
);

-- Create shopping_item table
CREATE TABLE IF NOT EXISTS shopping_item (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80) NOT NULL,
    quantity FLOAT DEFAULT 1.0,
    completed BOOLEAN DEFAULT FALSE,
    measuring_units VARCHAR(80),
    shopping_list_id INTEGER NOT NULL,
    FOREIGN KEY (shopping_list_id) REFERENCES shopping_list(id)
);          