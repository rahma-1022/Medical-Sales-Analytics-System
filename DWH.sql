CREATE DATABASE medical_sales;

USE medical_sales;


CREATE TABLE CustomerDim (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(255)
);

CREATE TABLE DateDim (
    DateID INT PRIMARY KEY,
    FullDate DATE,
    Year INT,
    Quarter INT,
    QuarterName VARCHAR(2),
    Month INT,
    MonthName VARCHAR(20),
    Day INT,
    Weekday INT,
    WeekdayName VARCHAR(20)
);

CREATE TABLE PaymentDim (
    PaymentID INT PRIMARY KEY,
    PaymentStatus VARCHAR(30)
);

CREATE TABLE FactSales (
    InvoiceID INT PRIMARY KEY,
    DateID INT,
    CustomerID INT,
    PaymentID INT,
    ItemsCount INT,
    TotalBeforeDiscount DECIMAL(10,2),
    DiscountAmount DECIMAL(10,2),
    Total DECIMAL(10,2),
    PaidAmount DECIMAL(10,2),
    RemainingBalance DECIMAL(10,2),

    FOREIGN KEY (DateID) REFERENCES DateDim(DateID),
    FOREIGN KEY (CustomerID) REFERENCES CustomerDim(CustomerID),
    FOREIGN KEY (PaymentID) REFERENCES PaymentDim(PaymentID)
);



INSERT INTO CustomerDim (CustomerID, CustomerName)
SELECT
ROW_NUMBER() OVER (ORDER BY Customer_Name),
Customer_Name
FROM
(
SELECT DISTINCT Customer_Name
FROM cleaned_sales
) c;


INSERT INTO DateDim
SELECT DISTINCT
DATE_FORMAT(Date_Time,'%Y%m%d') AS DateID,
DATE(Date_Time),
YEAR(Date_Time),
QUARTER(Date_Time),
CONCAT('Q',QUARTER(Date_Time)),
MONTH(Date_Time),
MONTHNAME(Date_Time),
DAY(Date_Time),
DAYOFWEEK(Date_Time),
DAYNAME(Date_Time)
FROM cleaned_sales;


INSERT INTO PaymentDim (PaymentID, PaymentStatus)
SELECT
ROW_NUMBER() OVER(ORDER BY Payment_Status),
Payment_Status
FROM
(
SELECT DISTINCT Payment_Status
FROM cleaned_sales
)p;


INSERT INTO FactSales
SELECT
c.ID,
d.DateID,
cu.CustomerID,
p.PaymentID,
c.Items_Count,
c.Total_Before_Discount,
c.Discount_Amount,
c.Total,
c.Paid_Amount,
c.Remaining_Balance
FROM cleaned_sales c
JOIN CustomerDim cu
ON c.Customer_Name = cu.CustomerName
JOIN PaymentDim p
ON c.Payment_Status = p.PaymentStatus
JOIN DateDim d
ON DATE(c.Date_Time)=d.FullDate;






SELECT * FROM medical_sales.factsales;