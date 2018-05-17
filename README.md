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


## Workflow

1. Photographer / Author / Editor goes to AssetHost and uploads or imports a media asset.

2. Author / Editor goes to their frontend CMS and uses the plugin UI to select the asset they want to attach to their content (which might be a story, a blog post, etc).

3. CMS plugin uses API to query AssetHost and retrieve presentation code for the asset.  

4. The CMS should call new AssetHost.Client() to put in place the handler for rich assets.

4. The CMS should display the image asset.  If it contains tags for a rich asset, the Client library will catch it and put in place the appropriate handling.

5. AssetHost will return a 302 Found to the rendered image asset if it exists, or render it on-the-fly if it does not yet exist.


## Getting Started

### Quick Start

The quickest way to get AssetHost up and running on your machine is to use [Docker](https://www.docker.com/) w/ [Docker Compose](https://docs.docker.com/compose/) and a pre-built AssetHost image.

#### Instructions

1. Install **Docker** and **Docker Compose**.
2. Clone this repo and enter its directory in your command line terminal.
3. Run `docker-compose up -d`.  This will pull the necessary images and run the containers.
4. Run `docker-compose exec assethost setup`

The AssetHost web application will be available at http://localhost:8080

You will be prompted to log in.  The database has been initialized with a user named `admin` with `password` as the password.

### Development

AssetHost is an [Ember](https://emberjs.com/) application running on a [Rails](https://rubyonrails.org/) backend.

### Prerequisites

Minimum Requirements:

- Ruby >= 2.3
- MySQL
- Redis
- Elasticsearch
- Imagemagick
- Exiftool
- S3-compatible storage medium([Riak CS](https://github.com/basho/riak_cs), [Fake S3](https://github.com/jubos/fake-s3), or [AWS S3](https://aws.amazon.com/s3/) itself.)

Recommended Requirements (see note below):

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

*NOTE: It's highly recommended that you install [Ruby](https://ruby-lang.org) natively and use Docker Compose to run the other prerequisite services.  To do this, run `docker-compose up -d` after cloning this repo.  You can certainly run those services natively, but Docker installation is much easier and allows simpler management of those services.*

### Instructions

Be sure that MySQL, Elasticsearch, Redis, Imagamagick, Exiftool, and an S3-compatible storage medium are running and available on the host machine.

1. If you haven't done so already, install [Bundler](https://bundler.io/) by running `gem install bundler`.
2. Clone this repo and enter its directory in your command line terminal.
3. Run `bundle install`.
4. Copy `templates/.env.development` to the root of your cloned AssetHost directory.  With a standard configuration(services using their standard ports on localhost, etc.), you shouldn't have to change anything in this file out of the box.  The reason you must perform this step is so secrets don't accidentally get committed to source control.
5. Run `bin/setup`.

Upon completion of those steps, start the server by running `bundle exec rails s`.

The web application will be available at http://localhost:3000.

You will be prompted to log in.  The database has been initialized with a user named **admin** with **password** as the password.

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


### Production

It's suggested that you use Docker and a container management solution like [Rancher](https://rancher.com/).  The `docker-compose.yml` file included with this project is meant to be used for development, but can also be adapted into configuration used for production.


## API

See the [API documentation](https://github.com/SCPR/AssetHost/blob/master/API.md).

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

## Credits

AssetHost is being developed to serve the media asset needs of [KPCC](https://scpr.org) and Southern California Public Radio, a member-supported public radio network that serves Los Angeles and Orange County on 89.3, the Inland Empire on 89.1, and the Coachella Valley on 90.3.

AssetHost development is currently led by Ben Titcomb and was originally written by Eric Richardson & Bryan Ricker.

