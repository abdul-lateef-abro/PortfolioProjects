

-- CLEANING DATA WITH SQL QUERIES
--VIEW DATASET
Select *
From PortfolioProject..NashvilleHousingData



--Standardize sale date
Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousingData

UPDATE PortfolioProject..NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER table NashvilleHousingData
Add SaleDateConverted Date

UPDATE PortfolioProject..NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)


-------------------------------------------------------------------------------
-- Populate Property Address Data

Select *
from PortfolioProject..NashvilleHousingData
--where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, a.parcelID, b. PropertyAddress, ISNULL(a.PropertyAddress, B.PropertyAddress) --if A.PropertyAddress is null populate with B.Property Address
from PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, B.PropertyAddress)
from PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL



------------------------------------------------------------------------
--Breaking out Addresses into separate Columns i.e. Address, City, State


--for property address
Select *
from PortfolioProject..NashvilleHousingData

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

From PortfolioProject..NashvilleHousingData



ALTER table NashvilleHousingData
Add PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER table NashvilleHousingData
Add PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select * from PortfolioProject..NashvilleHousingData






-- for owner address

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as OwnerSplitAddress
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as OwnerSplitCity
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as OwnerSplitState
From PortfolioProject..NashvilleHousingData


ALTER table NashvilleHousingData
Add OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER table NashvilleHousingData
Add OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER table NashvilleHousingData
Add OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)







---------------------------------------------------------------------
--Change Y and N to Yes and No in SoldAsVacant

--check unique/distinct Y's and N's and Yes's and No's
Select 
Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousingData
group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashvilleHousingData



Update NashvilleHousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

---------------------------------------------------
-- Remove Duplicates

with RowNumCTE as(
	Select *,
	ROW_NUMBER() over(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by UniqueId
				)row_num

		from PortfolioProject..NashvilleHousingData
) 
--DELETE from RowNumCTE
Select * from RowNumCTE
where row_num >1
--order by PropertyAddress




---------------------------------------------------
-- Delete Unused Columns

Select * 
From PortfolioProject..NashvilleHousingData


Alter table PortfolioProject..NashvilleHousingData
Drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

