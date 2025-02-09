
-- lapis = require "lapis"

-- RoutesApp = require "routes"
-- lapis.serve RoutesApp

-- app.moon
lapis = require "lapis"
import Model from require "lapis.db.model"
import respond_to from require "lapis.application"
import json_params from require "lapis.application"

class Categories extends Model
  @relations: {
    {"products", has_many: "products"}
  }

class Products extends Model

class extends lapis.Application
  
  "/categories": respond_to {
    GET: => 
      categories = Categories\select!
      json: categories
    POST: json_params =>
      category = Categories\create {
        name: @params.name
        description: @params.description
      }
      json: category
    }


  "/categories/:id[%d]": respond_to {
    GET: =>
      category = Categories\find id: @params.id
      json: category

    PUT: json_params =>
      category = Categories\find id: @params.id
      category\update @params
      json: category

    DELETE: =>
      category = Categories\find id: @params.id
      category\delete!
      render: true
  }

  "/categories/:id[%d]/products": respond_to {
    GET: => 
      products = Products\select "where category_id = ?", @params.id
      json: products
    }

  "/categories/:id[%d]/products/new": respond_to {
    POST: json_params =>
      thing = Products\create {
        name: @params.name
        price: @params.price
        category_id: tonumber(@params.id)
        description: @params.description
        amount: @params.amount
      }
      json: thing
  }

  "/categories/:category_id[%d]/products/:id[%d]": respond_to {
    GET: =>
      product = Products\find id: @params.id
      json: product

    PUT: json_params =>
      product = Products\find id: @params.id
      product\update @params
      json: product

    DELETE: =>
      product = Products\find @params.id
      product\delete!
      render: true
  }
  
  "/": =>
    @html ->
      h1 "Lapis MoonScript Products Catalog REST API"

      h2 "List of endpoints:"

      h3 "Categories"

      p "- GET /categories"
      
      p "- POST /categories/new -json params- name: String, description: String"

      p "- GET /categories/[id]"

      p "- PUT /categories/[id] -json params- name: String, description: String"

      p "- DELETE /categories/[id]"

      h3 "Products"

      p "- GET /categories/[category_id]/products"
      
      p "- POST /categories/[category_id]/products/new -json params- name: String, description: String, price: Double, amount: Integer"

      p "- GET /categories/[category_id]/products/[product_id]"

      p "- PUT /categories/[category_id]/products/[product_id] -json params- name: String, description: String, price: Double, amount: Integer"

      p "- DELETE /categories/[category_id]/products/[product_id]"