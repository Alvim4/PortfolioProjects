--Standardize Date Format

Select *
From ProjectPortfolio..NashvilleHousing

Select SaleDateConverted, CONVERT(Date, SaleDate)
From ProjectPortfolio..NashvilleHousing

Update ProjectPortfolio..NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table ProjectPortfolio..NashvilleHousing
Add SaleDateConverted date;

Update ProjectPortfolio..NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)



--Populate Property Address Data

Select *
From ProjectPortfolio..NashvilleHousing

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProjectPortfolio..NashvilleHousing a
Join ProjectPortfolio..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProjectPortfolio..NashvilleHousing a
Join ProjectPortfolio..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is NULL








--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) As City
From ProjectPortfolio..NashvilleHousing

Alter Table ProjectPortfolio..NashvilleHousing
Add Address nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table ProjectPortfolio..NashvilleHousing
Add City nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) As OwnerAddressUpdated,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) As OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) As OwnerState
From ProjectPortfolio..NashvilleHousing

Alter Table ProjectPortfolio..NashvilleHousing
Add OwnerAddressUpdated nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerAddressUpdated = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table ProjectPortfolio..NashvilleHousing
Add OwnerCity nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table ProjectPortfolio..NashvilleHousing
Add OwnerState nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From ProjectPortfolio..NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vanct" field

Select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From ProjectPortfolio..NashvilleHousing

Update ProjectPortfolio..NashvilleHousing
Set SoldAsVacant = CASE
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

Select Distinct(SoldAsVacant)
From ProjectPortfolio..NashvilleHousing



--Remove Duplicate

With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
			) row_num
From ProjectPortfolio..NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1




--Delete Unused Columns

Select *
From ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict