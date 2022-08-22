-- HOUSING PROJECT

SELECT *
FROM [dbo].[housingss]

--STANDARDIZED DATE FORMAT

SELECT SaleDate
FROM [dbo].[housingss]

--to separate the date from the time, use the convert or cast formula

select Saledate, cast(Saledate as date) 
from [dbo].[housingss]

select SaleDate , convert(date,SaleDate)
from [dbo].[housingss]

-- update into the database, you can use the update or alter 
update [dbo].[housingss]
set Saledate = cast(SaleDate as date) 

alter table[dbo].[housingss]
add Saledateconvert date

update [dbo].[housingss]
set Saledateconvert = cast(SaleDate as date)

select Saledateconvert
from [dbo].[housingss]


--POPULATE PROPERTY ADDRESS

select *
from [dbo].[housingss]
where  propertyAddress is null
order by ParcelID

-- the property address and parcel id are related, the parcelid usually correlate with the address, so we can use that to populate the missing address


select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress
from [dbo].[housingss] a
	join [dbo].[housingss] b on a.ParcelID = b.ParcelID
	and a.[UniqueID ]!= b.[UniqueID ]
where a.PropertyAddress is null

--use isnull to populate the table, this means if (a) is null fill it with (b)


select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress) 
from [dbo].[housingss] a
	join [dbo].[housingss] b on a.ParcelID = b.ParcelID
	and a.[UniqueID ]!= b.[UniqueID ]
where a.PropertyAddress is null

--then we update, anytime we use update with join, we dont write the data name

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress) 
from [dbo].[housingss] a
	join [dbo].[housingss] b on a.ParcelID = b.ParcelID
	and a.[UniqueID ]!= b.[UniqueID ]
where a.PropertyAddress is null


-- BREAK OUT ADDRESS, CITY AND STATE

select propertyAddress
from [dbo].[housingss]

--TO breakdown the address we can use either the string or left function)

--use the substring function

select 
substring (PropertyAddress, 1, charindex (',', PropertyAddress) - 1) as address,
right(PropertyAddress,len(PropertyAddress)-charindex(',',propertyAddress)) as city
from [dbo].[housingss]

--or use the left function
select 
left(PropertyAddress, charindex(',',PropertyAddress)) as address
from [dbo].[housingss]


--to get the city we can use the substring or right function

Select 
substring(PropertyAddress,charindex(',', propertyAddress) +1,len(propertyAddress)) as city
from [dbo].[housingss]

select 
right(PropertyAddress, len(PropertyAddress)- charindex(',',PropertyAddress)) as city
from[dbo].[housingss]


--
select 
substring (PropertyAddress,1,charindex(',',PropertyAddress)) as address,
substring(PropertyAddress, Charindex(',',PropertyAddress) +1,Len(PropertyAddress)) as city
from [dbo].[housingss]

-- or
select
left (PropertyAddress, charindex(',',PropertyAddress)) as Address,
right(PropertyAddress, len(PropertyAddress)- charindex(',',PropertyAddress)) as city
from [dbo].[housingss]


Alter table [dbo].[housingss]
Add PropertysplitAddress nvarchar(255)

update [dbo].[housingss]
set PropertysplitAddress = left (PropertyAddress, charindex(',',PropertyAddress))

Alter table [dbo].[housingss]
Add Propertysplitcity  nvarchar(255)

update [dbo].[housingss]
set Propertysplitcity  = right(PropertyAddress, len(PropertyAddress)- charindex(',',PropertyAddress))

select *
from [dbo].[housingss]

-- OR we can the paresename replace formula
select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2)as city,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as state
from[dbo].[housingss]

alter table [dbo].[housingss]
add ownersplitaddress nvarchar (255)

update[dbo].[housingss]
set ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table [dbo].[housingss]
add ownersplitcity nvarchar (255)

update [dbo].[housingss]
set ownersplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table[dbo].[housingss]
add ownersplitstate nvarchar(255)

update [dbo].[housingss]
set ownersplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1 )


SELECT *
from[dbo].[housingss]


--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

select soldasvacant
from [dbo].[housingss]

select distinct soldasvacant
from [dbo].[housingss]

select distinct (SoldAsVacant), count(soldasvacant)
from [dbo].[housingss]
group by SoldAsVacant
order by 2

--USING THE CASE FORMULA

select soldasvacant,
case
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from [dbo].[housingss]

update [dbo].[housingss]
set soldasvacant = 
case
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from [dbo].[housingss]


--REMOVE DUPLICATES

with rownumberCTE AS (
Select *,
	ROW_NUMBER() over (
	partition by parcelid,
				 Propertyaddress,
				 Saleprice,
				 Saledate,
				 legalreference
				 order by
					uniqueid
					) row_num
from[dbo].[housingss])
select *
from rownumberCTE 
where row_num > 1
order by propertyAddress

with rownumberCTE AS (
Select *,
	ROW_NUMBER() over (
	partition by parcelid,
				 Propertyaddress,
				 Saleprice,
				 Saledate,
				 legalreference
				 order by
					uniqueid
					) row_num
from[dbo].[housingss])
DELETE 
from rownumberCTE 
where row_num > 1
--order by propertyAddress


--DELETE UNUSED COLUMN

select *
from [dbo].[housingss]

alter table[dbo].[housingss]
drop column Owneraddress, Saledate
