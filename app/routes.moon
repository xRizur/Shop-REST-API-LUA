-- app/routes.moon
lapis = require "lapis"
app = lapis.Application!

require "app.models"  -- Ładujemy modele

### Category endpoints

app:get "/categories", (req) ->
  categories = Category:select!
  { json: categories }

app:get "/categories/:id", (req) ->
  id = req.params.id
  category = Category:find! id
  unless category
    return { status: 404, json: { error: "Category not found" } }
  { json: category }

app:post "/categories", (req) ->
  params = req.params
  category = Category:create! { name: params.name }
  { status: 201, json: category }

app:put "/categories/:id", (req) ->
  id = req.params.id
  category = Category:find! id
  unless category
    return { status: 404, json: { error: "Category not found" } }
  category:update! { name: req.params.name }
  { json: category }

app:delete "/categories/:id", (req) ->
  id = req.params.id
  category = Category:find! id
  unless category
    return { status: 404, json: { error: "Category not found" } }
  category:delete!
  { json: { message: "Category deleted" } }

### Product endpoints

app:get "/products", (req) ->
  products = Product:select!
  { json: products }

app:get "/products/:id", (req) ->
  id = req.params.id
  product = Product:find! id
  unless product
    return { status: 404, json: { error: "Product not found" } }
  { json: product }

app:post "/products", (req) ->
  params = req.params
  product_data = {
    name: params.name
    category_id: params.category_id
    price: params.price
  }
  product = Product:create! product_data
  { status: 201, json: product }

app:put "/products/:id", (req) ->
  id = req.params.id
  product = Product:find! id
  unless product
    return { status: 404, json: { error: "Product not found" } }
  update_data = {
    name: req.params.name or product.name
    category_id: req.params.category_id or product.category_id
    price: req.params.price or product.price
  }
  product:update! update_data
  { json: product }

app:delete "/products/:id", (req) ->
  id = req.params.id
  product = Product:find! id
  unless product
    return { status: 404, json: { error: "Product not found" } }
  product:delete!
  { json: { message: "Product deleted" } }

return app
