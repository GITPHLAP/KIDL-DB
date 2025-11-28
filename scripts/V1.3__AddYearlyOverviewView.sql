-- public.yearly_overview_by_category source

CREATE OR REPLACE VIEW yearly_overview_by_category
AS SELECT year,
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