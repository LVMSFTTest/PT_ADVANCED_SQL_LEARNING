CREATE TABLE customer_info (
    CustomerId INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Age INT,
    City VARCHAR(50)
);

-- Create salary table
CREATE TABLE salary (
    SalaryId INT PRIMARY KEY,
    CustomerId INT,
    Salary DECIMAL(10, 2),
    FOREIGN KEY (CustomerId) REFERENCES customer_info(CustomerId)
);

-- Insert sample data into customer_info
INSERT INTO customer_info (CustomerId, FirstName, LastName, Age, City) VALUES
(1, 'John', 'Doe', 30, 'New York'),
(2, 'Jane', 'Smith', 25, 'Los Angeles'),
(3, 'Alice', 'Johnson', 28, 'Chicago'),
(4, 'Bob', 'Brown', 35, 'Miami'),
(5, 'Charlie', 'Davis', 22, 'Seattle'),
(6, 'David', 'Wilson', 40, 'New York'),
(7, 'Emma', 'Garcia', 29, 'Los Angeles'),
(8, 'Frank', 'Martinez', 33, 'Houston'),
(9, 'Grace', 'Lopez', 31, 'Miami'),
(10, 'Hannah', 'Clark', 27, 'Chicago'),
(11, 'Isaac', 'Hernandez', 36, 'Seattle'),
(12, 'Jack', 'Lee', 45, 'Los Angeles'),
(13, 'Karen', 'Gonzalez', 38, 'New York'),
(14, 'Leo', 'Adams', 23, 'Miami'),
(15, 'Mia', 'Carter', 34, 'Houston');

-- Insert sample data into salary
INSERT INTO salary (SalaryId, CustomerId, Salary) VALUES
(1, 1, 60000.00),
(2, 2, 55000.00),
(3, 3, 70000.00),
(4, 4, 80000.00),
(5, 5, 45000.00),
(6, 6, 95000.00),
(7, 7, 58000.00),
(8, 8, 75000.00),
(9, 9, 72000.00),
(10, 10, 62000.00),
(11, 11, 90000.00),
(12, 12, 100000.00),
(13, 13, 85000.00),
(14, 14, 50000.00),
(15, 15, 68000.00);
