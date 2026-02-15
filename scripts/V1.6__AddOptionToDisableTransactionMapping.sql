ALTER TABLE public.transaction_categories_mapping 
ADD COLUMN IF NOT EXISTS disabled boolean NOT NULL DEFAULT false;



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
   WHERE tcm.disabled = false AND (LOWER(tc.description) ILIKE _description
	OR _description ILIKE ('%'|| LOWER(tcm.mapping_value) || '%'));
        
RETURN category_id;
end;
$function$
;