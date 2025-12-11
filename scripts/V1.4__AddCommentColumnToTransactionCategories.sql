ALTER TABLE transaction_categories 
ADD COLUMN IF NOT EXISTS "comment" text NULL;