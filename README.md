#  Simple Storage 

A Ruby on Rails application provides a single API to store/retrieve files as blobs for multiple storage backends:

-   AWS S3 on MinIO
-   Database table
-   Local file system


#### Setting up the environment

copy `.env-example` into a new file with the name `.env`
populate the file with your environment variables. Please refer to `.env-example` for more details

#### Running the app
in the project root run:
 `docker compose up`


## API Reference

#### Create users 

```http
  POST /api/v1/users
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `username` | `string` | E.g. aziz |
| `password` | `string` | E.g. StrongP455w0rd! |

the data send as `application/json` content type and the parameters sent inside a `user` object:

```json
{
    "user": 
    {
        "username": "aziz",
        "password": "StrongP455w0rd!"
    }
}
```

#### Generate API Key 

```http
  POST api/v1/api-keys 
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `username` | `string` | **Required**. a registerd username |
| `password` | `string` | **Required**. a registerd password |

authorize a user using the HTTP `basic` authentication scheme

a successful response will contain `token` and will be used for all API operations

#### Upload a blob  

```http
  POST api/v1/blobs 
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `id` | `string` | unique id |
| `data` | `string` | file binary data encoded in base64 |

the data send as `application/json` content type and the parameters sent inside an object:

```json
{
    "id": "unique_id",
    "data": "FwYLKwYBBAGCNzwCAQITCERlbGF3YXJlMRAwDgYDVQQFU"
}
```

**Required**. use the generated API Token as `bearer` token 

a successful response will return the `id` of the uploaded blob

#### Retrieve a blob  

```http
  GET api/v1/blobs/{id}
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `id` | `string` | blob id |

**Required**. use the generated API Token as `bearer` token 

a successful response will return the blob and its metadata






