SELECT * 
FROM Portfolio2..financial_loan

--Total Loan Applications
SELECT COUNT(DISTINCT id) AS Total_Loan_Application
FROM Portfolio2..financial_loan

--Total Applications for Dec 2021
SELECT COUNT(DISTINCT id) AS MTD_Total_Loan_Application
FROM Portfolio2..financial_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

----MoM Perecentage Application Increaase for 2021
WITH MTD AS (
    SELECT 
        MONTH(issue_date) AS Month, 
        COUNT(DISTINCT id) AS MTD_Total_Loan_Application,
        LAG(COUNT(DISTINCT id), 1) OVER (ORDER BY MONTH(issue_date)) AS Pmtd
    FROM Portfolio2..financial_loan
    WHERE YEAR(issue_date) = 2021
    GROUP BY MONTH(issue_date)
)
SELECT 
    Month, 
    MTD_Total_Loan_Application,
    Pmtd,
    (MTD_Total_Loan_Application - Pmtd) AS Difference,
    CASE 
        WHEN Pmtd IS NOT NULL AND Pmtd != 0 
        THEN ((MTD_Total_Loan_Application - Pmtd) * 1.0 / Pmtd) * 100 
        ELSE NULL 
    END AS MoMPercent
FROM MTD;

--Total Loan Amount
SELECT MONTH(issue_date) AS Month, SUM(loan_amount) AS MTD_Total_Funded_Amount
FROM Portfolio2..financial_loan
WHERE YEAR(issue_date) = 2021
GROUP BY MONTH(issue_date)
ORDER BY Month

----MoM Perecentage Funded Amount Increaase for 2021
WITH LATD AS (
    SELECT 
        MONTH(issue_date) AS Month, 
        SUM(loan_amount) AS MTD_Total_Funded_Amount,
        LAG(SUM(loan_amount), 1) OVER (ORDER BY MONTH(issue_date)) AS Pmtd
    FROM Portfolio2..financial_loan
    WHERE YEAR(issue_date) = 2021
    GROUP BY MONTH(issue_date)
)
SELECT 
    Month, 
    MTD_Total_Funded_Amount,
    Pmtd,
    (MTD_Total_Funded_Amount - Pmtd) AS Difference,
    CASE 
        WHEN Pmtd IS NOT NULL AND Pmtd != 0 
        THEN ((MTD_Total_Funded_Amount - Pmtd) * 1.0 / Pmtd) * 100 
        ELSE NULL 
    END AS MoM_Loan_Amount_Percent
FROM LATD;

--Total Amount of Payments Received
SELECT SUM(total_payment) AS Total_Amount_received
FROM Portfolio2..financial_loan

----MoM Perecentage Payments Received Increaase for 2021
WITH PRTD AS (
    SELECT 
        MONTH(issue_date) AS Month, 
        SUM(total_payment) AS Total_Amount_received,
        LAG(SUM(total_payment), 1) OVER (ORDER BY MONTH(issue_date)) AS Pmtd
    FROM Portfolio2..financial_loan
    WHERE YEAR(issue_date) = 2021
    GROUP BY MONTH(issue_date)
)
SELECT 
    Month, 
    Total_Amount_received,
    Pmtd,
    (Total_Amount_received - Pmtd) AS Difference,
    CASE 
        WHEN Pmtd IS NOT NULL AND Pmtd != 0 
        THEN ((Total_Amount_received - Pmtd) * 1.0 / Pmtd) * 100 
        ELSE NULL 
    END AS MoM_Payment_Received_Percent
FROM PRTD;


--Average Interest
SELECT ROUND(AVG(int_rate), 4) AS Avg_Interest_Rate
FROM Portfolio2..financial_loan

SELECT ROUND(AVG(int_rate), 4) AS MTD_Avg_Interest_Rate
FROM Portfolio2..financial_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

--Average Debt to Income Ratio
SELECT ROUND(AVG(dti), 4) AS Avg_DTI
FROM Portfolio2..financial_loan

SELECT ROUND(AVG(dti), 4) AS MTD_Avg_DTI
FROM Portfolio2..financial_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021

--Good Loan vs Bad Loan
WITH GBLP AS (
SELECT (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100)/COUNT(id) 
	AS Percent_Good_Loan_Applicants,
	COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) AS Total_Good_Loan_Applications,
	SUM(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN loan_amount END) AS Total_Good_Loan_Fund_Amount,
	SUM(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN total_payment END) AS Total_Good_Loan_Payment_Received,
	(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100)/COUNT(id) 
	AS Percent_Bad_Loan_Applicants,
	COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) AS Total_Bad_Loan_Applications,
	SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount END) AS Total_Bad_Loan_Fund_Amount,
	SUM(CASE WHEN loan_status = 'Charged Off' THEN total_payment END) AS Total_Bad_Loan_Payment_Received
FROM Portfolio2..financial_loan
)
SELECT * 
FROM GBLP

--Loan Status
SELECT loan_status, COUNT(id) AS Loan_Applications, 
		SUM(total_payment) AS Total_Amount_received,
		SUM(loan_amount) AS Total_funded_Amount,
		ROUND(AVG(int_rate), 4) AS Avg_Interest_Rate,
		ROUND(AVG(dti), 4) AS Avg_DTI
FROM Portfolio2..financial_loan
GROUP BY loan_status
ORDER BY loan_status

SELECT loan_status, COUNT(id) AS Loan_Applications, 
		SUM(total_payment) AS Total_Amount_received,
		SUM(loan_amount) AS Total_funded_Amount
FROM Portfolio2..financial_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021
GROUP BY loan_status
ORDER BY loan_status



--Information By Date
SELECT MONTH(issue_date) AS Monthnum, DATENAME(MONTH, issue_date) AS Month,
		COUNT(id) AS Loan_Applications, 
		SUM(total_payment) AS Total_Amount_received,
		SUM(loan_amount) AS Total_funded_Amount
FROM Portfolio2..financial_loan
GROUP BY DATENAME(MONTH, issue_date), MONTH(issue_date)
ORDER BY Monthnum


--Information By State
SELECT address_state,
		COUNT(id) AS Loan_Applications, 
		SUM(total_payment) AS Total_Amount_received,
		SUM(loan_amount) AS Total_funded_Amount
FROM Portfolio2..financial_loan
GROUP BY address_state
ORDER BY address_state


--Information By Term
SELECT term,
		COUNT(id) AS Loan_Applications, 
		SUM(total_payment) AS Total_Amount_received,
		SUM(loan_amount) AS Total_funded_Amount
FROM Portfolio2..financial_loan
GROUP BY term
ORDER BY term


--Information By Length of Employment
SELECT emp_length,
		COUNT(id) AS Loan_Applications, 
		SUM(total_payment) AS Total_Amount_received,
		SUM(loan_amount) AS Total_funded_Amount
FROM Portfolio2..financial_loan
GROUP BY emp_length
ORDER BY emp_length


--Information By Purpose
SELECT purpose,
		COUNT(id) AS Loan_Applications, 
		SUM(total_payment) AS Total_Amount_received,
		SUM(loan_amount) AS Total_funded_Amount
FROM Portfolio2..financial_loan
GROUP BY purpose
ORDER BY purpose


--Information By Home Ownership
SELECT home_ownership,
		COUNT(id) AS Loan_Applications, 
		SUM(total_payment) AS Total_Amount_received,
		SUM(loan_amount) AS Total_funded_Amount
FROM Portfolio2..financial_loan
GROUP BY home_ownership
ORDER BY home_ownership
