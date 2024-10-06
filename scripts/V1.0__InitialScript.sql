
-- DROP TYPE public."trans_type";

CREATE TYPE public."trans_type" AS ENUM (
	'expenses',
	'income');

-- Drop table

-- DROP TABLE api_statistics;

CREATE TABLE api_statistics (
	"timestamp" timestamp DEFAULT now() NOT NULL,
	url text NOT NULL,
	status_code int4 NOT NULL,
	http_method text NOT NULL,
	size_bytes int8 NOT NULL,
	client_ip text NOT NULL,
	elapsed_time_seconds float8 NULL
);


-- public.private_transactions_to_savings definition

-- Drop table

-- DROP TABLE private_transactions_to_savings;

CREATE TABLE private_transactions_to_savings (
	id serial4 NOT NULL,
	person_name text NOT NULL,
	"date" date NOT NULL,
	amount float8 NOT NULL,
	transferred bool NOT NULL,
	CONSTRAINT private_transactions_to_savings_pkey PRIMARY KEY (id)
);


-- public.savings definition

-- Drop table

-- DROP TABLE savings;

CREATE TABLE savings (
	id serial4 NOT NULL,
	"date" date NOT NULL,
	amount float8 NOT NULL,
	category text NOT NULL,
	CONSTRAINT savings_pkey PRIMARY KEY (id)
);


-- public.transaction_categories definition

-- Drop table

-- DROP TABLE transaction_categories;

CREATE TABLE transaction_categories (
	id serial4 NOT NULL,
	description text NOT NULL,
	CONSTRAINT transaction_categories_pkey PRIMARY KEY (id)
);


-- public.transactions_audit definition

-- Drop table

-- DROP TABLE transactions_audit;

CREATE TABLE transactions_audit (
	operation bpchar(1) NOT NULL,
	stamp timestamp NOT NULL,
	olddata text NULL,
	newdata text NULL,
	query text NULL
);


-- public.transactions_test definition

-- Drop table

-- DROP TABLE transactions_test;

CREATE TABLE transactions_test (
	id serial4 NOT NULL,
	accounting date NULL,
	amount numeric NULL,
	sender int8 NULL,
	recipient int8 NULL,
	"name" varchar(255) NULL,
	description varchar(255) NULL,
	balance numeric NULL,
	currency varchar(5) NULL,
	aligned varchar(255) NULL,
	user_category varchar(255) NULL,
	reserved bool NULL,
	user_accounting date NULL,
	user_category_id int4 NULL,
	CONSTRAINT transactions_test_key UNIQUE (amount, sender, recipient, name, description, balance, currency)
);


-- public."plans" definition

-- Drop table

-- DROP TABLE "plans";

CREATE TABLE "plans" (
	id serial8 NOT NULL,
	"year" int4 NOT NULL,
	"type" public."trans_type" NOT NULL,
	category_id int4 NULL,
	january_amount float8 NULL,
	february_amount float8 NULL,
	march_amount float8 NULL,
	april_amount float8 NULL,
	may_amount float8 NULL,
	june_amount float8 NULL,
	july_amount float8 NULL,
	august_amount float8 NULL,
	september_amount float8 NULL,
	october_amount float8 NULL,
	november_amount float8 NULL,
	december_amount float8 NULL,
	CONSTRAINT forecasts_pkey PRIMARY KEY (id),
	CONSTRAINT unique_forecasts_year_category UNIQUE (year, type, category_id),
	CONSTRAINT fk_forecasts_category_id FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE
);


-- public.transaction_categories_mapping definition

-- Drop table

-- DROP TABLE transaction_categories_mapping;

CREATE TABLE transaction_categories_mapping (
	id serial4 NOT NULL,
	category_id int4 NOT NULL,
	mapping_value text NOT NULL,
	CONSTRAINT transaction_categories_mapping_pkey PRIMARY KEY (id),
	CONSTRAINT unique_mapping_values UNIQUE (mapping_value),
	CONSTRAINT fk_transaction_categories_mapping_category_id FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE
);


-- public.transactions definition

-- Drop table

-- DROP TABLE transactions;

