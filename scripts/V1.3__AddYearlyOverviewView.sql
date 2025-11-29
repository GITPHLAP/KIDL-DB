CREATE OR REPLACE VIEW monthly_overview_by_category
AS 
WITH pivot_plans AS (
    SELECT fo.year,
        fo.category_id,
        f.month,
        f.amount,
        fo.type
    FROM plans fo
    CROSS JOIN LATERAL ( VALUES (1,fo.january_amount), (2,fo.february_amount), (3,fo.march_amount), (4,fo.april_amount), (5,fo.may_amount), (6,fo.june_amount), (7,fo.july_amount), (8,fo.august_amount), (9,fo.september_amount), (10,fo.october_amount), (11,fo.november_amount), (12,fo.december_amount)) f(month, amount)
), actual_calculated AS (
    SELECT date_part('year'::text, tv.accounting)::integer AS year,
        date_part('month'::text, tv.accounting)::integer AS month,
        sum(tv.amount)::double precision AS actual_sum,
        tv.category_id,
        tv.type
    FROM transactions_view tv
    GROUP BY (date_part('year'::text, tv.accounting)), (date_part('month'::text, tv.accounting)), tv.type, tv.category_id
)
SELECT COALESCE(pf.year, ac.year) AS year,
    COALESCE(pf.month, ac.month) AS month,
    COALESCE(pf.type, ac.type) AS type,
    tc.description AS category,
    ac.actual_sum,
    pf.amount AS plan_sum,
    tc.order_no AS category_order_no
FROM pivot_plans pf
FULL JOIN actual_calculated ac ON ac.year = pf.year AND ac.month = pf.month AND ac.type = pf.type AND ac.category_id = COALESCE(pf.category_id, '-1'::integer)
LEFT JOIN transaction_categories tc ON pf.category_id = tc.id OR ac.category_id = tc.id;




-- public.yearly_overview_by_category source

CREATE OR REPLACE VIEW yearly_overview_by_category
AS 
SELECT year,
    type,
    category,
    COALESCE(sum(
        CASE
            WHEN month = 1 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_1_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 1 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_1_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 2 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_2_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 2 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_2_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 3 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_3_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 3 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_3_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 4 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_4_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 4 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_4_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 5 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_5_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 5 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_5_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 6 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_6_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 6 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_6_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 7 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_7_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 7 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_7_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 8 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_8_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 8 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_8_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 9 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_9_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 9 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_9_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 10 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_10_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 10 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_10_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 11 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_11_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 11 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_11_actual_sum,
    COALESCE(sum(
        CASE
            WHEN month = 12 THEN abs(plan_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_12_plan_sum,
    COALESCE(sum(
        CASE
            WHEN month = 12 THEN abs(actual_sum)
            ELSE NULL::double precision
        END), 0::double precision) AS month_12_actual_sum
FROM monthly_overview_by_category
GROUP BY year, category, type;