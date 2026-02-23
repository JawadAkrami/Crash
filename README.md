NYC Motor Vehicle Collisions – Data Cleaning Project

This project focuses on cleaning and preparing raw NYC Motor Vehicle Collisions data for analysis. The dataset contains over 1 million police-reported crash records collected between 2012 and 2025 (with 2015 missing), and comes with the usual real-world challenges: inconsistent formats, missing values, and noisy columns.

Using SQL, I profiled the data, validated ranges, standardized data types, handled missing values, removed highly sparse columns, and enforced basic data integrity rules. Dates and times were converted from text to proper types, column names were standardized to snake_case, empty strings were normalized to NULLs, and unnecessary columns were dropped to improve usability and performance.

The end result is a cleaner, more consistent dataset that’s easier to query and ready for analysis—while preserving high-severity crash records and analytically important fields like borough and street information. This project serves as a foundation for downstream analysis and visualization.
