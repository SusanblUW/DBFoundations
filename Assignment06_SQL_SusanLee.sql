--*************************************************************************--
-- Title: Assignment06
-- Author: SusanLee
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2020-11-22,SusanLee,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SusanLee')
	 Begin 
	  Alter Database [Assignment06DB_SusanLee] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SusanLee;
	 End
	Create Database Assignment06DB_SusanLee;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SusanLee;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


-- Creating Basic View for Categories
GO
CREATE VIEW vCategories 
WITH SCHEMABINDING
AS
	SELECT
		 CategoryID
		,CategoryName
	FROM dbo.Categories;
GO

SELECT * FROM vCategories; -- CHECKING WORK
SELECT * FROM Categories; -- CHECKING WORK

-- Creating Basic View for Products
GO
CREATE VIEW vProducts 
WITH SCHEMABINDING
AS
	SELECT
		 ProductID
		,ProductName
		,CategoryID
		,UnitPrice		
	FROM dbo.Products;
GO

SELECT * FROM vProducts; -- CHECKING WORK
SELECT * FROM Products; -- CHECKING WORK

-- Creating Basic View for Employees
GO
CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT
		  EmployeeID
		, EmployeeFirstName
		, EmployeeLastName
		, ManagerID
	FROM dbo.Employees;
GO

SELECT * FROM vEmployees; -- CHECKING WORK
SELECT * FROM Employees; -- CHECKING WORK


-- Creating Basic View for Inventories
GO
CREATE VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT
		 InventoryID
		,InventoryDate
		,EmployeeID
		,ProductID
		,[Count]
	FROM
		dbo.Inventories;
GO

SELECT * FROM vInventories; -- CHECKING WORK
SELECT * FROM Inventories; -- CHECKING WORK

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON Categories TO PUBLIC;
DENY SELECT ON Products TO PUBLIC;
DENY SELECT ON Employees TO PUBLIC;
DENY SELECT ON Inventories TO PUBLIC;

GRANT SELECT ON vCategories TO PUBLIC;
GRANT SELECT ON vProducts TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

SELECT * FROM vCategories;
SELECT * FROM vProducts;

GO
CREATE VIEW vCategoriesAndProducts
AS
	SELECT TOP 1000000
		 CategoryName
		,ProductName
		,UnitPrice
	FROM
		vCategories AS C INNER JOIN
		vProducts AS P ON
		C.CategoryID = P.CategoryID
	ORDER BY
		 CategoryName
		,ProductName;
GO

SELECT * FROM vCategoriesAndProducts; -- CHECKING WORK


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

SELECT * FROM vProducts;
SELECT * FROM vInventories;

GO
CREATE VIEW vProductAndInventories
AS 
	SELECT TOP 1000000
		ProductName
		,InventoryDate
		,SUM([Count]) AS Count
	FROM
		vProducts AS P INNER JOIN
		vInventories AS I ON
		P.ProductID = I.ProductID
	GROUP BY
		ProductName
		,InventoryDate
	ORDER BY
		ProductName
		,InventoryDate
		,SUM([Count]);
GO

SELECT * FROM vProductAndInventories; -- CHECKING WORK

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

SELECT * FROM vInventories;
SELECT * FROM vEmployees;

GO
CREATE VIEW vInventoryAndEmployees
AS
	SELECT TOP 1000000
		InventoryDate
		,(E.EmployeeFirstName + ' '+ E.EmployeeLastName) AS EmployeeName
	FROM
		vInventories AS I INNER JOIN
		vEmployees AS E ON
		I.EmployeeID = E.EmployeeID
	GROUP BY
		InventoryDate
		,(E.EmployeeFirstName + ' '+ E.EmployeeLastName);

SELECT * FROM vInventoryAndEmployees; -- CHECKING WORK

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

SELECT * FROM vCategories;
SELECT * FROM vProducts;
SELECT * FROM vInventories;

GO
CREATE VIEW vCategoriesAndProductsAndInventories
AS
	SELECT TOP 1000000
		CategoryName
		,ProductName
		,InventoryDate
		,SUM([Count]) AS Count
	FROM	
		vCategories AS C INNER JOIN
		vProducts	AS P 
		ON C.CategoryID = P.CategoryID
		INNER JOIN
		vInventories AS I
		ON P.ProductID = I.ProductID
	GROUP BY
		CategoryName
		,ProductName
		,InventoryDate
	ORDER BY
		CategoryName
		,ProductName
		,InventoryDate
		,SUM([Count]);
GO

SELECT * FROM vCategoriesAndProductsAndInventories; -- CHECKING WORK

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Inventories;
SELECT * FROM Employees;

