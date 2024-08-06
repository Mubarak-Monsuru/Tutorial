ALTER TABLE Sky_Data
ADD [Full Name] AS (CONCAT([First Name], ' ', [Last Name]));


UPDATE Sky_Data
SET Sky_Data.[Property 1 City] = ['Adams County'].LOCCITY
FROM Sky_Data
JOIN ['Adams County']
	ON Sky_Data.[Property Street Address] = ['Adams County'].[Property Street Address]
WHERE Sky_Data.[Property 1 City] <> ['Adams County'].LOCCITY

SELECT sky.[Full Name], adams.OWNERNAMEFULL, sky.[Property Street Address],
	adams.[Property Street Address], sky.[Property 1 City], adams.LOCCITY, sky.County
FROM Sky_Data sky
JOIN ['Adams County'] adams
	ON sky.[Property Street Address] = adams.[Property Street Address]

SELECT sky.[Property Street Address], denv.SITUS_ADDRESS_LINE1, denv.OWNER_ADDRESS_LINE1
FROM Denver denv
JOIN Sky_Data sky
	ON denv.OWNER_ADDRESS_LINE1 = sky.[Property Street Address]
WHERE sky.[Property Street Address] = '2121 E 18TH AVE'

SELECT sky.[Full Name], denv.OWNER_NAME, sky.County, sky.[Property 1 City], denv.SITUS_CITY,
			sky.[Property Street Address], denv.SITUS_ADDRESS_LINE1, denv.OWNER_ADDRESS_LINE1
FROM Sky_Data sky
JOIN [Denver County] denv
	ON sky.[Property Street Address] = denv.SITUS_ADDRESS_LINE1

SELECT *
FROM [Denver County]

SELECT *, ROW_NUMBER() OVER (PARTITION BY BLKNUM, PARCELNUM, PARCEL_SOURCE, SYSTEM_START_DATE, OWNER_NAME, OWNER_ADDRESS_LINE1, SITUS_ADDRESS_LINE1,
											OWNER_CITY, OWNER_STATE, SITUS_STATE, SITUS_CITY
											ORDER BY SCHEDNUM) row_num
FROM [Denver County]

WITH DENVERCTE AS
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY OWNER_NAME, OWNER_ADDRESS_LINE1, SITUS_ADDRESS_LINE1,
											SITUS_STATE, SITUS_CITY
											ORDER BY SCHEDNUM) row_num
FROM [Denver County]
)
SELECT *
FROM DENVERCTE
WHERE OWNER_ADDRESS_LINE1 = '5840 E EVANS AVE'

SELECT [Property 1 City], County, COUNT([Property 1 City]) Entries
FROM [Sky Data]
GROUP BY [Property 1 City], County
ORDER BY County

SELECT sky.[First Name], sky.[Last Name], adams.OWNERNAMEFULL, sky.[Property Street Address],
			adams.CONCATADDR1, sky.[Property 1 City], adams.LOCCITY, sky.County
FROM [Sky Data] sky
JOIN ['Adams County'] adams
	ON sky.[Property Street Address] = adams.[Property Street Address]

UPDATE [Sky Data]
SET [Sky Data].[Property 1 City] = ['Adams County'].LOCCITY
FROM [Sky Data]
JOIN ['Adams County']
	ON [Sky Data].[Property 1 City] = ['Adams County'].[Property Street Address]
WHERE [Sky Data].[Property 1 City] <> ['Adams County'].LOCCITY

SELECT STREETNAME, LOCCITY, LOCZIP, [Property Street Address], OWNERNAMEFULL, CONCATADDR2, OWNERADDRESS, created_date, last_edited_date
FROM ['Adams County']
WHERE created_date is not NULL

SELECT created_date, last_edited_date, CONVERT(DateTime, created_date), CONVERT(DateTime, last_edited_date)
FROM ['Adams County']
WHERE created_date is not NULL

ALTER TABLE ['Adams County']
ADD CONCATADDR1 nvarchar(255),
	CREATEDDATE Datetime,
	LASTDATEEDITED Datetime;

UPDATE ['Adams County']
SET CONCATADDR1 = [Property Street Address],
	CREATEDDATE = CONVERT(DateTime, created_date),
	LASTDATEEDITED = CONVERT(DateTime, last_edited_date)

