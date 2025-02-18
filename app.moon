import autoload from require "lapis.util"
autoload "models"

lapis = require "lapis"
import Model from require "lapis.db.model"
import respond_to from require "lapis.application"
import json_params from require "lapis.application"
import capture_errors, validation_error  from require "lapis.application"
google = require "cloud_storage.google"

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
      file_param = @params.file
      if file_param and file_param.filename and file_param.content then

        content_type = file_param.content_type
        filename_on_gcs = string.format(
          "products/%d_%d.png",
          ngx.time(), math.random(9999)
        )
        storage = google.CloudStorage\from_json_key_file("booming-tooling-355400-0d01768ab786.json")
        ok, err = storage\put_file_string "moonscriptapi", filename_on_gcs, file_param.content, { 
          mimetype: "image/png" }

        if not ok
          return status: 400, json: { error: "Upload failed Reason: #{ok} Errorout: #{err}" }
        
        image_url = "https://storage.googleapis.com/moonscriptapi/#{filename_on_gcs}"
        
        product = Products\create({
          name: @params.name,
          price: @params.price,
          category_id: tonumber(@params.id),
          description: @params.description,
          amount: @params.amount,
          imageurl: image_url
        })
        
        
        json: product
      else
        product = Products\create {
          name: @params.name
          price: @params.price
          category_id: tonumber(@params.id)
          description: @params.description
          amount: @params.amount
        }
        json: product
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
  