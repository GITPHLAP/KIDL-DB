ALTER TABLE transactions
DROP CONSTRAINT fk_category_id,
ADD CONSTRAINT fk_category_id FOREIGN KEY (user_category_id) REFERENCES transaction_categories(id) ON DELETE SET NULL;
