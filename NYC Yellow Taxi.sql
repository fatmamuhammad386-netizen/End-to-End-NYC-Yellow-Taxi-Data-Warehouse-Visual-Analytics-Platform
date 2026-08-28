CREATE TABLE Dim_Vendor (
    VendorKey INT IDENTITY(1,1) PRIMARY KEY,
    VendorID INT NOT NULL,
    VendorName VARCHAR(100) NOT NULL
);
CREATE TABLE Dim_Ratecode (
    RatecodeKey INT IDENTITY(1,1) PRIMARY KEY,
    RatecodeID INT NOT NULL, 
    RateDescription VARCHAR(100) NOT NULL
);
CREATE TABLE Dim_PaymentType (
    PaymentTypeKey INT IDENTITY(1,1) PRIMARY KEY,
    PaymentTypeID INT NOT NULL,
    PaymentDescription VARCHAR(50) NOT NULL
);

CREATE TABLE Dim_Location (
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,
    LocationID INT NOT NULL, 
    Borough VARCHAR(50) DEFAULT 'Unknown',
    Zone VARCHAR(100) DEFAULT 'Unknown',
    service_zone VARCHAR(50) DEFAULT 'Unknown'
);

CREATE TABLE Dim_Date (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    QuarterName VARCHAR(2) NOT NULL, 
    Month INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    DayOfMonth INT NOT NULL,
    DayOfWeek INT NOT NULL,
    DayName VARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL,
    IsHoliday BIT DEFAULT 0
);

CREATE TABLE Dim_Time (
    TimeKey INT PRIMARY KEY, 
    TimeValue TIME NOT NULL,
    Hour INT NOT NULL,
    Minute INT NOT NULL,
    AmPm VARCHAR(2) NOT NULL,
    TimeBucket VARCHAR(20) NOT NULL 
);

CREATE TABLE Fact_TaxiTrips (
    TripID BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    VendorKey INT FOREIGN KEY REFERENCES Dim_Vendor(VendorKey),
    RatecodeKey INT FOREIGN KEY REFERENCES Dim_Ratecode(RatecodeKey),
    PaymentTypeKey INT FOREIGN KEY REFERENCES Dim_PaymentType(PaymentTypeKey),
    PULocationKey INT FOREIGN KEY REFERENCES Dim_Location(LocationKey),
    DOLocationKey INT FOREIGN KEY REFERENCES Dim_Location(LocationKey),
    
    PickupDateKey INT FOREIGN KEY REFERENCES Dim_Date(DateKey),
    DropoffDateKey INT FOREIGN KEY REFERENCES Dim_Date(DateKey),
    PickupTimeKey INT FOREIGN KEY REFERENCES Dim_Time(TimeKey),
    DropoffTimeKey INT FOREIGN KEY REFERENCES Dim_Time(TimeKey),
    
    StoreAndFwdFlag CHAR(1),
    
    PassengerCount INT,
    TripDistance FLOAT,
    FareAmount DECIMAL(10,2),
    Extra DECIMAL(10,2),
    MtaTax DECIMAL(10,2),
    TipAmount DECIMAL(10,2),
    TollsAmount DECIMAL(10,2),
    ImprovementSurcharge DECIMAL(10,2),
    CongestionSurcharge DECIMAL(10,2),
    AirportFee DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
    
    TripDurationMin DECIMAL(10,2),
    AvgSpeedMph DECIMAL(10,2)
);

CREATE TABLE Audit_TaxiErrors (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    VendorID FLOAT NULL,
    tpep_pickup_datetime DATETIME NULL,
    tpep_dropoff_datetime DATETIME NULL,
    passenger_count FLOAT NULL,
    trip_distance FLOAT NULL,
    RatecodeID FLOAT NULL,
    store_and_fwd_flag VARCHAR(10) NULL,
    PULocationID INT NULL,
    DOLocationID INT NULL,
    payment_type FLOAT NULL,
    fare_amount FLOAT NULL,
    extra FLOAT NULL,
    mta_tax FLOAT NULL,
    tip_amount FLOAT NULL,
    tolls_amount FLOAT NULL,
    improvement_surcharge FLOAT NULL,
    total_amount FLOAT NULL,
    congestion_surcharge FLOAT NULL,
    Airport_fee FLOAT NULL,
    error_reason VARCHAR(255) NULL,
    created_at DATETIME DEFAULT GETDATE()
);


-- 1. Executive Summary & Revenue Analysis View
CREATE VIEW vw_ExecutiveSummary AS
SELECT 
    f.TripID,
    d.FullDate,
    d.Year,
    d.MonthName,
    d.DayName,
    d.IsWeekend,
    p.PaymentDescription,
    v.VendorName,
    r.RateDescription,
    f.TripDistance,
    f.TripDurationMin,
    f.FareAmount,
    f.TipAmount,
    f.TotalAmount
FROM Fact_TaxiTrips f
JOIN Dim_Date d ON f.PickupDateKey = d.DateKey
JOIN Dim_PaymentType p ON f.PaymentTypeKey = p.PaymentTypeKey
JOIN Dim_Vendor v ON f.VendorKey = v.VendorKey
JOIN Dim_Ratecode r ON f.RatecodeKey = r.RatecodeKey;
GO

-- 2. Time-Series & Demand Pattern Analytics View
CREATE VIEW vw_TimeDemandAnalysis AS
SELECT 
    f.TripID,
    t.Hour,
    t.TimeBucket,
    t.AmPm,
    d.DayName,
    d.DayOfWeek,
    f.AvgSpeedMph,
    f.TripDurationMin,
    f.TotalAmount
FROM Fact_TaxiTrips f
JOIN Dim_Time t ON f.PickupTimeKey = t.TimeKey
JOIN Dim_Date d ON f.PickupDateKey = d.DateKey;
GO


-- 3. Geospatial & Route Performance View
CREATE VIEW vw_RouteAnalysis AS
SELECT 
    f.TripID,
    pu.LocationID AS PickupLocationID,
    do.LocationID AS DropoffLocationID,
    CONCAT(pu.LocationID, ' -> ', do.LocationID) AS Route,
    f.TripDistance,
    f.TotalAmount
FROM Fact_TaxiTrips f
JOIN Dim_Location pu ON f.PULocationKey = pu.LocationKey
JOIN Dim_Location do ON f.DOLocationKey = do.LocationKey;
GO



-- 4. Data Quality & Audit Summary View
CREATE VIEW vw_AuditSummary AS
SELECT 
    ErrorID,
    error_reason,
    created_at
FROM Audit_TaxiErrors;

-- 5. Financial Breakdown & Surcharge Distribution View
CREATE VIEW vw_FinancialBreakdown AS
SELECT 
    f.TripID,
    d.FullDate,
    d.MonthName,
    p.PaymentDescription,
    f.FareAmount,
    f.Extra,
    f.MtaTax,
    f.TipAmount,
    f.TollsAmount,
    f.ImprovementSurcharge,
    f.CongestionSurcharge,
    f.AirportFee,
    f.TotalAmount,
    (f.TipAmount / NULLIF(f.FareAmount, 0)) * 100 AS TipPercentage
FROM Fact_TaxiTrips f
JOIN Dim_Date d ON f.PickupDateKey = d.DateKey
JOIN Dim_PaymentType p ON f.PaymentTypeKey = p.PaymentTypeKey;

SELECT * FROM [dbo].[Dim_PaymentType][NYC_Taxi_DW]