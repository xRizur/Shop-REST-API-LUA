local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
local cjson = require("cjson")
local base_url = "http://localhost:8080"
local doRequest
doRequest = function(method, path, data)
  local full_url = base_url .. path
  local headers = { }
  local source = nil
  if data == nil then
    local json_str = cjson.encode(data)
    headers["Content-Type"] = "application/json"
    headers["Content-Length"] = #json_str
    source = ltn12.source.string(json_str)
  end
  local response_body = { }
  local res, code, response_headers = http.request({
    method = method,
    url = full_url,
    headers = headers,
    source = source,
    sink = ltn12.sink.table(response_body)
  })
  local body_str = table.concat(response_body)
  return body_str, code, response_headers
end
local parseJSON
parseJSON = function(body)
  local ok, result = pcall(cjson.decode, body)
  if ok then
    return result
  else
    return nil
  end
end
local tests = { }
tests.testRoot = function()
  print("\n[TEST] GET / (root)")
  local body, code, headers = doRequest("GET", "/")
  assert(code == 200, "Oczekiwany kod 200 dla /")
  assert({
    body = find("Lapis MoonScript Products Catalog REST API")
  }, "Brak oczekiwanego tekstu w HTML")
  return print("OK: Strona główna zawiera oczekiwany tytuł.")
