/*
    Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvillHousing

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvillHousing

Update NashvillHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvillHousing
Add SaleDateConerted Date;

Update NashvillHousing
SET SaleDateConerted = CONVERT(Date, SaleDate)

Select SaleDateConerted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvillHousing


-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvillHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvillHousing a
JOIN PortfolioProject.dbo.NashvillHousing b
    On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvillHousing a
JOIN PortfolioProject.dbo.NashvillHousing b
    On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvillHousing

Select 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvillHousing

ALTER TABLE NashvillHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvillHousing
Add PropertySplitCity Nvarchar(255);

Update NashvillHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvillHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvillHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject.dbo.NashvillHousing


ALTER TABLE NashvillHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvillHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvillHousing
Add OwnerSplitSate Nvarchar(255);

Update NashvillHousing
SET OwnerSplitSate = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
From PortfolioProject.dbo.NashvillHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvillHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvillHousing

Update NashvillHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-- Remove Duplicates

WITH RowNumCTE AS (
Select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   ) row_num
From PortfolioProject.dbo.NashvillHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject.dbo.NashvillHousing



-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvillHousing

ALTER TABLE PortfolioProject.dbo.NashvillHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvillHousing
DROP COLUMN SaleDate


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT

-- More advanced and looks cooler, but have to configure server appropriately to do correctly
-- Wanted to provide this in case you wanted to try it 

--sp_configure 'show advanced options', 1;
-- RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE
--GO


--USE PortfolioProject

--GO

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1

-- GO

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1

-- GO


----- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Stodio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH(
--      FIELDTERMINATOR = ','.
--      ROWTERMIMATOR = '\n'
--);
--GO


--Using OPENROWSET
--USE PortflioProject
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO