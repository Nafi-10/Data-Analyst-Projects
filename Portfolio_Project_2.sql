/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject..DataforDataCleaning

-----------------------------------------------------------------------------------------------
--Standardized Data Format

SELECT SaleDate, CONVERT(Date,SaleDate) as ConvertedSaleDate
FROM PortfolioProject..DataforDataCleaning

UPDATE DataforDataCleaning
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE DataforDataCleaning
Add SaleDateConverted Date;

UPDATE DataforDataCleaning
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..DataforDataCleaning


--Populate Property Address Data

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..DataforDataCleaning a
JOIN PortfolioProject..DataforDataCleaning b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..DataforDataCleaning a
JOIN PortfolioProject..DataforDataCleaning b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]

SELECT PropertyAddress
FROM PortfolioProject..DataforDataCleaning
WHERE PropertyAddress is null

--Breaking out Address into Indiidual Columns (Address,City,State)

SELECT PropertyAddress
FROM PortfolioProject..DataforDataCleaning

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM PortfolioProject..DataforDataCleaning

ALTER TABLE DataforDataCleaning
Add Property_Split_Address Nvarchar(255);

UPDATE DataforDataCleaning
SET Property_Split_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE DataforDataCleaning
Add Property_Split_City Nvarchar(255);

UPDATE DataforDataCleaning
SET Property_Split_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * 
FROM PortfolioProject..DataforDataCleaning

SELECT OwnerAddress
FROM PortfolioProject..DataforDataCleaning


SELECT 

PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State

FROM PortfolioProject..DataforDataCleaning

ALTER TABLE DataforDataCleaning
Add Owner_Split_Address Nvarchar(255);

UPDATE DataforDataCleaning
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE DataforDataCleaning
Add Owner_Split_City Nvarchar(255);

UPDATE DataforDataCleaning
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE DataforDataCleaning
Add Owner_Split_State Nvarchar(255);

UPDATE DataforDataCleaning
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject..DataforDataCleaning

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..DataforDataCleaning
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant,
CASE When SoldAsVacant='Y' THEN 'YES'
	 WHEN SoldAsVacant='N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..DataforDataCleaning

UPDATE DataforDataCleaning
SET SoldAsVacant = CASE When SoldAsVacant='Y' THEN 'YES'
	 WHEN SoldAsVacant='N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

--Removve Duplicates

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject..DataforDataCleaning
)

DELETE  
FROM RowNumCTE
Where row_num > 1

--Delete Unused Columns

SELECT *
FROM PortfolioProject..DataforDataCleaning

ALTER TABLE PortfolioProject..DataforDataCleaning
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate