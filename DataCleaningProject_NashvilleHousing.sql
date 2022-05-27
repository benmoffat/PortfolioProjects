-- Cleaning Data with SQL Queries Project
-- Dataset: Nashville Housing Data

Select *
From PortfolioProject2..NashvilleHousing

-- 1) Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted  = convert(date, SaleDate)

-- 2) Populate Missing Property Address Data

Select *
From PortfolioProject2..NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject2..NashvilleHousing a
Join PortfolioProject2..NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject2..NashvilleHousing a
Join PortfolioProject2..NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

-- 3) Separate property address into two columns (address, city)
--    Using substring

Select PropertyAddress
From PortfolioProject2..NashvilleHousing

Select 
Substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
Substring(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject2..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitCity  = Substring(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Separate owner address into three columns (address, city, state)
-- Using parsename

Select
Parsename(replace(OwnerAddress,',','.') ,3) as Address
,Parsename(replace(OwnerAddress,',','.') ,2) as City
,Parsename(replace(OwnerAddress,',','.') ,1) as State
From PortfolioProject2..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(replace(OwnerAddress,',','.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitCity  = Parsename(replace(OwnerAddress,',','.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(replace(OwnerAddress,',','.') ,1)

Select *
From NashvilleHousing

-- 4) Change 'y' and 'n' to match 'Yes' and 'No' in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldasVacant
, CASE when SoldasVacant = 'y' then 'yes'
       when SoldasVacant = 'n' then 'no' 
	   else SoldasVacant
	   END
From PortfolioProject2..NashvilleHousing

Update NashvilleHousing
Set SoldasVacant = CASE when SoldasVacant = 'y' then 'yes'
       when SoldasVacant = 'n' then 'no' 
	   else SoldasVacant
	   END

-- 5)  Remove duplicates 

WITH RowNumCTE as(
Select *,
	row_number() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
					) row_num
From Portfolioproject2..NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1

-- 6) Delete unused columns

Alter table PortfolioProject2..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- Final cleaned data

Select *
From PortfolioProject2..NashvilleHousing















