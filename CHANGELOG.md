## Changelog

### v2.0.0
#### Additions
* Added API User model.
* Added user permissions.

#### Bug Fixes
* Exif Data now gets invalid UTF-8 characters removed. This should prevent
  'invalid byte sequence' errors.
* Fixes a problem where trimming imported video stills wasn't working.

#### Changes
* [BREAKING] API - Moved `Utility#as_asset` into Assets endpoint `#create`.
* Updated mini_exiftool to 2.3.0
* Increased sphinx's MAX_MATCHES for search results.
