SELECT ["mailingAddr1"], ["mailingAddr2"], TRIM(CONCAT(StrNum, ' ', StrPfx, ' ', Street, ' ', StrSfx)) PropertyAddress
FROM [Boulder County] bold

--- To replace values with quotations with no quotations
SELECT ["str_num"], REPLACE(["str_num"], '"', ''), ["str"], REPLACE(["str"], '"', ''), ["str_pfx"], REPLACE(["str_pfx"], '"', ''),
		["str_sfx"], REPLACE(["str_sfx"], '"', ''), ["str_unit"], REPLACE(["str_unit"], '"', ''),
		["city"], REPLACE(["city"], '"', ''), ["owner_name"], REPLACE(["owner_name"], '"', ''),
		["mailingZip"], REPLACE(["mailingZip"], '"', ''), ["mailingCity"], REPLACE(["mailingCity"], '"', '')
FROM [Boulder County]

ALTER TABLE [Boulder County]
ADD PropertyAddress nvarchar(255)

CreatedDate, str_num, str_pfx, str, str_sfx, str_unit, city, owner_name, mailingZip, mailingCity

--- To remove extra  spaces.
UPDATE [Boulder County]
SET PropertyAddress = REPLACE(PropertyAddress, '  ', ' ')

SELECT CreatedDate, StrNum, StrPfx, Street, StrSfx, City, MailingAddress1, MailingAddress2, OwnerName, MailingZip, MailingCity, PropertyAddress
FROM [Boulder County]

SELECT PropertyAddress
FROM [Boulder County]