GO
CREATE VIEW vCategoriesAndProductsAndInventoriesAndEmployees
AS
	SELECT TOP 1000000
			CategoryName
			,ProductName
			,InventoryDate
			,SUM([Count]) AS Count
			,(EmployeeFirstName + ' ' + EmployeeLastName) AS EmployeeName
		FROM	
			vCategories AS C INNER JOIN
			vProducts	AS P 
			ON C.CategoryID = P.CategoryID INNER JOIN
			vInventories AS I
			ON P.ProductID = I.ProductID INNER JOIN
			vEmployees AS E
			ON I.EmployeeID = E.EmployeeID
		GROUP BY
			CategoryName
			,ProductName
			,InventoryDate
			,(EmployeeFirstName + ' ' + EmployeeLastName) 
		ORDER BY
			InventoryDate
			,CategoryName
			,ProductName
			,(EmployeeFirstName + ' ' + EmployeeLastName);
GO

SELECT * FROM vCategoriesAndProductsAndInventoriesAndEmployees; -- CHECKING WORK

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

GO
CREATE VIEW vEmployeesInventoryCheckOnChaiChang
AS
	SELECT TOP 1000000
			CategoryName
			,ProductName
			,InventoryDate
			,SUM([Count]) AS Count
			,(EmployeeFirstName + ' ' + EmployeeLastName) AS EmployeeName
		FROM	
			vCategories AS C INNER JOIN
			vProducts	AS P 
			ON C.CategoryID = P.CategoryID INNER JOIN
			vInventories AS I
			ON P.ProductID = I.ProductID INNER JOIN
			vEmployees AS E
			ON I.EmployeeID = E.EmployeeID
		WHERE
			ProductName IN ('Chai', 'Chang')
		GROUP BY
			CategoryName
			,ProductName
			,InventoryDate
			,(EmployeeFirstName + ' ' + EmployeeLastName) 
		ORDER BY
			InventoryDate
			,CategoryName
			,ProductName
			,(EmployeeFirstName + ' ' + EmployeeLastName);
GO

SELECT * FROM vEmployeesInventoryCheckOnChaiChang; -- CHECKING WORK

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

SELECT * FROM vEmployees;

GO
CREATE VIEW vManagerEmployee
AS
	SELECT TOP 1000000
		(M.EmployeeFirstName + ' ' + M.EmployeeLastName) AS ManagerName
		,(E.EmployeeFirstName + ' ' + E.EmployeeLastName) AS EmployeeName
	FROM
		vEmployees AS E INNER JOIN
		vEmployees AS M ON
		E.ManagerID = M.EmployeeID
	ORDER BY
		(M.EmployeeFirstName + ' ' + M.EmployeeLastName)
		,(E.EmployeeFirstName + ' ' + E.EmployeeLastName);
GO

SELECT * FROM vManagerEmployee; -- CHECKING WORK

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

GO
CREATE VIEW vViewAllData
AS
	SELECT TOP 1000000
				C.CategoryID
				,CategoryName
				,P.ProductID
				,ProductName
				,UnitPrice
				,I.InventoryID
				,InventoryDate
				,SUM([Count]) AS Count
				,E.EmployeeID
				,(E.EmployeeFirstName + ' ' + E.EmployeeLastName) AS Employee
				,(M.EmployeeFirstName + ' ' + M.EmployeeLastName) AS Manager
			FROM	
				vCategories AS C INNER JOIN
				vProducts	AS P 
				ON C.CategoryID = P.CategoryID INNER JOIN
				vInventories AS I
				ON P.ProductID = I.ProductID INNER JOIN
				vEmployees AS E
				ON I.EmployeeID = E.EmployeeID INNER JOIN
				vEmployees AS M
				ON E.ManagerID = M.EmployeeID
			GROUP BY
				C.CategoryID
				,CategoryName
				,P.ProductID
				,ProductName
				,UnitPrice
				,I.InventoryID
				,InventoryDate
				,E.EmployeeID
				,(E.EmployeeFirstName + ' ' + E.EmployeeLastName)
				,(M.EmployeeFirstName + ' ' + M.EmployeeLastName)
			ORDER BY
				C.CategoryID
				,CategoryName
				,P.ProductID
				,ProductName
				,UnitPrice
				,I.InventoryID
				,InventoryDate
				,SUM([Count])
				,E.EmployeeID
				,(E.EmployeeFirstName + ' ' + E.EmployeeLastName)
				,(M.EmployeeFirstName + ' ' + M.EmployeeLastName);
GO

SELECT * FROM vViewAllData;

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoriesAndProducts]
Select * From [dbo].[vProductAndInventories]
Select * From [dbo].[vInventoryAndEmployees]
Select * From [dbo].[vCategoriesAndProductsAndInventories]
Select * From [dbo].[vCategoriesAndProductsAndInventoriesAndEmployees]
Select * From [dbo].[vEmployeesInventoryCheckOnChaiChang]
Select * From [dbo].[vManagerEmployee]
Select * From [dbo].[vViewAllData]
/***************************************************************************************/