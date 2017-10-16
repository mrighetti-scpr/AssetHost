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

Alternatively, the same POST request can deliver an image directly in the request body.  The simplest way to do this is as a normal file upload with the binary data as the body and the `Content-Type` in the header.  Or you can upload the image with other data as a form.  These are the following form keys you will need:

- **image:** The binary image data.
- **title:** Custom image title.
- **owner:** Owner name.
- **caption:** Custom image caption.
- **image_gravity:** Custom image gravity.
- **image_created:** Custom image timestamp.
- **notes:** Notes used internally about the image.
- **content_type:** Custom content type.  This parameter is not required because if no content type is specified either in this parameter or the `X_CONTENT_TYPE` header, the content type will be assumed by the file extension.  However, it's recommended you be specific and provide a content type MIME type.

With a binary upload, the `X_FILE_UPLOAD` header **must** be set to true.  This can be omitted when using form data.

These headers are optional:

- **X_FILE_NAME:** The file name of the asset being uploaded.
- **X_CONTENT_TYPE:** The MIME type of the asset file.

**Put:** `/api/assets/{id}`

A PUT request should exhibit identical behavior to a POST request.

**Delete:** `/api/assets/{id}`

### Outputs

#### Operations

**List:** `/api/outputs`

**Get:** `/api/outputs/{id}`

