-- Data Cleaning 
-- step 1: Remove duplicates
-- step 2: standardize data 
-- step 3: null values and blank values 
-- step 4: remove any unnecssary columns   

select*
from layoffs
;

create table layoffs_staging  # we will create another table to keep raw table safe from changes.as
like layoffs;

select*
from layoffs_staging ;

insert layoffs_staging
select*
from layoffs; #we will insert same data from layoffs into layoffs_staging 
;

-- 1. deleteing duplicates 
select*,
row_number () over ( partition by company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging ;

with duplicate_cte as
(select*,
row_number () over ( partition by company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions ) as row_num
from layoffs_staging 
)

select*
from duplicate_cte
where row_num > 1
;


select* from layoffs_staging
where company like "wildlife studios"; # we will check if they are actually duplicates or we can cange partion by in over() but here no need as we have taken patition by all columns.  

-- we will remove duplicates now
with duplicate_cte as
(select*,
row_number () over ( partition by company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions ) as row_num
from layoffs_staging 
)
delete  
from duplicate_cte
where row_num > 1; # error is delete is not updatable so we will make a new table.

# we will go on layoff_stahgimg table in schemas then right click to copy to clipboard  for craete statment and paste it 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int        
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# we just added a new column of row_num to new table so we can perform functions on it. 

select*
from layoffs_staging2;

# we inserted the data in staging 2 table with row_num so we now can perform operations with it and remove duplicates.
insert into layoffs_staging2
select*,
row_number () over ( partition by company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions ) as row_num
from layoffs_staging ;

-- now we will delete the duplicates and error will not occur.
delete  
from layoffs_staging2
where row_num > 1; 

select*
from layoffs_staging2;
# if we had a seprate identity column it would have been easy. 



-- 2. standardizing data 
# so we can see spaces in company name so we will trim it so no spaces on left side . 

select company ,trim(company) 
from layoffs_staging2; 
#so we will update this to our table .

update layoffs_staging2 
set company = trim(company);

select distinct industry 
from layoffs_staging2
order by industry
; # we can see that there are multiple crypto but adressed diffrently so we need them to be a single feild as they are all same. 

select*
from layoffs_staging2
where industry like "crypto%" 
;  # we checked for more such crypto similar feilds which could be in table. 

update layoffs_staging2
set industry = "Crypto" 
where industry like "Crypto%";
# we succesfully updated industry column of table where cypto% 

select distinct  industry 
from layoffs_staging2; 
# we can see that every crypto similar names and rows are under one name crypto.
# we looked at company,industry now lets see location

select*
from layoffs_staging2;

select distinct location
from layoffs_staging2
order by location; # so it look normal 

# so we will move to country 
select distinct country 
from layoffs_staging2
order by country; 
# we can see that US and US. is taken as diffrent so we will fix it . 
select*
from layoffs_staging2
where country like "United States%";

# another method unlike above methods.
select distinct country , trim(trailing '.' from country )
from layoffs_staging2
order by country  ;
# we can see that . is now trim so we will update it to our table 

update layoffs_staging2 
set  country = trim(trailing '.' from country )
where country like 'United States%'
;

select distinct country 
from layoffs_staging2 order by country ;
# so we can see only one united states . 

select*
from layoffs_staging2; 

-- we would now look at  date column we can see that data type is text so we will change it to date .
select `date`,
str_to_date( `date`, '%m/%d/%Y')
from layoffs_staging2; 

update layoffs_staging2 
set `date` = str_to_date( `date`, '%m/%d/%Y'); 
# this has changed the column format to date but we can chnage the coulmn data type to date :

alter table layoffs_staging2
modify column `date` date; 
# never do this to raw data or raw file columns 

-- step 3 : now we will deal with nulls or blank values . 
update layoffs_staging2
set industry = null
where industry = '';
# we changed the blank values in industry coumn to null . 


select*
from layoffs_staging2
where industry is null
;
# so we can look for filling this by using distinct but  same company in this table .

select*
from layoffs_staging2
where company = 'airbnb'; # so here we can see that another same company has mentioned that they are travel so we can update that . 

select t1.company , t1.industry , t2.industry, t1.location
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
and t1.location = t2.location
where t1.industry is null 
and t2.industry is not null ; 
# so we can compare industry column of t1 and t2 table and we can see industry type of company in t2 table whih are same company so we need to fill them in table .

update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company 
set t1. industry = t2.industry
where t1.industry is null
and t2.industry is not null ; 

select*
from layoffs_staging2
where company = 'airbnb'; 
# so it is done ealry airbnb one row in industry coloumn was null now it is filled correctly. 

select * 
from layoffs_staging2 
where industry is null;  
# only bellys is left but we do not have data on it so it will not be usefull.

select* from layoffs_staging2;

-- step 4 removing unessary rows and columns 
select*
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null; 
# we cannot use them as both columns in this of laoid off are null so we do not have use of them yo study.

delete 
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;  
# so we deleted them as we not need them in layoffs study as both total and percentage laid off was null or blank .

select*
from layoffs_staging2;

# so now we do not need the row_num column so we will remove it 

alter table layoffs_staging2
drop column row_num;




