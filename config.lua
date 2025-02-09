-- -- config.lua
-- return {
--     postgres = "postgres://user:password@postgres:5432/shop_db",
--     port = 8080,
--     num_workers = 1,
--   }
  
local config = require("lapis.config")

config({"development", "production"}, {
  email_enabled = false,
  server = "nginx",
  postgres = {
    host = "postgres",
    user = "user",
    password = "password",
    database = "shop_db",
  }
})