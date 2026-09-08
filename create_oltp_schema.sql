CREATE TABLE Locations (
    ZipCodePrefix VARCHAR(10) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    State VARCHAR(2) NOT NULL,
    CONSTRAINT PK_Locations PRIMARY KEY (ZipCodePrefix)
);

CREATE TABLE Categories (
    CategoryNamePT VARCHAR(100) NOT NULL,
    CategoryNameEN VARCHAR(100) NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryNamePT)
);

CREATE TABLE Customers (
    CustomerUniqueID VARCHAR(50) NOT NULL,
    ZipCodePrefix VARCHAR(10) NOT NULL,
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerUniqueID),
    CONSTRAINT FK_Customers_Locations FOREIGN KEY (ZipCodePrefix) REFERENCES Locations(ZipCodePrefix)
);
CREATE NONCLUSTERED INDEX IX_Customers_ZipCode ON Customers(ZipCodePrefix);

CREATE TABLE Sellers (
    SellerID VARCHAR(50) NOT NULL,
    ZipCodePrefix VARCHAR(10) NOT NULL,
    CONSTRAINT PK_Sellers PRIMARY KEY (SellerID),
    CONSTRAINT FK_Sellers_Locations FOREIGN KEY (ZipCodePrefix) REFERENCES Locations(ZipCodePrefix)
);
CREATE NONCLUSTERED INDEX IX_Sellers_ZipCode ON Sellers(ZipCodePrefix);

CREATE TABLE Products (
    ProductID VARCHAR(50) NOT NULL,
    CategoryNamePT VARCHAR(100) NULL,
    Weight_g INT NULL,
    Length_cm INT NULL,
    Height_cm INT NULL,
    Width_cm INT NULL,
    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryNamePT) REFERENCES Categories(CategoryNamePT)
);
CREATE NONCLUSTERED INDEX IX_Products_Category ON Products(CategoryNamePT);

CREATE TABLE Orders (
    OrderID VARCHAR(50) NOT NULL,
    CustomerUniqueID VARCHAR(50) NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,
    PurchaseTimestamp DATETIME2 NOT NULL,
    ApprovedAt DATETIME2 NULL,
    DeliveredCarrierDate DATETIME2 NULL,
    DeliveredCustomerDate DATETIME2 NULL,
    EstimatedDeliveryDate DATETIME2 NULL,
    CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerUniqueID) REFERENCES Customers(CustomerUniqueID)
);
CREATE NONCLUSTERED INDEX IX_Orders_Customer ON Orders(CustomerUniqueID);
CREATE NONCLUSTERED INDEX IX_Orders_PurchaseDate ON Orders(PurchaseTimestamp);

CREATE TABLE OrderItems (
    OrderID VARCHAR(50) NOT NULL,
    OrderItemID INT NOT NULL,
    ProductID VARCHAR(50) NOT NULL,
    SellerID VARCHAR(50) NOT NULL,
    Price DECIMAL(12,2) NOT NULL CHECK (Price >= 0),
    FreightValue DECIMAL(12,2) NOT NULL CHECK (FreightValue >= 0),
    CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, OrderItemID),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_OrderItems_Sellers FOREIGN KEY (SellerID) REFERENCES Sellers(SellerID)
);
CREATE NONCLUSTERED INDEX IX_OrderItems_Product ON OrderItems(ProductID);
CREATE NONCLUSTERED INDEX IX_OrderItems_Seller ON OrderItems(SellerID);

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) NOT NULL,
    OrderID VARCHAR(50) NOT NULL,
    PaymentSequential INT NOT NULL,
    PaymentType VARCHAR(30) NOT NULL,
    PaymentInstallments INT NOT NULL,
    PaymentValue DECIMAL(14,2) NOT NULL CHECK (PaymentValue >= 0),
    CONSTRAINT PK_Payments PRIMARY KEY (PaymentID),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
CREATE NONCLUSTERED INDEX IX_Payments_Order ON Payments(OrderID);

CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) NOT NULL,
    OrderID VARCHAR(50) NOT NULL,
    ReviewScore INT NOT NULL CHECK (ReviewScore BETWEEN 1 AND 5),
    ReviewTitle NVARCHAR(100) NULL,
    ReviewMessage NVARCHAR(MAX) NULL,
    CreationDate DATETIME2 NOT NULL,
    AnswerTimestamp DATETIME2 NOT NULL,
    CONSTRAINT PK_Reviews PRIMARY KEY (ReviewID),
    CONSTRAINT FK_Reviews_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
CREATE NONCLUSTERED INDEX IX_Reviews_Order ON Reviews(OrderID);
