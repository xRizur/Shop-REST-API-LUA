-- app/models.moon
-- Pobieramy moduł lapis.db.model i przypisujemy go do lokalnej zmiennej
local db_model = require "lapis.db.model"
Model = db_model.Model

class Category extends Model
  @name: "categories"
  # Expected columns: id, name

class Product extends Model
  @name: "products"
  # Expected columns: id, name, category_id, price, image_url (optional)
