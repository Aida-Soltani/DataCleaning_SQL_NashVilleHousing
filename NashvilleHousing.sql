
/*

Cleaning Data in SQL Queries

*/

--------------------------------------------------------------------------------------------------------------------------


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

--Standardize SaleDate Format

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order BY ParcelID

SELECT t1.[UniqueID ],t1.ParcelID, t1.PropertyAddress, t2.[UniqueID ],t2.ParcelID, t2.PropertyAddress
FROM NashvilleHousing t1
JOIN NashvilleHousing t2
ON t1.ParcelID = t2.ParcelID
AND t1.[UniqueID ] <> t2.[UniqueID ]
Where t1.PropertyAddress is null


UPDATE t1
SET t1.PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM NashvilleHousing t1
JOIN NashvilleHousing t2
ON t1.ParcelID = t2.ParcelID
AND t1.[UniqueID ] <> t2.[UniqueID ]
Where t1.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

--Breaking PropertyAddress into Individuals Columns (Address, city)

SELECT PropertyAddress
FROM NashvilleHousing


SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE NashvilleHousing
Add PropertySplitcity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--------------------------------------------------------------------------------------------------------------------------


--Breaking OwnerAddress into Individuals Columns (Address, city, State) 

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and NO in "SOldAsVacant"

SELECT DISTINCT(SOldAsVacant), count(SOldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY  SOldAsVacant

SELECT SOldAsVacant,
	CASE 
		WHEN SOldAsVacant = 'Y' THEN 'Yes'
		WHEN SOldAsVacant = 'N' THEN 'No'
		ELSE SOldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SOldAsVacant = 	CASE 
		WHEN SOldAsVacant = 'Y' THEN 'Yes'
		WHEN SOldAsVacant = 'N' THEN 'No'
		ELSE SOldAsVacant
	END


--------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


DELETE *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--------------------------------------------------------------------------------------------------------------------------

-- DELETE Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
