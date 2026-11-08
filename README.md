Digital Marketing — Campaign ROI and Budget Allocation
> Which marketing campaigns, channels and locations actually pay back? An analysis of 308 daily campaign records using **SQL and Excel**, which found that the largest share of the budget was going to the worst-performing channel.
---
1. Introduction
Marketing budgets are easy to spend and hard to judge. Without a clear view of what each campaign returns, money keeps flowing to channels that feel busy but lose money.
This project analyses a month of digital marketing activity (1–28 February 2021) across five campaigns, four categories and several audience tiers. It answers six business questions about return on marketing investment (ROMI), campaign and category performance, timing and geo targeting, and ends with a clear recommendation on where to move the budget. It also catches a data error in the source file that would have doubled the reported return if left in.
---
2. Problem Statement
Marketing budget is being allocated across campaigns, categories and geo tiers without a clear, verified view of which ones actually generate a return.
The six questions this project answers:
What is the overall ROMI?
What is the ROMI of each campaign?
On which dates did we spend the most, earn the most, and see high and low conversion rates? What were the average order values?
When are buyers more active: weekdays or weekends?
Which type of campaign works best: social, banner, influencer or search?
Which geo locations are better for targeting: tier 1 or tier 2 cities?
---
3. Data Sourcing
Dataset: daily marketing records, with 309 rows and 23 columns. 308 are real campaign records and one is a spreadsheet "Total" row (see Section 5).
Source: [add where the dataset came from, e.g. the training provider or platform]
Period: 1–28 February 2021.
Currency: INR (Indian rupees), as stated in the dataset description.
Group	Columns
Campaign	`campaign_name` (facebook, instagram, google, youtube, banner), `category` (social, media, search, influencer), `campaign_id`, `tier` (audience or geo group)
Date	`c_date`, weekday, weekday/weekend flag
Raw performance	`impressions`, `mark_spent` (marketing spend), `clicks`, `leads`, `orders`, `revenue`
Provided KPIs	ROMI, click percentage, conversion 1 (leads ÷ clicks), conversion 2 (orders ÷ leads), AOV, CPC, CPL, CAC, gross profit
Metric definitions used (from the project brief):
ROMI = (Revenue − Marketing spend) ÷ Marketing spend
Revenue ÷ spend ("return on spend") = Revenue ÷ Marketing spend. This is ROMI + 1. It is shown next to ROMI so both readings are clear.
---
4. Tools I Used and Why
I used SQL and Excel only. This was a deliberate choice, not a limitation.
What I used it for SQL (PostgreSQL)	Created the table, excluded the invalid Total row, and answered all six questions with aggregations (`SUM`, `GROUP BY`, ratios with `NULLIF`). It also holds the data-quality check that shows the Total row matches the sum of all real rows
Excel	Pivot summaries by tier, campaign and category, a weekday vs weekend comparison, a what-if budget reallocation model, and a one-page summary sheet with two charts. It reproduces the SQL numbers independently
Why SQL and Excel were enough:

