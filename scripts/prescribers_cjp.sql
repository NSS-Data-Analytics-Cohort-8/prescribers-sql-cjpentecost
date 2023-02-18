SELECT *
from prescription
ORDER BY total_drug_cost DESC;

SELECT *
FROM prescriber;

SELECT *
FROM drug;
--WHERE drug_name = 'ESBRIET';

SELECT *
FROM fips_county;

SELECT *
FROM cbsa;

SELECT *
FROM population;
-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, npi, SUM(total_claim_count) AS sum_totalclaims
FROM prescriber
INNER JOIN prescription
USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name
ORDER BY sum_totalclaims DESC;

--Bruce Pendley NPI 1881634483, total claim count is 99707


-- 	 b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS sum_totalclaims
FROM prescriber
INNER JOIN prescription
USING (npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY sum_totalclaims DESC;

--Bruce Pendley NPI 1881634483, total claim count is 99707

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, SUM(total_claim_count) AS sum_totalclaims
FROM prescriber
LEFT JOIN prescription
USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY sum_totalclaims DESC;
--Family Practice : 9,752,347

--     b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, COUNT(opioid_drug_flag) AS opioid_rx, SUM(total_claim_count) AS sum_totalclaims
FROM prescriber
LEFT JOIN prescription
USING (npi)
LEFT JOIN drug
USING (drug_name)
WHERE total_claim_count IS NOT NULL 
AND opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY opioid_rx DESC;
--Nurse Practitioner (900,845 total claim count)

-- Looking for a count of both opioid columns and result was 29 for both
-- SELECT COUNT(opioid_drug_flag) AS opioid_1, COUNT(long_acting_opioid_drug_flag) AS opioid_2
-- FROM drug
-- WHERE opioid_drug_flag = 'Y' 
-- AND long_acting_opioid_drug_flag = 'Y';

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT specialty_description, drug_name, SUM(total_claim_count) AS sum_totalclaims
FROM prescriber
LEFT JOIN prescription
USING (npi)
LEFT JOIN drug
USING (drug_name) 
WHERE drug_name IS NULL
GROUP BY specialty_description, drug_name;
--Yes, running the above syntax shows 92 specialties without a drug name 
--changed to full join and still got 92 specialties↓
--SELECT specialty_description, drug_name, SUM(total_claim_count) AS sum_totalclaims
-- FROM prescriber
-- FULL JOIN prescription
-- USING (npi)
-- FULL JOIN drug
-- USING (drug_name) 
-- WHERE drug_name IS NULL
-- GROUP BY specialty_description, drug_name;

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT drug_name, generic_name, total_drug_cost
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_drug_cost IS NOT NULL
ORDER BY total_drug_cost DESC;
--Pirfenidone (2829174.30)

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT DISTINCT(generic_name), ROUND(total_day_supply,2) AS round_totdaysup
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_drug_cost IS NOT NULL
ORDER BY round_totdaysup DESC;
--Levothyroxine sodium $115546.00 - not sure why i cannot get rid of dup values

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name, opioid_drug_flag, antibiotic_drug_flag
FROM drug
WHERE opioid_drug_flag = 'Y' OR antibiotic_drug_flag = 'Y';

-- SELECT drug_name, opioid_drug_flag, antibiotic_drug_flag
-- 	CASE WHEN opioid_drug_flag 'Y' AND antibiotic_drug_flag 'N' THEN "opioid"
-- 	WHEN antibiotic_drug_flag 'Y' AND opioid_drug_flag 'N' THEN "antibiotic"
-- 	ELSE "other" END AS drug_total
-- FROM drug;
	
--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
	
-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT state, COUNT(cbsa) AS count_cbsa
FROM cbsa
LEFT JOIN fips_county
USING (fipscounty)
WHERE state = 'TN'
GROUP BY state;
-->42 CBSA in TN

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, MAX(population),MIN(population)
FROM cbsa
INNER JOIN population
USING (fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY MIN(population) ASC, MAX(population) DESC;
--Largest Nashville-Davidson-Mboro-Franklin TN 678322 , Smallest, same name -8773
 --i am pretty sure this can't be correct.

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT population, county, state, cbsa 
FROM cbsa
FULL JOIN fips_county
USING (fipscounty)
FULL JOIN population
USING (fipscounty)
WHERE population IS NOT NULL
AND cbsa IS NULL 
ORDER BY population DESC;
--Sevier County, population 95523

--6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, SUM(total_claim_count) AS sum_totalclms
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000
GROUP BY drug_name
ORDER BY sum_totalclms ASC;
--Furosemide (3083), Mirtazapine (3085), Hydrocodone-acetaminophen (3376), Gabapentin (3531), Lisinopril (3655), Oxycodone (4538), Levothyrozine sodium (9262)


--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, SUM(total_claim_count) AS sum_totalclms, opioid_drug_flag
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000
GROUP BY drug_name, opioid_drug_flag
ORDER BY sum_totalclms ASC;
--Lazily done, but column added and Hydrocodone-acetaminophen and oxycodone HCL are identified as opioids. 

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT npi, nppes_provider_last_org_name, nppes_provider_first_name, SUM(total_claim_count) AS sum_totalclms, opioid_drug_flag, drug_name
FROM prescription
LEFT JOIN drug
USING (drug_name)
LEFT JOIN prescriber
USING (npi)
WHERE total_claim_count >= 3000
GROUP BY npi, nppes_provider_last_org_name, nppes_provider_first_name, drug_name, opioid_drug_flag
ORDER BY sum_totalclms DESC;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name, specialty_description, opioid_drug_flag, nppes_provider_city
FROM prescriber
LEFT JOIN prescription
USING (npi)
LEFT JOIN drug
USING (drug_name)
WHERE opioid_drug_flag IN
	(SELECT opioid_drug_flag
	FROM drug
	LEFT JOIN prescription USING (drug_name)
	WHERE opioid_drug_flag = 'Y')
AND specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE';
--result set contains 35 rows

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT npi, drug_name, SUM(total_claim_count) AS total_claims
FROM prescriber
FULL JOIN prescription
USING (npi)
FULL JOIN drug
USING (drug_name)
GROUP BY npi, drug_name
ORDER BY total_claims DESC;


    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
