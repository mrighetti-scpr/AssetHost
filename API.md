API Documentation
=================

The AssetHost API is a fairly straight-forward REST-like API.

## API Users

Users for the API are created in the admin panel at `/api_users`.  Each user is assigned permissions on if they can read/write certain resources.  At the moment, the only resources are **Asset** and **Output**.

When a user is created, they are automatically assigned an auth token.  This token should be sent through the `auth_token` parameter in each request.  In production, HTTPS should be used since this token has no inherent security features – it's merely an identifier for a user.

## Endpoints

### Assets

#### Operations

**List:** `/api/assets`

**Get:** `/api/assets/{id}`

**Post:** `/api/assets/`

A POST request can take the following parameters:

- **url:** The URL of the image on a remote server.  This is currently the only way to import an image using the API.  We will later add the ability to directly upload through the API.
- **caption:** Custom image caption.
- **owner:** Owner name.
- **title:** Custom image title.

Alternatively, the same POST request can deliver an image directly w/ the following **required** request headers set:

- **X_FILE_NAME:** The file name of the asset being uploaded.
- **CONTENT_TYPE:** The MIME type of the asset file.
- **HTTP_X_FILE_UPLOAD:** Set the value to `true` to signal a file upload to the HTTP server.

**Put:** `/api/assets/{id}`

A PUT request takes the following parameters:
- **caption:** Custom image caption.
- **owner:** Owner name.
- **title:** Custom image title.

Alternatively, the same PUT request can deliver an image directly w/ the following **required** request headers set:

- **X_FILE_NAME:** The file name of the asset being uploaded.
- **CONTENT_TYPE:** The MIME type of the asset file.
- **HTTP_X_FILE_UPLOAD:** Set the value to `true` to signal a file upload to the HTTP server.

**Delete:** `/api/assets/{id}`

### Outputs

#### Operations

**List:** `/api/outputs`

**Get:** `/api/outputs/{id}`

