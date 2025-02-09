-- tests/test_api.moon

socket = require "socket"
http = require "socket.http"
ltn12 = require "ltn12"
cjson = require "cjson"

base_url = "http://localhost:8080"

doRequest = (method, path, data) ->
  full_url = base_url .. path
  headers = {}
  source = nil
  if data
    json_str = cjson.encode data
    headers["Content-Type"] = "application/json"
    headers["Content-Length"] = #json_str
    source = ltn12.source.string json_str
  response_body = {}
  res, code, response_headers = http.request
    method: method
    url: full_url
    headers: headers
    source: source
    sink: ltn12.sink.table response_body
  body_str = table.concat response_body
  return body_str, code, response_headers

parseJSON = (body) ->
  ok, result = pcall cjson.decode, body
  if ok then result else nil

tests = {}

tests.testRoot = ->
  print "\n[TEST1] GET / (root)"
  body, code, headers = doRequest "GET", "/"
  assert code == 200, "Oczekiwany kod 200 dla /"
  assert string.find(body, "Lapis MoonScript Products Catalog REST API"), "Brak oczekiwanego tekstu w HTML"
  print "OK: Strona główna zawiera oczekiwany tytuł."

tests.testGetCategoriesEmpty = ->
  print "\n[TEST2] GET /categories (lista kategorii)"
  body, code, headers = doRequest "GET", "/categories"
  assert code == 200, "Oczekiwany kod 200 dla GET /categories"
  data = parseJSON body
  assert type data == "table", "Oczekiwano tablicy (JSON array)"
  print "OK: Otrzymano listę kategorii, ilość: " .. (#data)

tests.testCreateCategory = ->
  print "\n[TEST3] POST /categories (utworzenie kategorii)"
  catData = { name: "TestCategory" , description: "Test" }
  body, code, headers = doRequest "POST", "/categories", catData
  assert code == 200, "Oczekiwany kod 200 dla POST /categories"
  data = parseJSON body
  assert data.name == catData.name, "Błędna wartość name"
  assert data.description == catData.description, "Błędna wartość description"
  assert data.id, "Brak id nowej kategorii"
  tests.createdCategoryId = data.id
  print "OK: Utworzono kategorię z id: " .. data.id

tests.testGetCategory = ->
  print "\n[TEST4] GET /categories/:id (pobranie kategorii)"
  id = tests.createdCategoryId
  body, code, headers = doRequest "GET", "/categories/" .. id
  assert code == 200, "Oczekiwany kod 200 dla GET /categories/" .. id
  data = parseJSON body
  assert data.id == id, "Pobrana kategoria ma inne id"
  print "OK: Pobranie kategorii o id: " .. id

tests.testUpdateCategory = ->
  print "\n[TEST5] PUT /categories/:id (aktualizacja kategorii)"
  id = tests.createdCategoryId
  updateData = { name: "UpdatedCategory"}
  body, code, headers = doRequest "PUT", "/categories/" .. id, updateData
  assert code == 200, "Oczekiwany kod 200 dla PUT /categories/" .. id
  data = parseJSON body
  assert data.name == updateData.name, "Pole name nie zostało zaktualizowane"
  print "OK: Zaktualizowano kategorię o id: " .. id

tests.testDeleteCategory = ->
  print "\n[TEST6] DELETE /categories/:id (usunięcie kategorii)"
  id = tests.createdCategoryId
  body, code, headers = doRequest "DELETE", "/categories/" .. id
  assert code == 200, "Oczekiwany kod 200 dla DELETE /categories/" .. id
  body, code, headers = doRequest "GET", "/categories/" .. id
  data = parseJSON body
  if data
    assert next(data) is nil, "Kategoria nadal istnieje po usunięciu"
  print "OK: Usunięto kategorię o id: " .. id

tests.testCategoryForProducts = ->
  print "\n[TEST7] Przygotowanie kategorii dla testów produktów"
  catData = { name: "ProductCategory", description: "Product Category" }
  body, code, headers = doRequest "POST", "/categories", catData
  assert code == 200, "Oczekiwany kod 200 dla POST /categories (produkty)"
  data = parseJSON body
  tests.productCategoryId = data.id
  print "OK: Utworzono kategorię dla produktów, id: " .. data.id

tests.testGetProductsEmpty = ->
  print "\n[TEST8] GET /categories/:id/products (lista produktów)"
  catId = tests.productCategoryId
  body, code, headers = doRequest "GET", "/categories/" .. catId .. "/products"
  assert code == 200, "Oczekiwany kod 200 dla GET /categories/" .. catId .. "/products"
  data = parseJSON body
  assert type data == "table", "Oczekiwano tablicy (JSON array)"
  print "OK: Lista produktów jest pusta lub zawiera " .. (#data) .. " rekordów."

tests.testCreateProduct = ->
  print "\n[TEST9] POST /categories/:id/products/new (utworzenie produktu)"
  catId = tests.productCategoryId
  prodData = 
    name: "TestProduct"
    description: "Produkttestowy"
    price: 9.99
    amount: 100
  path = "/categories/" .. catId .. "/products/new"
  body, code, headers = doRequest "POST", path, prodData
  assert code == 200, "Oczekiwany kod 200 dla POST " .. path
  data = parseJSON body
  assert data.name == prodData.name, "Błędna nazwa produktu"
  assert data.id, "Brak id produktu"
  tests.createdProductId = data.id
  print "OK: Utworzono produkt z id: " .. data.id

tests.testGetProduct = ->
  print "\n[TEST10] GET /categories/:category_id/products/:id (pobranie produktu)"
  catId = tests.productCategoryId
  prodId = tests.createdProductId
  path = "/categories/" .. catId .. "/products/" .. prodId
  body, code, headers = doRequest "GET", path
  assert code == 200, "Oczekiwany kod 200 dla GET " .. path
  data = parseJSON body
  assert data.id == prodId, "Błędne id produktu"
  print "OK: Pobranie produktu o id: " .. prodId

tests.testUpdateProduct = ->
  print "\n[TEST11] PUT /categories/:category_id/products/:id (aktualizacja produktu)"
  catId = tests.productCategoryId
  prodId = tests.createdProductId
  updateData = 
    name: "Updated Product"
    description: "Zaktualizowany opis produktu"
    price: 19.99
    amount: 50
  path = "/categories/" .. catId .. "/products/" .. prodId
  body, code, headers = doRequest "PUT", path, updateData
  assert code == 200, "Oczekiwany kod 200 dla PUT " .. path
  data = parseJSON body
  assert data.name == updateData.name, "Pole name nie zostało zaktualizowane"
  print "OK: Zaktualizowano produkt o id: " .. prodId

tests.testDeleteProduct = ->
  print "\n[TEST12] DELETE /categories/:category_id/products/:id (usunięcie produktu)"
  catId = tests.productCategoryId
  prodId = tests.createdProductId
  path = "/categories/" .. catId .. "/products/" .. prodId
  body, code, headers = doRequest "DELETE", path
  assert code == 200, "Oczekiwany kod 200 dla DELETE " .. path
  body, code, headers = doRequest "GET", path
  data = parseJSON body
  if data
    assert next(data) is nil, "Produkt nadal istnieje po usunięciu"
  print "OK: Usunięto produkt o id: " .. prodId

tests.testRoot!
tests.testGetCategoriesEmpty!
tests.testCreateCategory!
tests.testGetCategory!
tests.testUpdateCategory!
tests.testDeleteCategory!
tests.testCategoryForProducts!
tests.testGetProductsEmpty!
tests.testCreateProduct!
tests.testGetProduct!
tests.testUpdateProduct!
tests.testDeleteProduct!

print "\nWSZYSTKIE TESTY ZALICZONE!"
