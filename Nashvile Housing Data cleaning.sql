select *
from PortfolioProject..NashvileHousing
 
 -- standardize data format

select SaleDate, convert(date,saledate)
from PortfolioProject..NashvileHousing

update NashvileHousing
set SaleDate = convert(date,saledate)

-- populate property address

select *
from PortfolioProject..NashvileHousing
where PropertyAddress is null


select *
from PortfolioProject..NashvileHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..NashvileHousing a
join PortfolioProject..NashvileHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..NashvileHousing a
join PortfolioProject..NashvileHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null


-- Breaking out address into individual columns (address, city, state)

select PropertyAddress
from PortfolioProject..NashvileHousing
order by ParcelID

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
,substring(PropertyAddress, charindex(',', PropertyAddress)+1,len(propertyaddress)) as Address
--charindex (',', PropertyAddress)
from PortfolioProject..NashvileHousing

alter table NashvileHousing
add PropertySplitAddress nvarchar(255);

update NashvileHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)


alter table NashvileHousing
add PropertyCityAddress nvarchar(255);

update NashvileHousing
set PropertyCityAddress = substring(PropertyAddress, charindex(',', PropertyAddress)+1,len(propertyaddress))


-- using parcename

select OwnerAddress
from NashvileHousing

select
PARSENAME(replace(owneraddress, ',','.'),3),
PARSENAME(replace(owneraddress, ',','.'),2),
PARSENAME(replace(owneraddress, ',','.'),1)
from NashvileHousing


alter table NashvileHousing
add street nvarchar(255);

update NashvileHousing
set street = PARSENAME(replace(owneraddress, ',','.'),3)

alter table NashvileHousing
add city nvarchar(255);

update NashvileHousing
set city = PARSENAME(replace(owneraddress, ',','.'),2) 

alter table NashvileHousing
add state nvarchar(255);

update NashvileHousing
set state = PARSENAME(replace(owneraddress, ',','.'),1)



--change y and n to yes and no in 'sold as vacant' column


select soldasvacant,count(soldasvacant)
from NashvileHousing 
where SoldAsVacant = 'y' 
or SoldAsVacant ='n'
group by SoldAsVacant

select distinct (soldasvacant),count(soldasvacant)
from NashvileHousing
group by (soldasvacant)

select SoldAsVacant,
case when SoldAsVacant = 'y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end
from NashvileHousing


update NashvileHousing
set soldasvacant = case when SoldAsVacant = 'y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end


-- Remove duplicates

with rownumCTE AS(
select *,
row_number() over 
( partition by parcelID,
Propertyaddress,
saledate,
saleprice
order by uniqueID
)row_num
from NashvileHousing
)
delete
from rownumCTE
where row_num > 1


-- Delete unused columns

select *
from NashvileHousing

alter table nashvilehousing
drop column propertyaddress, owneraddress, taxdistrict