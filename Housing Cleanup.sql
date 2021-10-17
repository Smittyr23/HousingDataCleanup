SELECT *
FROM HousingInfo..Housing

-- Remove time from SaleDate column

ALTER TABLE HousingInfo..Housing
ALTER COLUMN SaleDate date;

-- Populating Property Address data that is null by matching other records by matching ParcelID

SELECT * 
FROM HousingInfo..Housing
WHERE PropertyAddress is null

-- Query to make view correct property address in places it is currently null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM HousingInfo..Housing a
JOIN HousingInfo..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Query to fill in null values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingInfo..Housing a
JOIN HousingInfo..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingInfo..Housing a
JOIN HousingInfo..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking apart PropertyAddress into separate columns using SUBSTRING

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM HousingInfo..Housing

ALTER TABLE HousingInfo..Housing
Add PropertyCity Nvarchar(255)

UPDATE HousingInfo..Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

UPDATE HousingInfo..Housing
SET PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- Breaking apart OwnerAddress into separate columns using PARSE

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM HousingInfo..Housing

ALTER TABLE HousingInfo..Housing
Add NewOwnerAddress Nvarchar(255)

ALTER TABLE HousingInfo..Housing
Add OwnerCity Nvarchar(255)

ALTER TABLE HousingInfo..Housing
Add OwnerState Nvarchar(255)

UPDATE HousingInfo..Housing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE HousingInfo..Housing
SET OwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE HousingInfo..Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Changing Y and N to Yes and No in SoldAsVacant column

UPDATE HousingInfo..Housing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

SELECT DISTINCT(SoldAsVacant)
FROM HousingInfo..Housing