SELECT STREETNAME, LOCCITY, LOCZIP, CONCATADDR1, OWNERNAMEFULL, OWNERADDRESS, CREATEDDATE, LASTDATEEDITED
FROM ['Adams County']
WHERE created_date is not NULL
ORDER BY LASTDATEEDITED DESC

SELECT PARCELNUM, PARCEL_SOURCE, SYSTEM_START_DATE, OWNER_NAME, OWNER_ADDRESS_LINE1, SITUS_ADDRESS_LINE1,
											OWNER_CITY, OWNER_STATE, SITUS_STATE, SITUS_CITY, SALE_DATE
FROM [Denver County]
WHERE SALE_DATE != 'None'
ORDER BY SALE_DATE DESC

SELECT sky.[First Name], sky.[Last Name], ara.CurOwnerName, ara.OwnerList, sky.[Property Street Address],
			ara.SAFreeFormAddr, sky.[Property 1 City], ara.SACity, sky.County
FROM [Sky Data] sky
JOIN Arapahoe ara
	ON sky.[Property Street Address] = ara.SAFreeFormAddr

SELECT TaxYear, AssessmentYear, LegalDescr, TaxRollDescr, TaxYear, SACity, SAFreeFormAddr, SAPostalCd, CurOwnerName, CurCountry, CurDeliveryAddr, OwnerList
FROM Arapahoe

SELECT CreatedDate, StrNum, StrPfx, Street, StrSfx, City, OwnerName, MailingZip, MailingCity, PropertyAddress
FROM [Boulder County]

SELECT sky.[First Name], sky.[Last Name], bc.OwnerName, sky.[Property Street Address], bc.PropertyAddress,
		sky.[Property 1 City], bc.City
FROM [Sky Data] sky
JOIN [Boulder County] bc
	ON sky.[Property Street Address] = bc.PropertyAddress OR
		sky.[Property Street Address] = bc.MailingAddress1

SELECT TOP 5 SITUS, CONCAT(STREETNO, ' ', STREETDIR, ' ', STREETNAME, ' ', STREETSUF)
FROM [Weld County]

SELECT SIT_ADDRESS
FROM [Weld County]
WHERE SIT_ADDRESS LIKE '%2922%'

ALTER TABLE [Weld County]
ADD SIT_ADDRESS nvarchar(255)

UPDATE [Weld County]
SET SIT_ADDRESS = REPLACE(SIT_ADDRESS, '  ', ' ')

SELECT PARCEL, NAME, ADDRESS1, ADDRESS2, CITY, LOCCITY, STREETNO, STREETDIR, STREETNAME,
			STREETSUF, STATE, SIT_ADDRESS, ZIPCODE
FROM [Weld County]

SELECT sky.[First Name], sky.[Last Name], wc.NAME, sky.[Property 1 City], wc.LOCCITY,
			sky.[Property Street Address], wc.SIT_ADDRESS, sky.County
FROM [Sky Data] sky
JOIN [Weld County] wc
	ON sky.[Property Street Address] = wc.SIT_ADDRESS

SELECT OBJECTID, PARCEL_NUM, OWNER, LOCATION, SITUS_CITY, SITUS_STATE, MAILING,
		MAILING_CITY, MAILING_ST
FROM [Mesa County]

SELECT sky.[First Name], sky.[Last Name], mc.OWNER, sky.[Property Street Address], mc.LOCATION,
		sky.[Property 1 City], mc.SITUS_CITY, sky.County
FROM [Sky Data] sky
JOIN [Mesa County] mc
	ON sky.[Property Street Address] = mc.LOCATION

SELECT *
FROM [Larimer County]
WHERE FULLADDRES LIKE '%TIMBERLINE RD%' OR
		OWNER_ADDRESS_LINE1 LIKE '%1375 E 20TH AVE%'

SELECT sky.[Property Street Address], epc.LOCATION, sky.[Property 1 City], epc.CmntyArea, sky.County,
		sky.[Property 1 City], epc.MAILCITY
FROM [Sky Data] sky
JOIN [El Paso County] epc
	ON sky.[Property Street Address]= epc.LOCATION
WHERE sky.County = 'El Paso County'
AND sky.[Property Street Address] <> epc.LOCATION;
