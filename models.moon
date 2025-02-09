-- -- app/models.moon
-- import Model from require "lapis.db.model"

-- class Category extends Model
--   @name: "categories"

--   validate: ->
--     if not self.name or self.name == ""
--       error "Category: name is required"

-- class Product extends Model
--   @name: "products"

--   validate: ->
--     if not self.name or self.name == ""
--       error "Product: name is required"
--     if not self.category_id
--       error "Product: category_id is required"
--     if not self.price
--       error "Product: price is required"

-- return {
--   Category: Category,
--   Product: Product
-- }

import autoload from require "lapis.util"
autoload "models"