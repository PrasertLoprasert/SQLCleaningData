/*
	Cleaning Data in SQL Queries
*/

select *
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------


-- Standardize Date Format

select 
	SaleDate, 
	convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing;

update NashvilleHousing   --This code not work
set SaleDate = convert(date,SaleDate);

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing;

-----------------------------------------------------------------------


-- Populate Property Address Data

-- See the Null value
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null;

select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null;

-- See the same value (or duplicate value)
select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

-- Fill the Null value
select 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

-- Update data table
Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

-- check PropertyAddress
select *
from PortfolioProject.dbo.NashvilleHousing 
where PropertyAddress is null;

-----------------------------------------------------------------------------------------------------


-- Breaking out address into individual columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing 

-- Sepparate the Address 1
select 
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
from PortfolioProject.dbo.NashvilleHousing ;

-- Sepparate the Address 2
select 
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing ;

-- Add and Update new data table
alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

select *
from NashvilleHousing;

-- Sepparate the OwnerAddress 
select OwnerAddress
from NashvilleHousing;

select 
	PARSENAME(replace(OwnerAddress, ',', '.'), 3),
	PARSENAME(replace(OwnerAddress, ',', '.'), 2),
	PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing;

-- Add and Update new data table about OwnerAddress
alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3);

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2);

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1);

select *
from NashvilleHousing;


----------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in " Sold as Vacant " field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing 
group by SoldAsVacant
order by 2;

select 
	SoldAsVacant,
	case	when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end
from PortfolioProject.dbo.NashvilleHousing ;


update NashvilleHousing
set SoldAsVacant = 
		case	when SoldAsVacant = 'Y' then 'Yes'
				when SoldAsVacant = 'N' then 'No'
				else SoldAsVacant
				end

-- Check the update
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing 
group by SoldAsVacant
order by 2;

----------------------------------------------------------------------------------------------


-- Remove Duplicates

select *
from PortfolioProject.dbo.NashvilleHousing ;

select *,
	ROW_NUMBER() over(
	partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing 
order by ParcelID;


-- Create CTE(common table expression) for seeking the duplicate row

with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
--where PropertyAddress = '3009  SKYVALLEY GRV, NASHVILLE'
order by PropertyAddress;


-- Delete the duplicate row
with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1
--where PropertyAddress = '3009  SKYVALLEY GRV, NASHVILLE'
--order by PropertyAddress;


-- Checking the duplicate row deleted or not	

with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
--where PropertyAddress = '3009  SKYVALLEY GRV, NASHVILLE'
order by PropertyAddress;


----------------------------------------------------------------------------------------------------


-- Delete unused columns

select *
from PortfolioProject.dbo.NashvilleHousing 


-- Delete unused columns
alter table PortfolioProject.dbo.NashvilleHousing 
drop column OwnerAddress, TaxDistrict, PropertyAddress

-- Checking result
select *
from PortfolioProject.dbo.NashvilleHousing 

-- Delete SaleDate
alter table PortfolioProject.dbo.NashvilleHousing 
drop column SaleDate