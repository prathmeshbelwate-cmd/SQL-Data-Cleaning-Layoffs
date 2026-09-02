# 📊 SQL Data Cleaning — Layoffs Dataset

## 📌 Project Overview

This project focuses on cleaning and preparing a **layoffs dataset using SQL**. The original dataset contains information about company layoffs, including company name, location, industry, number of employees laid off, percentage laid off, date, company stage, country, and funds raised.

The main goal of this project was to transform raw and inconsistent data into a **clean, standardized, and analysis-ready dataset** while keeping the original data protected.

---

## 🎯 Project Objectives

The cleaning process focused on:

* 🔍 Identifying and removing duplicate records
* ✨ Standardizing inconsistent data
* 🧹 Handling blank and `NULL` values
* 📅 Converting date values into the correct format
* 🏷️ Standardizing industry and country names
* 🗑️ Removing rows that were not useful for analysis
* 📦 Removing unnecessary columns after the cleaning process

---

## 🛠️ Tools & Technologies

* **MySQL**
* **SQL**
* Window Functions
* Common Table Expressions (CTEs)
* Joins
* Data Definition Language (DDL)
* Data Manipulation Language (DML)

---

## 🔄 Data Cleaning Process

### 1️⃣ Creating a Staging Table

Instead of making changes directly to the original `layoffs` table, a staging table was created.

This helped preserve the raw dataset while allowing the cleaning process to be performed safely on a separate copy.

```sql
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;
```

A second staging table, `layoffs_staging2`, was later created to make it easier to identify and remove duplicate records.

---

### 2️⃣ Removing Duplicate Records

Duplicate records were identified using the `ROW_NUMBER()` window function.

The following columns were considered when identifying duplicates:

* Company
* Location
* Industry
* Total laid off
* Percentage laid off
* Date
* Stage
* Country
* Funds raised

Records with a `row_num` greater than `1` were treated as duplicates and removed.

This ensured that each relevant layoff record appeared only once in the cleaned dataset.

---

### 3️⃣ Standardizing the Data

The next step was to make inconsistent values more uniform.

#### 🏢 Company Names

Leading and trailing spaces were removed using `TRIM()`.

```sql
UPDATE layoffs_staging2
SET company = TRIM(company);
```

#### 💻 Industry

Different variations of cryptocurrency-related industries were identified and standardized under a single value:

```sql
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```

This prevents values such as different `Crypto` variations from being treated as separate industries during analysis.

#### 🌎 Country Names

Inconsistent country formatting was identified, such as `United States` and `United States.`.

The trailing period was removed to ensure consistent country names.

#### 📅 Date Formatting

The `date` column was initially stored as text. It was converted into a proper SQL `DATE` format using `STR_TO_DATE()` and then the column data type was changed to `DATE`.

```sql
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

Having the correct date data type makes the dataset much more useful for future analysis.

---

### 4️⃣ Handling NULL and Blank Values

Blank industry values were converted into `NULL` values to make missing data easier to identify and handle.

```sql
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
```

Where possible, missing industry information was populated by comparing records belonging to the same company.

This was done using a self-join, allowing existing industry information from another record to be used when appropriate.

Some missing values could not be reliably determined from the available dataset, so they were left as `NULL` rather than introducing inaccurate information.

---

### 5️⃣ Removing Unnecessary Rows

Rows where **both `total_laid_off` and `percentage_laid_off` were `NULL`** were removed.

These records did not provide useful information for studying layoffs because neither the number nor percentage of employees affected was available.

```sql
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
```

---

### 6️⃣ Removing the Helper Column

The `row_num` column was created temporarily to identify duplicate records.

Once duplicate removal was completed, the column was no longer required and was removed from the final dataset.

```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

---

## 📈 Final Outcome

After completing the cleaning process, the dataset was:

✅ Free from duplicate records
✅ More consistent across company, industry, and country fields
✅ Converted to appropriate date formatting
✅ Better organized for handling missing values
✅ Free from records with no useful layoff information
✅ Ready for further exploratory analysis

---

## 💡 Key SQL Concepts Demonstrated

This project provided practical experience with several important SQL concepts:

* `ROW_NUMBER()` and window functions
* `PARTITION BY`
* Common Table Expressions (CTEs)
* `UPDATE` and `DELETE`
* `JOIN` operations
* Self-joins for filling missing information
* `TRIM()` for text cleaning
* `LIKE` for pattern matching
* `STR_TO_DATE()` for date conversion
* `ALTER TABLE`
* Creating and working with staging tables
* Handling `NULL` and blank values

---

## 📂 Repository Structure

```text
SQL-Data-Cleaning-Layoffs/
│
├── layoffs_data_cleaning.sql
└── README.md
```

---

## 🚀 What's Next?

The cleaned dataset can be used for further **Exploratory Data Analysis (EDA)** to investigate questions such as:

* Which companies had the largest layoffs?
* Which industries were most affected?
* How did layoffs change over time?
* Which countries experienced the most layoffs?
* Which companies had the highest percentage of employees laid off?
* How did layoffs vary across different company stages?

---

## 👨‍💻 About This Project

This project was created as a practical exercise to strengthen SQL and data-cleaning skills using a real-world dataset.

The focus was not only on writing SQL queries, but also on understanding the **data-cleaning workflow** and making thoughtful decisions about data quality before performing analysis.

---

⭐ **If you find this project useful, feel free to explore the SQL file and follow the cleaning process step by step.**

