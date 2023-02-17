/* 
Cleaning Data in SQL
*/

Select * 
From PortfolioProject..Nashville_Housing


--- Standerdize sales date

Select SaleDateConverted, CONVERT(date, SaleDate) 
From PortfolioProject..Nashville_Housing

Alter Table PortfolioProject..Nashville_Housing 
Add SaleDateConverted Date;

Update PortfolioProject..Nashville_Housing 
SET SaleDateConverted = CONVERT(date, SaleDate)


--- Populate property address

Select *
From PortfolioProject..Nashville_Housing
Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..Nashville_Housing a
Join PortfolioProject..Nashville_Housing b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
	

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..Nashville_Housing a
Join PortfolioProject..Nashville_Housing b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


---Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..Nashville_Housing
--- Where PropertyAddress is Null
---Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address   

From PortfolioProject..Nashville_Housing


Alter Table PortfolioProject..Nashville_Housing 
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject..Nashville_Housing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


Alter Table PortfolioProject..Nashville_Housing 
Add PropertySplitCity nvarchar(255);

Update PortfolioProject..Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select 
Parsename (Replace(OwnerAddress, ',','.'), 3)
,Parsename (Replace(OwnerAddress, ',','.'), 2)
,Parsename (Replace(OwnerAddress, ',','.'), 1)

From PortfolioProject..Nashville_Housing

Alter Table PortfolioProject..Nashville_Housing 
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject..Nashville_Housing 
SET OwnerSplitAddress = Parsename (Replace(OwnerAddress, ',','.'), 3)



Alter Table PortfolioProject..Nashville_Housing 
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject..Nashville_Housing
SET OwnerSplitCity = Parsename (Replace(OwnerAddress, ',','.'), 2)



Alter Table PortfolioProject..Nashville_Housing 
Add OwnerSplitState nvarchar(255);

Update PortfolioProject..Nashville_Housing
SET OwnerSplitState = Parsename (Replace(OwnerAddress, ',','.'), 1)



Select *
From PortfolioProject..Nashville_Housing


---Change Y and N to Yes and No in 'Sold as Vacant Field'

Select distinct (SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..Nashville_Housing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject..Nashville_Housing
---Group by SoldAsVacant

Update PortfolioProject..Nashville_Housing 
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End





--- Remove Duplicates

With RowNumCTE as (
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 Order by
					UniqueID
					) row_num
				 
	
From PortfolioProject..Nashville_Housing
---Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
---order by PropertyAddress



--------------------------------------------------------

---Delete Unused Columns

Select *
From PortfolioProject..Nashville_Housing

Alter Table PortfolioProject..Nashville_Housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..Nashville_Housing
Drop Column SaleDate