SELECT LastU
FROM [El Paso County]

SELECT [Property Street Address], LOCATION
FROM [Sky Data] sky
JOIN [El Paso County] epc
	ON sky.[Property Street Address] = epc.LOCATION 