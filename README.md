#  Supply Chain Analytics & Risk Management

##  Note from Masrur
Hey there, and thanks for stopping by. I built this project to show, hands-on, how I use data to make supply chain decisions, the kind of work I do day to day as a program manager. It walks through the full journey: pulling insight out of raw transactional data with SQL, and turning it all into dashboards for KPI tracking and executive business review. I had a lot of fun building it, and I hope it gives you a clear sense of how I think and work. Feel free to dig into any piece that interests you.

##  About the Data (please read first)
Everything here runs on a **fully synthetic, anonymized dataset** I built specifically for this demonstration. Every supplier (Supplier 1 to 16), factory (Factory 1 to 5), and program (Program A to E) is a generic placeholder. There is **no proprietary or confidential information from any specific organization anywhere in this project.**

The dataset is designed to mirror the *structure* of a real data-center hardware supply chain, hardware components, lead times, demand signals, inventory positions, and purchase orders, so the analytical methods are realistic and transferable. Every value in it is fabricated.

## Project Overview
This repository is an end-to-end supply chain analytics and business intelligence project for a multi-regional network, tracking performance across five business units (Programs A through E). The goal is to bridge raw backend data and high-level executive decision-making, the same gap I work to close in my role.

The project encompasses:
* **SQL** | The analytical engine. Extracting operational insights, logistics bottleneck buckets, supplier performance, and Pareto spend distribution using CTEs, window functions, and multi-table joins.
* **Power BI** | The executive view. A fully interactive QBR dashboard where slicers filter every  KPI and chart live, from a global view down to a single region in one click.
* **Excel** | The working dashboard. A 100% formula-driven, interactive QBR workbook, no macros, with live KPI cards, demand forecast-vs-actual tracking, ranked supplier and risk tables, and dynamic dropdown slicers.

---

## Data Visualization & Reporting

### Power BI | Advanced Business Intelligence
*An interactive QBR dashboard. The slicers filter every KPI and chart live, so you can move from a global view down to a single region or program in one click. Tracks spend, on-time delivery, coverage risk, clean-launch rate, supplier concentration (Pareto), and the demand forecast-vs-actual gap.*

![Power BI Preview](https://github.com/masrurrezamash-sketch/Masrur_SupplyChain_AnalyticsDemo/blob/93f14fc85388cc4a6c86673642c2960d63d310bf/PbDB.png)

**Techniques used:** Excel Tables with structured references, dynamic dropdown slicers, SUMIFS / COUNTIFS / AVERAGEIFS with wildcard logic, XLOOKUP, LARGE + INDEX/MATCH for dynamic ranking, IFERROR guards, and conditional formatting, all native, nothing hard-coded.

<br/>

### Excel | Operational Tracking & Analytics
*A fully formula-driven dashboard built entirely on native Excel, no macros, no VBA. Six live KPI cards, a demand forecast-vs-actual trend, a purchase-order status breakdown, ranked Top 5 supplier and at-risk-parts tables, and shortage risk by region, all driven by dynamic dropdown slicers.
Change a dropdown and every KPI and chart recalculates instantly.*

![Excel Preview](https://github.com/masrurrezamash-sketch/Masrur_SupplyChain_AnalyticsDemo/blob/16e903d32a9bd16e3ecb0011531a6ee69336aa56/ExcelDashboard.png)

---

## Relational Database Execution & SQL Outputs
*Standard SQL queries executed natively in the MySQL environment to extract core supply chain KPIs and validate data models.*

### 1. Financial Exposure: Spend-at-Risk Query
*Tracks total financial exposure and delayed units caused by logistics bottlenecks across manufacturing factories.*
![SQL Output 1](https://github.com/masrurrezamash-sketch/Masrur_SupplyChain_AnalyticsDemo/blob/42ee390ea0030180f6035737d477c3961069ca26/SqlOutput1.png)

<br/>

### 2. Operational Risk: Critical Stockout Warnings
*Cross-references real-time inventory on-hand balances against component burn rates to isolate immediate material risks.*
![SQL Output 2](https://github.com/masrurrezamash-sketch/Masrur_SupplyChain_AnalyticsDemo/blob/42ee390ea0030180f6035737d477c3961069ca26/SqlOutput2.png)

<br/>

### 3. Supplier Performance & Pareto Spend Distribution
*Evaluates vendor delivery metrics and classifies spend tiers to optimize procurement risk.*
![SQL Output 3](https://github.com/masrurrezamash-sketch/Masrur_SupplyChain_AnalyticsDemo/blob/42ee390ea0030180f6035737d477c3961069ca26/SqlOutput3.png)

<br/>

### 4. Demand Volatility & Forecast Variance Tracking
*Aggregates forecast-to-actual unit variances across Programs A–E to uncover hidden tracking errors.*
![SQL Output 4](https://github.com/masrurrezamash-sketch/Masrur_SupplyChain_AnalyticsDemo/blob/42ee390ea0030180f6035737d477c3961069ca26/SqlOutput4.png)

<br/>

### 5. NPI Launch Health & Sourcing Diversity
*Monitors milestone completion rates and strategic multi-sourcing percentages for pre-production launch readiness.*
![SQL Output 5](https://github.com/masrurrezamash-sketch/Masrur_SupplyChain_AnalyticsDemo/blob/42ee390ea0030180f6035737d477c3961069ca26/SqlOutput5.png)
