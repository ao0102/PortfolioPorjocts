/*

Cleaning Data in SQL Queries

*/

---Standardized Date Format

SELECT SaleDateConverted, CONVERT(DATE, Saledate)
FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, Saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, Saledate)

----------------------------------------------------------------------------------------------

--Populate Property Address Data


SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)	
FROM Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing
--WHERE PropertyAddress is Null
--Order BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing


SELECT OwnerAddress
FROM Portfolio_Project.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

 ----------------------------------------------------------------------------------------

 --Change Y and N to Yes and No in "Sold as Vacant" field

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM Portfolio_Project.dbo.NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2

 SELECT SoldAsVacant
 , CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END 


------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Portfolio_Project.dbo.NashvilleHousing
--ORDER BY ParcelID
)SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate