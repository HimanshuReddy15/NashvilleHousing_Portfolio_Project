
-- Standardize Date Format

Select SaleDate
from NashvileHousing

Update NashvileHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter table NashvileHousing
Add SaleDateConverted Date;

Update NashvileHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate the Property Address

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvileHousing a
JOIN NashvileHousing b
	On a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set  PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvileHousing a
JOIN NashvileHousing b
	On a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking the address into Address,City,State 

Select PropertyAddress,
Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1),
Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress))
From NashvileHousing

Alter table NashvileHousing
Add PropertySplitAddress nvarchar(255);

Update NashvileHousing
Set PropertySplitAddress=Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1);

Alter table NashvileHousing
Add PropertySplitCity nvarchar(255);

Update NashvileHousing
Set PropertySplitCity = Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress))

-- Spliting the Owner's Address
-- Testing Parsename
 Select Acreage, Parsename(Acreage,1)
 from NashvileHousing

Select OwnerAddress,
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
From NashvileHousing

Alter table NashvileHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvileHousing
Set  OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3);

Alter table NashvileHousing
Add OwnerSplitCity nvarchar(255);

Update NashvileHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2);

Alter table NashvileHousing
Add OwnerSplitState nvarchar(255);

Update NashvileHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1);


-- Changing Y and N to Yes and No

Select SoldAsVacant,
CASE
	WHEN SoldAsVacant='N' Then 'No'
	WHEN SoldAsVacant='Y' Then 'Yes'
	Else SoldAsVacant
END
from NashvileHousing

Update NashvileHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant='N' Then 'No'
	WHEN SoldAsVacant='Y' Then 'Yes'
	Else SoldAsVacant
END

Select distinct(SoldAsVacant)
from NashvileHousing

-- Remove Duplicates

With RowNumCTE AS(
Select * ,
			ROW_NUMBER() OVER(
			PARTITION BY ParcelID,PropertyAddress,
			SalePrice,SaleDate,LegalReference
			ORDER BY
				UniqueID
				) row_num
From NashvileHousing
)
Select *
From RowNumCTE
where row_num>1
--Order BY PropertyAddress

-- Delete Unused columns

 

Alter table NashvileHousing
Drop Column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict


Select ROW_NUMBER() Over(Partition By [UniqueID] Order By ) row_num from NashvileHousing