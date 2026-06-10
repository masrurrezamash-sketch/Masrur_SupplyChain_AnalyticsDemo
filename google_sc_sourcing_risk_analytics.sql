USE google_sc_analytics;


/* The Sourcing Team needs a list of all active components that are single-sourced and have a lead time
longer than 12 weeks (3 months). They want to identify which parts are at risk of a long recovery
delay if a supplier goes down. */

select
 Part_ID,
 Part_Name,
 Supplier,
 Lead_Time_Weeks,
 Unit_Cost_USD
FROM Parts_Master
WHERE Multi_Source = 'False'
 AND Lead_Time_Weeks > 12
ORDER BY Lead_Time_Weeks DESC;


/* Want to know how many parts are currently running below their reorder points in each regional
hub, and what the average inventory runway is in those regions.
 */
 
 SELECT
 Region,
 COUNT(Part_ID) AS Under_Reorder_Part_Count,
 ROUND(AVG(Coverage_Weeks), 1) AS Average_Runway_Weeks
FROM Inventory_Coverage
WHERE Below_Reorder = 'True'
GROUP BY Region
ORDER BY Average_Runway_Weeks ASC;


/* We need to audit our supplier relationships. You must join our active catalog ( Parts_Master ) with
the official scorecard ( Supplier_Scorecard ) to show total spend and count how many singlesourced parts each supplier manages, focusing on suppliers with more than 1 single-sourced part */

SELECT 
    pm.Supplier,
    COUNT(pm.Part_ID) AS Total_Parts_Supplied,
    -- 1. FIXED: Added the missing comma and fixed the truncated alias name
    SUM(CASE WHEN pm.Multi_Source = 'False' THEN 1 ELSE 0 END) AS Single_Source_Count,
    ROUND(ss.Total_Spend_USD_M, 2) AS Annual_Spend_USD_M,
    ss.Risk_Rating
FROM Parts_Master pm
INNER JOIN Supplier_Scorecard ss ON pm.Supplier = ss.Supplier
GROUP BY pm.Supplier, ss.Total_Spend_USD_M, ss.Risk_Rating
-- 2. FIXED: This now perfectly matches the alias declared above
HAVING Single_Source_Count >= 1
ORDER BY Annual_Spend_USD_M DESC;


/* The logistics team claims that shipping delays are under control. You need to write a query analyzing
raw purchase orders to calculate the actual On-Time Delivery percentage (OTD%) and the total
capital (USD) currently delayed.
*/

SELECT 
    Supplier,
    COUNT(PO_Number) AS Total_POs_Placed,
    -- 1. FIXED: Restored complete alias name and added the missing comma
    SUM(CASE WHEN Status = 'Delayed' OR Days_Late > 0 THEN 1 ELSE 0 END) AS Delayed_POs,
    -- 2. FIXED: Fully restored the dynamic OTD% mathematical expression
    ROUND(
        (1 - (SUM(CASE WHEN Status = 'Delayed' OR Days_Late > 0 THEN 1 ELSE 0 END) / COUNT(PO_Number))) * 100, 
        1
    ) AS Calculated_OTD_Pct,
    -- 3. FIXED: Restored the complete final column alias name
    ROUND(SUM(CASE WHEN Status = 'Delayed' THEN Total_Value_USD ELSE 0 END), 0) AS Delayed_Spend_At_Risk_USD
FROM Purchase_Orders
GROUP BY Supplier
ORDER BY Delayed_Spend_At_Risk_USD DESC;


/* Our inventory levels fluctuate rapidly. Instead of showing all records, write an advanced query that
ranks parts by their inventory shortage risk within each region and returns only the top 2 highest-risk
parts for each area.
 */
 
 WITH RankedInventory AS (
 SELECT
 Region,
 Part_ID,
 Part_Name,
 Supplier,
 On_Hand_Units,
 Coverage_Weeks,
 Shortage_Risk,
 -- Rank parts within each region from shortest to longest runway
 DENSE_RANK() OVER(
 PARTITION BY Region
 ORDER BY Coverage_Weeks ASC, On_Hand_Units ASC
 ) AS Risk_Rank
 FROM Inventory_Coverage
 WHERE Below_Reorder = 'True'
)
SELECT
 Region,
 Part_ID,
 Part_Name,
 Supplier,
 On_Hand_Units,
 Coverage_Weeks,
 Shortage_Risk
FROM RankedInventory
WHERE Risk_Rank <= 2
ORDER BY Region, Risk_Rank;


/* A high-priority program (such as the XIO X2) is tracking "At Risk" due to schedule delays. To fix this,
you must write a diagnostic query joining the NPI Program Tracker, the Demand Forecast, the Parts
Master, and Purchase Orders to flag delayed orders causing delays for this regional launch.
*/

WITH TargetedNPI AS (
    -- Step 1: Isolate programs tracking 'At Risk' (safely handling NULL variance)
    SELECT
        Program,
        Region,
        Milestone,
        IFNULL(Days_Variance, 0) AS Milestone_Delay_Days
    FROM NPI_Program_Tracker
    WHERE Status = 'At Risk'
),
DelayedLogistics AS (
    -- Step 2: Identify physical components with active delayed shipments
    SELECT
        po.Part_ID,
        po.Part_Name,
        po.Region,
        po.PO_Number,
        po.Supplier,
        po.Days_Late AS PO_Delay_Days,
        po.Total_Value_USD
    FROM Purchase_Orders po
    WHERE po.Status = 'Delayed' OR po.Days_Late > 0
)
SELECT
    n.Program,
    n.Region AS NPI_Launch_Region,
    n.Milestone,
    n.Milestone_Delay_Days,
    p.Part_ID,
    p.Part_Name,
    dl.Supplier,
    dl.PO_Number,
    dl.Region AS PO_Current_Region,
    dl.PO_Delay_Days,
    ROUND(IFNULL(dl.Total_Value_USD, 0) / 1000, 1) AS Open_PO_Value_K_USD
FROM TargetedNPI n
-- Link NPI programs to their forecasted parts requirements
INNER JOIN Demand_Forecast df ON n.Program = df.Program
-- Resolve specific component metadata to identify Part IDs
INNER JOIN Parts_Master p ON df.Part_Name = p.Part_Name
-- Use LEFT JOIN so NPI risks are visible even if the delayed PO is in a different hub
LEFT JOIN DelayedLogistics dl ON p.Part_ID = dl.Part_ID
GROUP BY
    n.Program, n.Region, n.Milestone, n.Milestone_Delay_Days,
    p.Part_ID, p.Part_Name, dl.Supplier, dl.PO_Number, dl.Region, dl.PO_Delay_Days, dl.Total_Value_USD
ORDER BY n.Milestone_Delay_Days DESC, dl.PO_Delay_Days DESC;