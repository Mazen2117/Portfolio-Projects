



-- Standardize Date Format

SELECT saleDate , convert (Date,SaleDate) 
FROM  PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;


Update PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted = convert (Date,SaleDate)


-- Populate Property Address data

SELECT *
FROM  PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM  PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	Where a.PropertyAddress is null


	
UPDATE a 
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM  PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	Where a.PropertyAddress is null


	-- Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM  PortfolioProject.dbo.NashvilleHousing


Select SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM  PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )




ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) --ForAddress 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) --ForCity
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) --ForState
From PortfolioProject.dbo.NashvilleHousing
--هي ماشية 3-2-1 مش العكس
--(للتوضيح)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field



Select Distinct (SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2
  

Select SoldAsVacant
,CASE When SoldAsVacant='Y' Then 'Yes'
	  When SoldAsVacant='N' Then 'No'
Else SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing

 Update PortfolioProject.dbo.NashvilleHousing
 Set SoldAsVacant = CASE When SoldAsVacant='Y' Then 'Yes'
	  When SoldAsVacant='N' Then 'No'
Else SoldAsVacant
END




-- Remove Duplicates



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
)
Select *
From RowNumCTE
--Where row_num > 1
Order by PropertyAddress




-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

