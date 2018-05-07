AssetHost
=========

📸 AssetHost is a one-stop-shop for hosting and linking to media assets that are intended for inclusion in news stories.

[![Build Status](https://travis-ci.org/SCPR/AssetHost.png)](https://travis-ci.org/SCPR/AssetHost)

The goal is to create a hub that multiple frontend CMS systems can hook into, querying images, videos and documents from one source and enabling the easier interchange of data.

AssetHost includes:

- 💽 A server application provides the primary UI for uploading, managing, and  
serving assets.
- 🔌 An API endpoint that can be accessed by other applications or plugins.
- 👆 A Chooser UI that can be integrated into your application with a minimal amount of code.

Plus:

- A powerful search function built on [Elasticsearch](https://www.elastic.co/products/elasticsearch) & [Searchkick](https://github.com/ankane/searchkick).
- Automatic tagging of image features using deep-learning through [Amazon Rekognition](https://aws.amazon.com/rekognition/), allowing for images to become searchable upon upload with no user intervention.


## Getting Started

### Prerequisites

Minimum Requirements:

- Ruby
- Docker
- MySQL

*The minimum requirements will get the application up and running, but many features will not work.  For production functionality, you will need the following:*

- Redis
- Elasticsearch
- Memcached

### Setup

#### Development

AssetHost is a [Rails](http://rubyonrails.org/)-based application.

The most straight-forward way to setup AssetHost is to use [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) with a pre-built image.

```sh
docker-compose up -d
docker-compose exec assethost setup
```

The web application will then be available at [localhost:8080](http://localhost:8080).

For code modification, you will need to have [Ruby](https://ruby-lang.org) installed natively.

Make sure you have the prerequisite services running.  You can either have them installed natively, or you can use the `docker-compose.yml` file to run them with containers:

```sh
docker-compose up -d mysql elasticsearch redis s3
```

Then run the setup to pull in dependencies and initialize the database

```sh
./bin/setup
```

Finally, run the server:

```sh
rails s
```

The web application will be available at [localhost:3000](http://localhost:3000).

On first use, you will be required to log in.  An initial user called **admin** already exists with the password **password**.  Use those credentials to log in, and then promptly change the password to a more suitable one.


#### Production

It's suggested that you use Docker and a container management solution like [Rancher](https://rancher.com/).  The `docker-compose.yml` file included with this project is meant to be used for development, but can also be adapted into configuration used for production.


## Workflow

1. Photographer / Author / Editor goes to AssetHost and uploads or imports a media asset.

2. Author / Editor goes to their frontend CMS and uses the plugin UI to select the asset they want to attach to their content (which might be a story, a blog post, etc).

3. CMS plugin uses API to query AssetHost and retrieve presentation code for the asset.  

4. The CMS should call new AssetHost.Client() to put in place the handler for rich assets.

4. The CMS should display the image asset.  If it contains tags for a rich asset, the Client library will catch it and put in place the appropriate handling.

5. AssetHost will return a 302 Found to the rendered image asset if it exists, or render it on-the-fly if it does not yet exist.


## Image Storage

AssetHost supports Amazon S3 as a storage backend.  For in-house storage, you can use [Riak CS](https://github.com/basho/riak_cs), which implements the S3 API and can be used in the same way.  For AssetHost to work properly, AWS credentials for S3 need to be set as these environment variables:

- ASSETHOST_S3_BUCKET
- ASSETHOST_S3_REGION
- ASSETHOST_S3_ACCESS_KEY_ID
- ASSETHOST_S3_SECRET_ACCESS_KEY

When using Riak, you can provide the host under the `ASSETHOST_S3_ENDPOINT` and comment out the `ASSETHOST_S3_REGION` variable.

Local filesystem storage may be implemented in the future.


## Rich Media Support

Rich media assets are delivered as specially-tagged img tags, and are replaced on the client-side via an AssetHost.Client plugin.

### Brightcove Video

Brightcove videos can be imported as assets and used to place videos into image display contexts. The video is delivered as an img tag, and the AssetHost.Client library will see the tag and call the AssetHost.Client.Brightcove plugin. The plugin will replace the asset with the video.

Brightcove assets can be imported via a key in the URL Input field.

## Feature Recognition

For the purpose of improving ease of searchability, AssetHost can tie into Amazon's Rekognition service which uses computer-vision to classify features inside a given image.  When enabled, photos are automatically populated with keywords without any user intervention.  For example, a photo of people mountain biking will be immediately searchable with queries like "bicycle" or "outdoors" upon upload even when no metadata is provided.  This optional feature can be enabled when AWS credentials are set in the following environment variables:

- ASSETHOST_REKOGNITION_REGION
- ASSETHOST_REKOGNITION_ACCESS_KEY_ID
- ASSETHOST_REKOGNITION_SECRET_ACCESS_KEY


## API

See the [API documentation](https://github.com/SCPR/AssetHost/blob/master/API.md).


### Prerequisites

The application requires the following prerequisites:

- Ruby >= 2.3
- Rails >= 5.0.0
- Imagemagick
- Exiftool
- MySQL
- Redis
- Elasticsearch >= 1.6.0
- Memcached


### Adding Custom Functionality

AssetHost can be extended by writing a [Rails plugin](http://guides.rubyonrails.org/plugins.html).  If you need to add organization-specific code, it's suggested that you write that code into a plugin before you decide to fork the AssetHost codebase for the same purpose.  This ensures that you can easily version-control your own code while being able to easily upgrade the AssetHost core.

KPCC has an open-source [plugin](https://github.com/SCPR/asset_host_kpcc) that extends AssetHost for their own needs, and you can use that as a reference for how to write your own plugin.

It's recommended that if you are going to add plugins to your AssetHost instance, that you create your own Dockerfile that builds off the main AssetHost image.

```sh
FROM scprdev/assethost

# ... custom configuration
```

So a Dockerfile that adds the KPCC plugin would look something like this:

```sh
FROM scprdev/assethost

RUN echo "gem 'asset_host_kpcc', github: 'scpr/asset_host_kpcc'" >> Gemfile
RUN bundle install
```

The image would be built just like the main image, with a different tag:

```sh
docker build -t assethost-custom .
```

Even simpler, you can make a GitHub repo for your Dockerfile and set up an [automated build process](https://docs.docker.com/docker-hub/builds/) in [Docker Hub](https://hub.docker.com/).


## Credits

AssetHost is being developed to serve the media asset needs of [KPCC](https://scpr.org) and Southern California Public Radio, a member-supported public radio network that serves Los Angeles and Orange County on 89.3, the Inland Empire on 89.1, and the Coachella Valley on 90.3.

AssetHost development is currently led by Ben Titcomb and was originally written by Eric Richardson & Bryan Ricker.

