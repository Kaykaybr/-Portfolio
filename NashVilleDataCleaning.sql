SELECT *
FROM PortfolioProject..NashVilleHousing



--Standardize Date
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashVilleHousing

ALTER TABLE NashVilleHousing
Add SaleDateConverted Date;

Update NashVilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


--Populate PropertyAddress
SELECT *
FROM PortfolioProject..NashVilleHousing
WHERE PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashVilleHousing AS a
JOIN PortfolioProject..NashVilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashVilleHousing AS a
JOIN PortfolioProject..NashVilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



--Separate PropertyAddress into Address, City

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashVilleHousing

ALTER TABLE NashVilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing
Add PropertySplitCity Nvarchar(200);

Update NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Split OwnerAddress into Address, City, State
SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
	   PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
	   PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject..NashVilleHousing

ALTER TABLE NashVilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashVilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashVilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



--Change Y, N to Yes and No in SoldAsVacant
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject..NashVilleHousing

Update NashVilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashVilleHousing
GROUP BY SoldAsVacant



--Remove Duplicates
WITH RowNum As(
	SELECT *,
		ROW_NUMBER() OVER 
		(
			PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
			ORDER BY UniqueID
		) AS row_num
	FROM PortfolioProject..NashVilleHousing
)
SELECT *
FROM RowNum
WHERE row_num > 1



--Delete Unused Columns

ALTER TABLE PortfolioProject..NashVilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate