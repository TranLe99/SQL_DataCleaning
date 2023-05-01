/*
Cleaning Data in SQL Queries
*/

Select * From Data_Cleaning.dbo.NashvilleHousing


/*Standardized Date Format
--By adding a column to the table called "SaleDateConverted" with the new date format. 
Removing the old SaleDate Column
*/

Select SaleDateConverted, CONVERT(date,SaleDate)
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate);

Alter Table NashvilleHousing
Drop Column SaleDate;


---------------------------------------------------------------------------------------------------------------------------------------------
/*Populate property Address Data
Using a Self Join to fill in null values in the property address with similar ParcelID
Using Isnull to fill in the Null Values within Property address
Then looping back into the Select statement to ensure that there are no more null values 
*/


Select *
From NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing as a
Join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing as a
Join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------------------------------
/*
Breaking out Address into Individual Columns (address, city, state)
On the PropertyAddress, by using Substrings and Charindex, split the address into address and city
Create new collumns for the new data set
*/

Select * from NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress)) as City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1);


Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress));




---------------------------------------------------------------------------------------------------------------------------------------------
/*
Breaking out Owners Address into Individual Columns (address, city, state)
This time using ParseName
Since ParseName takes in '.' instead of commas, use Replace to switch commas into periods.
Create new collumns for the new data set
*/


Select 
PARSENAME(Replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(Replace(OwnerAddress,',','.'),2) as City,
PARSENAME(Replace(OwnerAddress,',','.'),1) as State
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3);


Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2);

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1);



---------------------------------------------------------------------------------------------------------------------------------------------
/*
Change Y and N to Yes and NO in "Sold As Vacant"
using A case Statement to change Y to Yes and N to NO
*/

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End



	---------------------------------------------------------------------------------------------------------------------------------------------
/*
Removing Duplicates
*/

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 Order By
					UniqueID
					) row_num

From NashvilleHousing
)

Select *
From RowNumCTE
Where row_num >1
Order by PropertyAddress


--End
	--------------------------------------------------------------------------------------------------------------------------------------------