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

AssetHost is an [Ember](https://emberjs.com/) application running on a [Rails](https://rubyonrails.org/) backend.

### Quick Start

The fastest way to get AssetHost up and running is to deploy to [Docker Cloud](https://cloud.docker.com):

[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https%3A%2F%2Fgithub.com%2Fscpr%2Fassethost)

For running AssetHost on a dev machine, it's highly recommended to use [Docker](https://www.docker.com/) w/ [Docker Compose](https://docs.docker.com/compose/).  Why, you might ask?  Here's why:

- Docker images are reproducible builds of applications with their environments.  This simplifies setup and reduces the possibility of issues created by differing dependency versions.
- A developer can easily have the production environment replicated on their machine and manage those simultaneously with other software installed natively or with Docker.
- Docker and Docker Compose reduce the burden on DevOps, allowing them to focus on maintenance and less on managing dependencies. 

#### Instructions

1. Install [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/).
2. Clone this repo and enter its directory in your command line terminal.
3. Build the server context image by running `docker-compose build ruby`.  This will install dependencies such as Ruby, Node.js, Imagemagick, etc.  This can take several minutes.  You'll only have to do this once.
3. Run `docker-compose up -d`.  This will pull the necessary images and run the containers.
4. Run `docker-compose run ruby bin/setup`.  This pulls in dependencies for Rails and Ember, and performs other setup procedures.  As with the build step, this may take some time.
5. Finally, run `docker-compose run --service-ports ruby bin/server`.

The AssetHost web application will be available at http://localhost:8080

You will be prompted to log in.  The database has been initialized with a user named `admin` with `password` as the password.

To enter the Rails console, run `docker-compose run ruby bin/rails c`.

### Native Development

It is, of course, possible to develop the app using natively-installed dependencies.

#### Prerequisites

Minimum Requirements:

- Ruby >= 2.3
- MongoDB
- Redis
- Elasticsearch
- Imagemagick
- Exiftool
- S3-compatible storage medium([Riak CS](https://github.com/basho/riak_cs), [Fake S3](https://github.com/jubos/fake-s3), or [AWS S3](https://aws.amazon.com/s3/) itself.)

#### Instructions

Be sure that MySQL, Elasticsearch, Redis, Imagamagick, Exiftool, and an S3-compatible storage medium are running and available on the host machine.  They can either be available natively or run using Docker; whichever you choose, the result should be the same.

1. If you haven't done so already, install [Bundler](https://bundler.io/) by running `gem install bundler`.
2. Clone this repo and enter its directory in your command line terminal.
3. Run `bundle install`.
4. Copy `templates/.env.development` to the root of your cloned AssetHost directory.  With a standard configuration(services using their standard ports on localhost, etc.), you shouldn't have to change anything in this file out of the box.  The reason you must perform this step is so secrets don't accidentally get committed to source control.
5. Run `bin/setup`.

Upon completion of those steps, start the server by running `bundle exec rails s`.

The web application will be available at http://localhost:3000.

You will be prompted to log in.  The database has been initialized with a user named **admin** with **password** as the password.


### Production

It's suggested that you use Docker and a container management solution like [Rancher](https://rancher.com/).  The `docker-cloud.yml` file can be adapted into configuration used for production.  The `docker-compose.yml` file is intended mainly for development, not deployment.


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

