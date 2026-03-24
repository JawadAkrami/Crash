## NYC Motor Vehicle Collisions – Data Cleaning Project

This project focuses on cleaning and preparing raw NYC Motor Vehicle Collisions data for analysis. The dataset contains over 1 million police-reported crash records collected between 2012 and 2025 (with 2015 missing), and reflects common real-world data challenges such as inconsistent formats, missing values, and noisy columns.

Using SQL, I profiled the dataset, validated value ranges, standardized data types, handled missing values, removed highly sparse columns, and enforced basic data integrity rules. Date and time fields were converted from text to proper formats. Moreover, column names were standardized to snake_case, empty strings were normalized to NULLs, and unnecessary columns were dropped.

---

## Handling Missing Borough Values

A significant portion of the dataset contains records where the borough is labeled as **“Unknown.”**

Rather than removing these records, they were intentionally retained for the following reasons:

* Removing them would result in a **substantial loss of data**
* It could introduce **bias**, especially in aggregate analysis
* These records still contain **valuable information** (e.g., injuries, fatalities, vehicle types)

Keeping the “Unknown” category ensures that the dataset remains complete and representative of real-world reporting limitations, while still allowing meaningful analysis of known boroughs.

---

## Dashboard

An interactive dashboard was created to explore key insights such as collisions by borough, vehicle types, injury distribution, and monthly trends:

[https://drive.google.com/file/d/12ieXB_GsTofbjciFnbkEpmkAGvjm1o6f/view?usp=drive_link](https://drive.google.com/file/d/12ieXB_GsTofbjciFnbkEpmkAGvjm1o6f/view?usp=drive_link)

---

## Outcome

The final dataset is cleaner, more consistent, and optimized for analysis while preserving critical fields such as borough, street information, and injury severity.

---