end
tests.testGetCategoriesEmpty = function()
  print("\n[TEST] GET /categories (lista kategorii)")
  local body, code, headers = doRequest("GET", "/categories")
  assert(code == 200, "Oczekiwany kod 200 dla GET /categories")
  local data = parseJSON(body)
  assert(type(data(is("table", "Oczekiwano tablicy (JSON array)"))))
  return print("OK: Otrzymano listę kategorii, ilość: " .. (#data))
end
tests.testCreateCategory = function()
  print("\n[TEST] POST /categories (utworzenie kategorii)")
  local catData = {
    name = "Test Category",
    description = "Kategoria testowa"
  }
  local body, code, headers = doRequest("POST", "/categories", catData)
  assert(code == 200, "Oczekiwany kod 200 dla POST /categories")
  local data = parseJSON(body)
  assert(data.name == catData.name, "Błędna wartość name")
  assert(data.description == catData.description, "Błędna wartość description")
  assert(data.id, "Brak id nowej kategorii")
  tests.createdCategoryId = data.id
  return print("OK: Utworzono kategorię z id: " .. data.id)
end
tests.testGetCategory = function()
  print("\n[TEST] GET /categories/:id (pobranie kategorii)")
  local id = tests.createdCategoryId
  local body, code, headers = doRequest("GET", "/categories/" .. id)
  assert(code == 200, "Oczekiwany kod 200 dla GET /categories/" .. id)
  local data = parseJSON(body)
  assert(data.id == id, "Pobrana kategoria ma inne id")
  return print("OK: Pobranie kategorii o id: " .. id)
end
tests.testUpdateCategory = function()
  print("\n[TEST] PUT /categories/:id (aktualizacja kategorii)")
  local id = tests.createdCategoryId
  local updateData = {
    name = "Updated Category",
    description = "Zaktualizowany opis"
  }
  local body, code, headers = doRequest("PUT", "/categories/" .. id, updateData)
  assert(code == 200, "Oczekiwany kod 200 dla PUT /categories/" .. id)
  local data = parseJSON(body)
  assert(data.name == updateData.name, "Pole name nie zostało zaktualizowane")
  return print("OK: Zaktualizowano kategorię o id: " .. id)
end
tests.testDeleteCategory = function()
  print("\n[TEST] DELETE /categories/:id (usunięcie kategorii)")
  local id = tests.createdCategoryId
  local body, code, headers = doRequest("DELETE", "/categories/" .. id)
  assert(code == 200, "Oczekiwany kod 200 dla DELETE /categories/" .. id)
  body, code, headers = doRequest("GET", "/categories/" .. id)
  local data = parseJSON(body)
  if data == nil then
    assert(next(data)(is(nil, "Kategoria nadal istnieje po usunięciu")))
  end
  return print("OK: Usunięto kategorię o id: " .. id)
end
tests.testCategoryForProducts = function()
  print("\n[TEST] Przygotowanie kategorii dla testów produktów")
  local catData = {
    name = "Product Category",
    description = "Kategoria dla produktów"
  }
  local body, code, headers = doRequest("POST", "/categories", catData)
  assert(code == 200, "Oczekiwany kod 200 dla POST /categories (produkty)")
  local data = parseJSON(body)
  tests.productCategoryId = data.id
  return print("OK: Utworzono kategorię dla produktów, id: " .. data.id)
end
tests.testGetProductsEmpty = function()
  print("\n[TEST] GET /categories/:id/products (lista produktów)")
  local catId = tests.productCategoryId
  local body, code, headers = doRequest("GET", "/categories/" .. catId .. "/products")
  assert(code == 200, "Oczekiwany kod 200 dla GET /categories/" .. catId .. "/products")
  local data = parseJSON(body)
  assert(type(data(is("table", "Oczekiwano tablicy (JSON array)"))))
  return print("OK: Lista produktów jest pusta lub zawiera " .. (#data) .. " rekordów.")
end
tests.testCreateProduct = function()
  print("\n[TEST] POST /categories/:id/products/new (utworzenie produktu)")
  local catId = tests.productCategoryId
  local prodData = {
    name = "Test Product",
    description = "Produkt testowy",
    price = 9.99,
    amount = 100
  }
  local path = "/categories/" .. catId .. "/products/new"
  local body, code, headers = doRequest("POST", path, prodData)
  assert(code == 200, "Oczekiwany kod 200 dla POST " .. path)
  local data = parseJSON(body)
  assert(data.name == prodData.name, "Błędna nazwa produktu")
  assert(data.id, "Brak id produktu")
  tests.createdProductId = data.id
  return print("OK: Utworzono produkt z id: " .. data.id)
end
tests.testGetProduct = function()
  print("\n[TEST] GET /categories/:category_id/products/:id (pobranie produktu)")
  local catId = tests.productCategoryId
  local prodId = tests.createdProductId
  local path = "/categories/" .. catId .. "/products/" .. prodId
  local body, code, headers = doRequest("GET", path)
  assert(code == 200, "Oczekiwany kod 200 dla GET " .. path)
  local data = parseJSON(body)
  assert(data.id == prodId, "Błędne id produktu")
  return print("OK: Pobranie produktu o id: " .. prodId)
end
tests.testUpdateProduct = function()
  print("\n[TEST] PUT /categories/:category_id/products/:id (aktualizacja produktu)")
  local catId = tests.productCategoryId
  local prodId = tests.createdProductId
  local updateData = {
    name = "Updated Product",
    description = "Zaktualizowany opis produktu",
    price = 19.99,
    amount = 50
  }
  local path = "/categories/" .. catId .. "/products/" .. prodId
  local body, code, headers = doRequest("PUT", path, updateData)
  assert(code == 200, "Oczekiwany kod 200 dla PUT " .. path)
  local data = parseJSON(body)
  assert(data.name == updateData.name, "Pole name nie zostało zaktualizowane")
  return print("OK: Zaktualizowano produkt o id: " .. prodId)
end
tests.testDeleteProduct = function()
  print("\n[TEST] DELETE /categories/:category_id/products/:id (usunięcie produktu)")
  local catId = tests.productCategoryId
  local prodId = tests.createdProductId
  local path = "/categories/" .. catId .. "/products/" .. prodId
  local body, code, headers = doRequest("DELETE", path)
  assert(code == 200, "Oczekiwany kod 200 dla DELETE " .. path)
  body, code, headers = doRequest("GET", path)
  local data = parseJSON(body)
  if data == nil then
    assert(next(data)(is(nil, "Produkt nadal istnieje po usunięciu")))
  end
  return print("OK: Usunięto produkt o id: " .. prodId)
end
for name, test in tests do
  print("\n===========================")
  print("Uruchamiam test: " .. name)
  test()
end
return print("\nWSZYSTKIE TESTY ZALICZONE!")
