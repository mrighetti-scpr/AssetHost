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

The fastest way to get an instance of AssetHost up and running is to deploy to [Docker Cloud](https://cloud.docker.com):

[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https%3A%2F%2Fgithub.com%2Fscpr%2Fassethost)

If you aren't deploying with Docker, or if you want to run AssetHost on a development machine, you will need to install the following prerequisites:

- [Docker](https://www.docker.com/) w/ [Docker Compose](https://docs.docker.com/compose/)
- [Node.js](https://nodejs.org/) <~ 9.8.0
- [Ember CLI](https://ember-cli.com/) <~ 3.1.3
- [Ruby](https://ruby-lang.org) >= 2.5.0
- [Python](https://www.python.org) >= 2.7.0 (this is required for installing certain Node dependencies)
- [Imagemagick](https://www.imagemagick.org/)
- [Exiftool](https://www.sno.phy.queensu.ca/~phil/exiftool/)
- S3-compatible storage medium([Riak CS](https://github.com/basho/riak_cs), [Fake S3](https://github.com/jubos/fake-s3), or [AWS S3](https://aws.amazon.com/s3/) itself.)

For running AssetHost on a dev machine, it's highly recommended to use [Docker](https://www.docker.com/) w/ [Docker Compose](https://docs.docker.com/compose/) to run things like MongoDB, Elasticsearch, and Redis.  This allows the developer to use precise versions of those services so that the production environment can be closely replicated.

#### Instructions

1. Install your prerequisites if you haven't already done so.  Make sure MongoDB, Elasticsearch, and Redis are running.
2. Clone this repo and enter its directory in your command line terminal.
3. Install the Ruby package manager [Bundler](https://bundler.io) by running `gem install bundler`.
4. Run `bin/setup`.  This will install dependencies and initialize the database.
5. If all goes well, run `bin/server` to start the Rails server along with the Ember CLI build server, which will run in the background to rebuild frontend code on changes.

The web application will be available at [localhost:3000](http://localhost:3000).

You will be prompted to log in.  The database has been initialized with a user named **admin** with **password** as the password.


#### Further Development Notes

Why not wrap the entire development environment in Docker?  Technically, a savvy individual could easily make this happen.  However, it's not advised because the Ember CLI build system is very slow when running in a virtualized Docker container(which is what happens when you are using Docker for Mac or Docker Machine); this is a result of file operations being very slow between the host and the virtual machine.  It simply saves time on many fronts by having Rails and Ember installed on the development host.  It's possible that this issue does not exist on a Linux host, but we have not tested it.


### Production

It's suggested that you use Docker and a container management solution like [Rancher](https://rancher.com/).  The `docker-cloud.yml` file can be adapted into configuration used for production.  The `docker-compose.yml` file is intended mainly for development, not deployment.

The first time you run the AssetHost image in a container, you will need to run `bin/setup`.  If you were using Dockeer Compose, the command would be something like the following:

```sh
docker-compose -f docker-cloud.yml run --rm assethost setup
```


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

Rich media assets are delivered as specially-tagged img tags, and are replaced on the client-side via an `client.js`.


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

AssetHost development has been developed by Ben Titcomb and was originally written by Eric Richardson & Bryan Ricker.

