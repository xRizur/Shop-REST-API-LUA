# Lapis MoonScript Products Catalog REST API

This project implements a REST API for a store, built using Lapis and MoonScript. It provides CRUD endpoints for categories and products, returns data as JSON, and supports uploading product images (PNG/JPG) to Google Cloud Storage (GCS).

## 🚀 Features

- **REST API** built with [Lapis](http://leafo.net/lapis/) in MoonScript.
- **Models** created using `lapis.db.model`.
- **Endpoints for Categories and Products** with full CRUD operations:
  - **Categories:** Create, read (single & list), update, delete.
  - **Products:** Create, read (single & list), update, delete.
- **Image Upload:** Product images (PNG/JPG) are uploaded to GCS using [leafo/cloud_storage](https://github.com/leafo/cloud_storage).
- **API Tests:** Implemented using LuaSocket and lua-cjson.
- **Docker Compose:** The entire application is containerized for easy setup and deployment by just docker-compose up

