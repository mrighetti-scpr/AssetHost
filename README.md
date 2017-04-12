# AssetHost

[![Build Status](https://travis-ci.org/SCPR/AssetHost.png)](https://travis-ci.org/SCPR/AssetHost)

AssetHost is a one-stop-shop for hosting and linking to media assets that are 
intended for inclusion in news stories.  The goal is to create a hub that 
multiple frontend CMS systems can hook into, querying images, videos and documents
from one source and enabling the easier interchange of data.

# Philosophy

AssetHost is built around the idea that all web media assets need to 
have a static visual fallback, either to support limited-functionality 
devices or to support rendering of rich media assets in contexts where 
a rich implementation isn't desired.

AssetHost is intended to run as two pieces: a backend asset server and 
lightweight frontend plugins that attach to the CMS system.  The pieces 
should speak to each other using a secure API.


### Application

The server application provides the primary UI for uploading, managing, and  
serving assets. It also provides an API endpoint that can be accessed either 
by the local application (this is how much of the admin works) or by other 
applications or plugins.


### Plugins for Other Applications

AssetHost provides an API and a Chooser UI that can be integrated into 
your application, allowing you to integrate the system in a minimal amount 
of code.

_TODO: More documentation on CMS interaction. External Rails example. Django example._


### Workflow

1. Photographer / Author / Editor goes to AssetHost and uploads or imports 
a media asset.

2. Author / Editor goes to their frontend CMS and uses the plugin UI to 
select the asset they want to attach to their content (which might be a 
story, a blog post, etc).

3. CMS plugin uses API to query AssetHost and retrieve presentation code 
for the asset.  

4. The CMS should call new AssetHost.Client() to put in place the handler 
for rich assets.

4. The CMS should display the image asset.  If it contains tags for a 
rich asset, the Client library will catch it and put in place the 
appropriate handling.

5. AssetHost will return a 302 Found to the rendered image asset if it 
exists, or render it on-the-fly if it does not yet exist.

# Rich Media Support

Rich media assets are delivered as specially-tagged img tags, and are 
replaced on the client-side via an AssetHost.Client plugin.


### Brightcove Video

Brightcove videos can be imported as assets and used to place videos into 
image display contexts. The video is delivered as an img tag, and the 
AssetHost.Client library will see the tag and call the 
AssetHost.Client.Brightcove plugin. The plugin will replace the asset with
the video.

Brightcove assets can be imported via a key in the URL Input field. See
Importing Help for more.


# Setup

`rake db:schema:load`

# Development

A Dockerfile is included to make it easy to quickly spin up services required by AssetHost(MySQL, Redis, Elasticsearch) for development on a local machine.

Simply build the image:

`docker build -t assethost-services .`

And run the container:

`docker run -i -d -p 3306:3306 -p 6379:6379 -p 9200:9200 -p 9300:9300 assethost-services`

If you are using *docker-machine*, you can run `echo $DOCKER_HOST` to optain the IP address of the virtual machine and use it to connect to the services running on it at the specified ports.


# Image Storage

AssetHost supports Amazon S3 as a storage backend.  For in-house storage,
you can use [Riak CS](https://github.com/basho/riak_cs), which implements
the S3 API and can be used in the same way.

Local filesystem storage may be implemented in the future.

## Feature Recognition

For the purpose of improving ease of searchability, AssetHost can tie into
Amazon's Rekognition service which uses computer-vision to classify features
inside a given image.  When enabled, photos are automatically populated with
keywords without any user intervention.  For example, a photo of people 
mountain biking will be immediately searchable with queries like "bicycle"
or "outdoors" upon upload even when no metadata is provided.  This optional
feature can be enabled when AWS credentials are set in the following
environment variables:

- ASSETHOST_REKOGNITION_REGION
- ASSETHOST_REKOGNITION_ACCESS_KEY_ID
- ASSETHOST_REKOGNITION_SECRET_ACCESS_KEY


# External Requirements

### Async Workers via Redis

The AssetHost server uses Redis (via the Resque gem) to coordinate async 
processing of images.  Configure for your Redis setup in config/resque.yml.

### Image Processing via ImageMagick

AssetHost does image processing using ImageMagick.

### Text Search via Elasticsearch

Searches are done via Elasticsearch using the Searchkick gem.


# Credits

AssetHost is being developed to serve the media asset needs of [KPCC](https://scpr.org) 
and Southern California Public Radio, a member-supported public radio network that 
serves Los Angeles and Orange County on 89.3, the Inland Empire on 89.1, and the 
Coachella Valley on 90.3.

AssetHost development is currently led by Ben Titcomb and was originally written by
Eric Richardson & Bryan Ricker.

