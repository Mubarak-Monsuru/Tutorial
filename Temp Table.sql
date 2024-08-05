DROP TABLE IF EXISTS #Temp_Employee2
CREATE TABLE #Temp_Employee2
(JobTitle varchar(50),
EmployeePerJob int,
AvgAge int,
AvgSalary int
)

INSERT INTO #Temp_Employee2
SELECT JobTitle, COUNT(JobTitle) No, AVG(Age) Avg_age, AVG(Salary) Avg_Salary
FROM EmployeeDemographics
JOIN EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitle

SELECT *
FROM #Temp_Employee2