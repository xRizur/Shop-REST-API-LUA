-- import create_table, types from require "lapis.db.schema"

-- {
--   -- Pierwsza migracja: tworzy tabelę categories
--   [1]: =>
--     create_table "categories", {
--       { "id", types.serial }
--       { "name", types.varchar, { length: 255, null: false } }
--       { "created_at", "timestamp default current_timestamp" }
--       { "updated_at", "timestamp default current_timestamp" }

--       "PRIMARY KEY (id)"
--     },

--   -- Druga migracja: tworzy tabelę products
--   [2]: =>
--     create_table "products", {
--       { "id", types.serial }
--       { "name", types.varchar, { length: 255, null: false } }
--       { "category_id", types.integer, { null: false } }
--       { "price", types.numeric, { precision: 10, scale: 2, null: false } }
--       { "image_url", types.varchar, { length: 255, null: true } }
--       { "created_at", "timestamp default current_timestamp" }
--       { "updated_at", "timestamp default current_timestamp" }

--       "PRIMARY KEY (id)"
--     }
-- }

import create_table, types from require "lapis.db.schema"

{
	[1]: =>
		create_table "categories", {
			{ "id", types.serial }
			{ "name", types.text }
			{ "description", types.text } 

			"PRIMARY KEY (id)"
		}
	[2]: =>
		create_table "products", {
			{ "id", types.serial }
			{ "category_id", types.serial }
			{ "name", types.text }
			{ "description", types.text }
			{ "price", types.double }
			{ "amount", types.integer } 

			"PRIMARY KEY (id)"
		}
}