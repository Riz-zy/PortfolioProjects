


 -- Standardize Date Formate

SELECT * 
FROM PortfolioProjects.dbo.NashvilleHousingData


SELECT SaleDate,CONVERT(date,SaleDate)
FROM PortfolioProjects..NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(date,SaleDate)

-- Populate Property Address

SELECT *
FROM PortfolioProjects..NashvilleHousingData
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousingData a
JOIN PortfolioProjects..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousingData a
JOIN PortfolioProjects..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Breaking out addreess into Individual Columns

SELECT * 
FROM PortfolioProjects.dbo.NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProjects.dbo.NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1)


ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



-- Changing Y and N to Yes and No in SoldVacant Column

SELECT * 
FROM NashvilleHousingData


Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingData
group by SoldAsVacant
order by 2



Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousingData


UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END



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
					UniqueId
				) row_num

FROM NashvilleHousingData
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

Select *
From NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict



Select *
From NashvilleHousingData