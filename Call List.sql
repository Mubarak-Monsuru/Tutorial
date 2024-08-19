SELECT *
FROM ['Call List']

--- Remove duplicate rows
WITH CTE_Duplicate AS
(SELECT *, ROW_NUMBER() OVER (PARTITION BY CustomerID, First_Name, Last_Name, Phone_Number, Address
								ORDER BY CustomerID) as row_num
FROM ['Call List']
)
DELETE FROM CTE_Duplicate
WHERE row_num > 1

--- Delete unecessary columns
ALTER TABLE ['Call List']
DROP COLUMN F9, F10

---Remove special characters from table
update ['Call List']
set Last_Name = MASTER.dbo.udfGetCharacters(Last_Name,'A-Z /')
where Last_Name != MASTER.dbo.udfGetCharacters(Last_Name,'A-Z /')

update ['Call List']
set Phone_Number =  MASTER.dbo.udfGetCharacters(Phone_Number,'0-9 /')
where Phone_Number !=  MASTER.dbo.udfGetCharacters(Phone_Number,'0-9 /')

begin tran

---Replace '/White' as 'White'
UPDATE ['Call List']
SET Last_Name = REPLACE(Last_Name, '/', '')

---Remove '/' and space between phone numbers
UPDATE ['Call List']
SET Phone_Number = REPLACE(Phone_Number, '/', '')

UPDATE ['Call List']
SET Phone_Number = REPLACE(Phone_Number, ' ', '')

---Set a standard format for phone numbers
UPDATE ['Call List']
SET Phone_Number=  STUFF(STUFF(Phone_Number, 4, 0, '-'), 9, 0, '-')
WHERE Phone_Number is not NULL

--- Separate Address into 3 columns
SELECT Address, PARSENAME(REPLACE(Address, ',', '.'), 3) Owner_Address,
	PARSENAME(REPLACE(Address, ',', '.'), 2) State,
	PARSENAME(REPLACE(Address, ',', '.'), 1) Zip_Code
FROM ['Call List']

ALTER TABLE ['Call List']
ADD Owner_Address nvarchar(200),
	Remaining_Address nvarchar(200)

UPDATE ['Call List']
SET
	Owner_Address = LEFT(Address, CHARINDEX(',', Address + ',') - 1),
	Remaining_Address = SUBSTRING(Address, CHARINDEX(',', Address + ',') + 1, LEN(Address))

ALTER TABLE ['Call List']
ADD State nvarchar(200),
	Zip_Code nvarchar(200)

Update ['Call List']
SET
	State = LEFT(Remaining_Address, CHARINDEX(',', Remaining_Address + ',') - 1),
    Zip_Code = SUBSTRING(Remaining_Address, CHARINDEX(',', Remaining_Address + ',') + 1, LEN(Remaining_Address))

ALTER TABLE ['Call List']
DROP COLUMN Remaining_Address, Address

UPDATE ['Call List']
SET [Paying Customer] = CASE
	WHEN [Paying Customer] = 'Y' THEN 'Yes'
	WHEN [Paying Customer] = 'N' THEN 'No'
	ELSE [Paying Customer]
END
FROM ['Call List']

UPDATE ['Call List']
SET [Do_Not_Contact] = CASE
	WHEN [Do_Not_Contact] = 'Y' THEN 'Yes'
	WHEN [Do_Not_Contact] = 'N' THEN 'No'
	ELSE [Do_Not_Contact]
END
FROM ['Call List']

SELECT *
FROM ['Call List']
