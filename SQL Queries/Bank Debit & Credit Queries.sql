use Bank_project;

# 1. Total Credit Amount
select concat(round(sum(`Amount`)/1000000,3), "M") as Credit_Amount
from debit_credit  where `Transaction Type`= "Credit";


# 2. Total Debit Amount
select concat(round(sum(`Amount`)/1000000,3), "M") as Debit_Amount
from debit_credit  where `Transaction Type`= "Debit";

# 3. Credit to Debit Ratio
select round((select sum(`Amount`)
from debit_credit  where `Transaction Type`= "Credit") / (select sum(`Amount`) 
from debit_credit  where `Transaction Type`= "Debit"),4) as Credit_to_Debit_Ratio;


# 4. Net Transaction Amount
select concat(round(((select sum(`Amount`)
from debit_credit  where `Transaction Type`= "Credit") - (select sum(`Amount`) 
from debit_credit  where `Transaction Type`= "Debit"))/1000,3),"K") as Net_Transaction_Amount;

# 5. Account Activity Ratio
select round(count(`Transaction Type`)/sum(`Balance`),5) as "Account Activity Ratio"from debit_credit;

# 6. Transactions per Day/Week/Month
select 
    `Transaction year`, 
    `Transaction Month`, 
    count(*) as total_transactions
from debit_credit
group by `Transaction year`, `Transaction Month`
order by total_transactions desc;


# 7. Total Transaction Amount by Branch
select Branch, 
concat(round(sum(`amount`)/1000000,2),"M") as Transaction_Amount 
from debit_credit 
group by Branch 
order by Transaction_Amount desc;

# 8. Transaction Volume by Bank
select `Bank Name`, concat(round(sum(`Amount`)/1000000,2),"M") as Transaction_Amount 
from debit_credit 
group by `Bank Name` 
order by Transaction_Amount desc;

# 9. Transaction Method Distribution
select `Transaction Method`,
count(*) as "Transaction Method Distribution" 
from debit_credit 
group by `Transaction Method`;

# 10. Branch Transaction Growth
select 
    Branch,
    `Transaction Month`,
    sum(`Amount`) as monthly_total,
    lag(sum(`Amount`)) over (partition by Branch order by str_to_date(`Transaction Month`, '%M')) as previous_month_total,
    round(
        (sum(`Amount`) - lag(sum(`Amount`)) over (partition by Branch order by str_to_date(`Transaction Month`, '%M'))) / 
        lag(sum(`Amount`)) over (partition by Branch order by str_to_date(`Transaction Month`, '%M')) * 100, 2) 
        as monthly_growth_percentage
from debit_credit
group by Branch, `Transaction Month`
order by Branch, str_to_date(`Transaction Month`, '%M');

# 11. High-Risk Transaction Flag
select
   `Account Number`,`Bank Name`,`Branch`,`Amount`,
    case 
        when `Amount` > 4000 then 'HIGH_RISK'
        else 'NORMAL'
    end as High_Risk
from debit_credit;

# 12. Suspicious Transaction Frequency

select 
    "High Risk" as "Status",
    `Transaction Month`, 
    `Transaction year`,
    count(*) as suspicious_count
from 
    debit_credit
where 
    "High Risk" = 'High Risk'
group by 
    "High Risk",
    `Transaction year`, 
    `Transaction Month`
order by 
    `Transaction year` desc, 
    str_to_date(`Transaction Month`, '%M');


