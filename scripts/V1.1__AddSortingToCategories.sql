
ALTER TABLE transaction_categories ADD COLUMN order_no SERIAL NOT NULL,
ADD CONSTRAINT unique_transaction_categories_order_no UNIQUE (order_no);



CREATE OR REPLACE FUNCTION move_transaction_categories_order_no(row_id INTEGER, new_order_no INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Move all the existing order_no
    UPDATE transaction_categories
    SET order_no = order_no + 1
    WHERE order_no >= new_order_no
      AND id <> row_id;

    -- Update the specific category with the new order 
    UPDATE transaction_categories
    SET order_no = new_order_no
    WHERE id = row_id;

END;
$$ LANGUAGE plpgsql;




-- public.transactions_view source

CREATE OR REPLACE VIEW transactions_view
AS SELECT t.id,
        CASE
            WHEN t.user_accounting IS NULL THEN t.accounting
            ELSE t.user_accounting
        END AS accounting,
    t.amount,
    t.sender,
    t.recipient,
    t.name,
    t.description,
    t.balance,
    t.currency,
    t.aligned,
    t.reserved,
    COALESCE(t.user_category_id, getcategory(t.description, t.amount < 0::numeric), '-1'::integer) AS category_id,
    gettype(t.amount::double precision) AS type
   FROM transactions t
     LEFT JOIN transaction_categories tc ON t.user_category_id = tc.id
   ORDER BY tc.order_no;

-- public.monthly_overview_by_category source

CREATE OR REPLACE VIEW monthly_overview_by_category
AS WITH pivot_plans AS (
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
    pf.amount AS plan_sum
   FROM pivot_plans pf
     FULL JOIN actual_calculated ac ON ac.year = pf.year AND ac.month = pf.month AND ac.type = pf.type AND ac.category_id = COALESCE(pf.category_id, '-1'::integer)
     LEFT JOIN transaction_categories tc ON pf.category_id = tc.id OR ac.category_id = tc.id
   ORDER BY tc.order_no;