CREATE TABLE transactions (
	id serial4 NOT NULL,
	accounting date NULL,
	amount numeric NULL,
	sender int8 NULL,
	recipient int8 NULL,
	"name" varchar(255) NULL,
	description varchar(255) NULL,
	balance numeric NULL,
	currency varchar(5) NULL,
	aligned varchar(255) NULL,
	user_category varchar(255) NULL,
	reserved bool NULL,
	user_accounting date NULL,
	user_category_id int4 NULL,
	CONSTRAINT transactions_amount_sender_recipient_name_description_balan_key UNIQUE (amount, sender, recipient, name, description, balance, currency),
	CONSTRAINT fk_category_id FOREIGN KEY (user_category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE
);

-- Table Triggers

CREATE TRIGGER transactions_audit AFTER INSERT
OR DELETE
OR UPDATE ON
public.transactions FOR EACH ROW EXECUTE FUNCTION process_transactions_audit();


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
     LEFT JOIN transaction_categories tc ON pf.category_id = tc.id OR ac.category_id = tc.id;


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
     LEFT JOIN transaction_categories tc ON t.user_category_id = tc.id;



-- DROP FUNCTION public.getcategory(varchar, bool);

CREATE OR REPLACE FUNCTION public.getcategory(_description character varying, is_expenses boolean)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$

declare 
    category_id int;
   temp_cat int;
begin
   	category_id = NULL;
   SELECT tc.id
   INTO category_id
   FROM transaction_categories tc 
   LEFT JOIN transaction_categories_mapping tcm 
   	ON tc.id = tcm.category_id 
WHERE LOWER(tc.description) ILIKE _description
	OR _description ILIKE ('%'|| LOWER(tcm.mapping_value) || '%');
        
RETURN category_id;
end;
$function$
;

-- DROP FUNCTION public.getlatestaccountingdate();

CREATE OR REPLACE FUNCTION public.getlatestaccountingdate()
 RETURNS date
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE 
    accountingDate date;
BEGIN
    SELECT MAX(accounting)
    INTO accountingDate
    FROM transactions;
    CASE 
        WHEN accountingDate IS NULL
            THEN RETURN '1900-01-01';
        ELSE 
            RETURN accountingDate;
    END CASE;
END;
$function$
;

-- DROP FUNCTION public.gettype(float8);

CREATE OR REPLACE FUNCTION public.gettype(amount double precision)
 RETURNS trans_type
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
declare 
    type varchar(255);
begin
    CASE
        WHEN amount > 0 
            THEN type = 'income'::public.trans_type;
        ELSE 
            type = 'expenses'::public.trans_type;
        END CASE;

return type;
end;
$function$
;

-- DROP PROCEDURE public.inserttransactions(date, numeric, int8, int8, varchar, varchar, numeric, varchar, varchar, varchar, bool);

CREATE OR REPLACE PROCEDURE public.inserttransactions(IN _accounting date, IN _amount numeric, IN _sender bigint, IN _recipient bigint, IN _name character varying, IN _description character varying, IN _balance numeric, IN _currency character varying, IN _aligned character varying, IN _user_category character varying, IN _reserved boolean)
 LANGUAGE plpgsql
AS $procedure$
begin
    IF (_accounting >= getLatestAccountingDate() AND _accounting IS NOT null) THEN -- Only inserting new data or update the accounting
		INSERT INTO transactions as t (accounting, amount, sender, recipient, name, description, balance, currency, aligned, user_category, reserved)
		VALUES (_accounting, _amount, _sender, _recipient, _name, _description, _balance, _currency, _aligned, _user_category, _reserved)
		ON CONFLICT (amount, sender, recipient, name, description, balance, currency)
			DO UPDATE SET (reserved, accounting) = (_reserved, _accounting)
			WHERE t.accounting IS NULL;
    END IF;
    commit;
end;
$procedure$
;

-- DROP PROCEDURE public.inserttransactions_old(date, numeric, int8, int8, varchar, varchar, numeric, varchar, varchar, varchar, bool);

CREATE OR REPLACE PROCEDURE public.inserttransactions_old(IN _accounting date, IN _amount numeric, IN _sender bigint, IN _recipient bigint, IN _name character varying, IN _description character varying, IN _balance numeric, IN _currency character varying, IN _aligned character varying, IN _user_category character varying, IN _reserved boolean)
 LANGUAGE plpgsql
AS $procedure$
begin
    IF (_accounting >= getLatestAccountingDate() OR _accounting is null) AND NOT EXISTS(SELECT 1 FROM transactions t WHERE t.amount = _amount AND
            t.description = _description AND t.reserved = _reserved AND t.sender = _sender AND t.recipient = _recipient AND t.balance = _balance) THEN
        IF EXISTS(SELECT id FROM transactions t WHERE t.accounting is null AND t.amount = _amount AND
            t.description = _description AND t.reserved = TRUE AND t.sender = _sender AND t.recipient = _recipient AND t.balance = _balance) THEN
            UPDATE transactions
                SET reserved = _reserved,
                    accounting = _accounting,
					balance = _balance
            WHERE id = (SELECT id FROM transactions t WHERE t.accounting is null AND t.amount = _amount AND
            t.description = _description AND t.user_category = _user_category AND t.reserved = TRUE AND t.sender = _sender AND t.recipient = _recipient AND t.balance = _balance);
        ELSE
            INSERT INTO transactions(accounting, amount, sender, recipient, name, description, balance, currency, aligned, user_category, reserved)
            VALUES (_accounting, _amount, _sender, _recipient, _name, _description, _balance, _currency, _aligned, _user_category, _reserved); 
            -- ON CONFLICT ON CONSTRAINT transactions_accounting_amount_description_balance_user_cat_key
            --     DO NOTHING;
        END IF;
    END IF;
    commit;
end;
$procedure$
;

-- DROP FUNCTION public.process_transactions_audit();

CREATE OR REPLACE FUNCTION public.process_transactions_audit()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO transactions_audit SELECT 'D', now(), ROW(OLD.*), NULL, current_query();
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO transactions_audit SELECT 'U', now(), ROW(OLD.*), ROW(NEW.*), current_query();
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO transactions_audit SELECT 'I', now(), NULL, ROW(NEW.*), current_query();
            RETURN NEW;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$function$
;