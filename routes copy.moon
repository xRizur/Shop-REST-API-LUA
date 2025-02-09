-- routes.moon
lapis = require "lapis"
app = lapis.Application!
import Category, Product from require "models"
require "models"

app:get("/categories", (self) =>
  categories = Category:select!
  { json: categories }
)

app:get("/categories/:id", (self) =>
  category = Category:find! self.params.id
  unless category
    return { status: 404, json: { error: "Category not found" } }
  { json: category }
)

app:post("/categories", (self) =>
  category = Category:create! { name: self.params.name }
  { status: 201, json: category }
)

app:put("/categories/:id", (self) =>
  category = Category:find! self.params.id
  unless category
    return { status: 404, json: { error: "Category not found" } }
  category:update! { name: self.params.name }
  { json: category }
)

app:delete("/categories/:id", (self) =>
  category = Category:find! self.params.id
  unless category
    return { status: 404, json: { error: "Category not found" } }
  category:delete!
  { json: { message: "Category deleted" } }
)

### Products
app:get("/products", (self) =>
  products = Product:select!
  { json: products }
)

app:get("/products/:id", (self) =>
  product = Product:find! self.params.id
  unless product
    return { status: 404, json: { error: "Product not found" } }
  { json: product }
)

app:post("/products", (self) =>
  product = Product:create! {
    name: self.params.name
    category_id: self.params.category_id
    price: self.params.price
  }
  { status: 201, json: product }
)

app:put("/products/:id", (self) =>
  product = Product:find! self.params.id
  unless product
    return { status: 404, json: { error: "Product not found" } }

  product:update! {
    name: self.params.name or product.name
    category_id: self.params.category_id or product.category_id
    price: self.params.price or product.price
  }
  { json: product }
)

app:delete("/products/:id", (self) =>
  product = Product:find! self.params.id
  unless product
    return { status: 404, json: { error: "Product not found" } }
  product:delete!
  { json: { message: "Product deleted" } }
)

return app