Every question is a direct aggregation. Totals, ratios and averages by group are exactly what SQL does best, and a ratio like ROMI needs no modelling.
Two tools, two independent checks. SQL and Excel are different routes to the same numbers. When they agree, the result is reliable, and a third tool would only repeat the work.
No Python needed. Python is the right tool for statistical tests, large datasets or heavy cleaning. Here there was no hypothesis test to run, the data is small (308 rows), and the one cleaning issue was a single row.
Excel suits the audience. Marketing and finance stakeholders already use it, and the what-if budget model is easy for them to open, change and trust.
Why I did not build a Power BI dashboard:
It was a one-time decision, not ongoing monitoring. The question was where to move a budget. A dashboard is for tracking a metric over time.
Small, static data. One month, 308 rows, no live data connection and no refresh schedule. A dashboard would have nothing to update.
The answers fit on one page. The findings come down to a handful of ranked tables and two charts, which the Excel summary sheet shows clearly.
Effort vs benefit. Building and maintaining a dashboard would not have improved the decision. It becomes worthwhile if this turns into a regularly refreshed feed. The DAX measures for that are already written, so it can be built later.
---
5. Data Transformation and Cleaning
The key data issue: a Total row in the source file.
One row (id blank or 0, category "0") has spend = 0 but revenue = 42,889,366. It is not a campaign.
Tracing it back to the original spreadsheet showed it is a "Total" row that someone added for their own reference. Its revenue equals the sum of all 308 real rows.
Left in, it doubles revenue. The overall revenue ÷ spend would read 2.80x instead of 1.40x, and ROMI would read 180% instead of 40%.
What I did: excluded it from every calculation (`WHERE id <> 0`, or spend > 0) and documented why. This is an upstream issue, since a summary row should never be exported alongside transaction records.
Other checks and steps:
No duplicate rows. The only blank values (in date, weekday, weekday/weekend flag and tier) were in that same Total row.
Standardised column names in SQL (for example `Weekdays` → `weekdays`, `Days` → `days_type`, `campaign_name.1` → `campaign_name`).
Set correct data types (dates, integers, decimals) when creating the SQL table.
Safe division with `NULLIF` so rows with zero orders or zero spend can't cause errors.
Cross-checked SQL totals against the Excel pivots to confirm they match.
---
6. Analytics and Measures
Q1. Overall return
Measure	Result
Total spend	INR 30.59M
Total revenue	INR 42.89M
Gross profit	INR 12.30M
Revenue ÷ spend	1.40x
ROMI (revenue − spend) ÷ spend	40%
Q2. By campaign
Campaign	Spend	Revenue	Revenue ÷ spend	ROMI
YouTube	4.06M	15.31M	3.77x	+277%
Instagram	7.88M	11.02M	1.40x	+40%
Banner	5.03M	6.15M	1.22x	+22%
Google	3.46M	3.71M	1.07x	+7%
Facebook	10.17M	6.70M	0.66x	−34%
Q3. Performance by date
The highest-spend day and the highest-revenue day were the same: 20 February 2021 (spend 3.50M, revenue 5.26M).
Average order value stayed steady across the top five spend days (about 4,692–4,760).
The best conversion day was 10 February (2.83% leads per click). The worst was 2 February (1.29%), less than half as good.
Q4. Weekday vs weekend
Average revenue per campaign-day record was 141,914 on weekdays and 132,594 on weekends, about 7% higher on weekdays. This is a real but modest gap, and not a reason to change the schedule on its own.
Q5. By category
Category	Spend	Revenue	Revenue ÷ spend	ROMI
Influencer	8.31M	21.12M	2.54x	+154%
Media (banner)	5.03M	6.15M	1.22x	+22%
Search	3.46M	3.71M	1.07x	+7%
Social	13.80M	11.91M	0.86x	−14%
Social is the largest spend category (about 45% of the budget) and it loses money.
Q6. Geo targeting: tier 1 vs tier 2
Tier	Spend	Revenue	Revenue ÷ spend	ROMI
Tier 1	5.13M	6.94M	1.35x	+35%
Tier 2	5.76M	4.13M	0.72x	−28%
The gap also holds in every one of the four weeks of the period (tier 1 between 1.17x and 1.43x, tier 2 between 0.69x and 0.79x revenue ÷ spend), not just in the total.
SQL techniques used
`SUM` and `GROUP BY` for rollups, `NULLIF` for safe ratios, `WHERE` filters for tiers, `ORDER BY ... LIMIT` for top dates, and a reconciliation query that proves the Total row equals the sum of the real rows.
---
7. Recommendation
Move budget from Facebook and the Social category toward YouTube and Influencer. Facebook and Social lose money, while YouTube and Influencer return 2–6x more per unit spent.
Prioritise tier 1 over tier 2 geo targeting. Tier 1 returns +35% and tier 2 loses 28%, and the gap is consistent.
Test before a full switch. Shift about 20% of the Facebook budget to YouTube first, and compare results before committing more.
Add a standing data-quality check (flag any row with spend = 0 but a very large revenue) so a future data refresh can't bring the Total-row error back. Also ask the owner of the source spreadsheet to keep summary rows out of exports.
Re-run the analysis monthly to confirm the advantage of YouTube and Influencer holds beyond this one month.
---
8. Conclusions
Overall marketing is profitable (ROMI 40%), but the return is very uneven. YouTube returns +277% while Facebook loses 34%.
The biggest share of the budget goes to the weakest channel. Social takes about 45% of spend and returns less than it costs.
Where you target matters. Tier 1 audiences return +35% and tier 2 loses 28%.
Data quality changed the result. One invalid Total row would have doubled the reported revenue and made the whole programme look twice as good as it is. Checking the data before calculating prevented a false conclusion.
Limitation: this covers one month (28 days) of data. The findings are a strong reason to run a controlled budget test, not a guarantee that the pattern holds all year.
---
Prepared by Nwogbe Onyinyechi Victoria · Data Analyst
