## Changelog

### v2.0.0
#### Additions
* Added API User model.
* Added user permissions.

#### Bug Fixes
* Exif Data now gets its encoding converted to UTF-8. This should prevent
  'invalid byte sequence' errors.

#### Changes
* [BREAKING] API - Moved `Utility#as_asset` into Assets endpoint `#create`.
