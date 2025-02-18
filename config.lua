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