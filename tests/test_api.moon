socket   = require "socket"
http     = require "socket.http"
ltn12    = require "ltn12"
cjson    = require "cjson"

base_url = "http://localhost:8080"

doRequest = (method, path, data) ->
  full_url = base_url .. path
  headers  = {}
  source   = nil
  if data
    json_str = cjson.encode data
    headers["Content-Type"]   = "application/json"
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

doMultipartRequest = (method, path, fields, fileFieldName, filePath, fileMime) ->
  boundary = "----WebKitFormBoundary" .. tostring(math.random(1000000000))
  dataParts = {}

  for key, value in pairs(fields)
    dataParts[#dataParts+1] = (
      "--" .. boundary .. "\r\n" ..
      'Content-Disposition: form-data; name="' .. key .. "\"\r\n\r\n" ..
      tostring(value) .. "\r\n"
    )

  fileName = string.match(filePath, "[^/]+$")
  f = io.open filePath, "rb"
  fileContent = f\read("*all")
  f\close!

  dataParts[#dataParts+1] = (
    "--" .. boundary .. "\r\n" ..
    'Content-Disposition: form-data; name="' .. fileFieldName .. '"; filename="' .. fileName .. "\"\r\n" ..
    "Content-Type: " .. fileMime .. "\r\n\r\n" ..
    fileContent .. "\r\n"
  )

  dataParts[#dataParts+1] = "--" .. boundary .. "--\r\n"

  bodyData = table.concat dataParts
  headers = {
    ["Content-Type"]: "multipart/form-data; boundary=" .. boundary,
    ["Content-Length"]: #bodyData
  }

  response_body = {}
  full_url = base_url .. path
  res, code, response_headers = http.request({
    method: method,
    url: full_url,
    headers: headers,
    source: ltn12.source.string(bodyData),
    sink: ltn12.sink.table(response_body)
  })

  return table.concat(response_body), code, response_headers
  
tests = {}

tests.testRoot = ->
  print "\n[TEST1] GET / (root)"
  body, code, headers = doRequest "GET", "/"
  assert code == 200, "Expected code 200 for /"
  assert string.find(body, "Lapis MoonScript Products Catalog REST API"), "Expected text not found in HTML"
  print "OK: Homepage contains the expected title."

tests.testGetCategoriesEmpty = ->
  print "\n[TEST2] GET /categories (list of categories)"
  body, code, headers = doRequest "GET", "/categories"
  assert code == 200, "Expected code 200 for GET /categories"
  data = parseJSON body
  assert type data == "table", "Expected an array (JSON array)"
  print "OK: Received list of categories, count: " .. (#data)

tests.testCreateCategory = ->
  print "\n[TEST3] POST /categories (create category)"
  catData = { name: "TestCategory", description: "Test" }
  body, code, headers = doRequest "POST", "/categories", catData
  assert code == 200, "Expected code 200 for POST /categories"
  data = parseJSON body
  assert data.name == catData.name, "Incorrect name value"
  assert data.description == catData.description, "Incorrect description value"
  assert data.id, "Missing id for new category"
  tests.createdCategoryId = data.id
  print "OK: Created category with id: " .. data.id

tests.testGetCategory = ->
  print "\n[TEST4] GET /categories/:id (retrieve category)"
  id = tests.createdCategoryId
  body, code, headers = doRequest "GET", "/categories/" .. id
  assert code == 200, "Expected code 200 for GET /categories/" .. id
  data = parseJSON body
  assert data.id == id, "Retrieved category has a different id"
  print "OK: Retrieved category with id: " .. id

tests.testUpdateCategory = ->
  print "\n[TEST5] PUT /categories/:id (update category)"
  id = tests.createdCategoryId
  updateData = { name: "UpdatedCategory" }
  body, code, headers = doRequest "PUT", "/categories/" .. id, updateData
  assert code == 200, "Expected code 200 for PUT /categories/" .. id
  data = parseJSON body
  assert data.name == updateData.name, "Name field was not updated"
  print "OK: Updated category with id: " .. id

tests.testDeleteCategory = ->
  print "\n[TEST6] DELETE /categories/:id (delete category)"
  id = tests.createdCategoryId
  body, code, headers = doRequest "DELETE", "/categories/" .. id
  assert code == 200, "Expected code 200 for DELETE /categories/" .. id
  body, code, headers = doRequest "GET", "/categories/" .. id
  data = parseJSON body
  if data
    assert next(data) is nil, "Category still exists after deletion"
  print "OK: Deleted category with id: " .. id

tests.testCategoryForProducts = ->
  print "\n[TEST7] POST Create category for product tests"
  catData = { name: "ProductCategory", description: "Product Category" }
  body, code, headers = doRequest "POST", "/categories", catData
  assert code == 200, "Expected code 200 for POST /categories (products)"
  data = parseJSON body
  tests.productCategoryId = data.id
  print "OK: Created category for products, id: " .. data.id

tests.testGetProductsEmpty = ->
  print "\n[TEST8] GET /categories/:id/products (list of products)"
  catId = tests.productCategoryId
  body, code, headers = doRequest "GET", "/categories/" .. catId .. "/products"
  assert code == 200, "Expected code 200 for GET /categories/" .. catId .. "/products"
  data = parseJSON body
  assert type data == "table", "Expected an array (JSON array)"
  print "OK: The product list is empty or contains " .. (#data) .. " records."

tests.testCreateProductWithImage = ->
  print "\n[TEST9] POST /categories/:id/products/new (create product with image)"
  catId = tests.productCategoryId
  prodData = 
    name: "ImageProduct"
    description: "Product with image"
    price: 15.99
    amount: 20
  fields = {
    name: prodData.name,
    description: prodData.description,
    price: prodData.price,
    amount: prodData.amount,
    category_id: tostring(catId)
  }
  fileFieldName = "file"        
  filePath      = "test.png"      
  fileMime      = "image/png"
  path = "/categories/" .. catId .. "/products/new"
  body, code, headers = doMultipartRequest "POST", path, fields, fileFieldName, filePath, fileMime
  assert code == 200, "Expected code 200 for POST " .. path
  data = parseJSON body
  assert data.name == prodData.name, "Incorrect product name"
  assert data.id, "Missing product id"
  assert data.imageurl, "Image URL not set"
  tests.createdProductWithImageId = data.id
  print "OK: Created product with image, id: " .. data.id

tests.testGetProduct = ->
  print "\n[TEST10] GET /categories/:category_id/products/:id (retrieve product)"
  catId  = tests.productCategoryId
  prodId = tests.createdProductWithImageId
  path = "/categories/" .. catId .. "/products/" .. prodId
  body, code, headers = doRequest "GET", path
  assert code == 200, "Expected code 200 for GET " .. path
  data = parseJSON body
  assert data.id == prodId, "Incorrect product id"
  print "OK: Retrieved product with id: " .. prodId .." and result:"
  print(string.gsub(body, "\\/", "/"))

tests.testRoot!
tests.testGetCategoriesEmpty!
tests.testCreateCategory!
tests.testGetCategory!
tests.testUpdateCategory!
tests.testDeleteCategory!
tests.testCategoryForProducts!
tests.testGetProductsEmpty!
tests.testCreateProductWithImage!
tests.testGetProduct!

print "\nALL TESTS PASSED!"
