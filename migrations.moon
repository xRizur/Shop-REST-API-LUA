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
			{ "imageurl", types.text, null: true }

			"PRIMARY KEY (id)"
		}
}