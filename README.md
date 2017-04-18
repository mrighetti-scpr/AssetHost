AssetHost
=========

📸 AssetHost is a one-stop-shop for hosting and linking to media assets that are intended for inclusion in news stories.

[![Build Status](https://travis-ci.org/SCPR/AssetHost.png)](https://travis-ci.org/SCPR/AssetHost)

The goal is to create a hub that multiple frontend CMS systems can hook into, querying images, videos and documents from one source and enabling the easier interchange of data.

AssetHost includes:

- 💽 A server application provides the primary UI for uploading, managing, and  
serving assets.
- 🔌 An API endpoint that can be accessed by other applications or plugins.
- 🖥️ A Chooser UI that can be integrated into your application with a minimal amount of code.

Plus:

- A powerful search function built on [Elasticsearch](https://www.elastic.co/products/elasticsearch) & [Searchkick](https://github.com/ankane/searchkick).
- Automatic tagging of image features using deep-learning through [Amazon Rekognition](https://aws.amazon.com/rekognition/), allowing for images to become searchable upon upload with no user intervention.


## Getting Started

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

### Setup

Once the necessary prerequisites are installed, you will need to clone this repository and add a **.env** file to the project root with configuration values.  This file will automatically supply the environment variables the application will use to connect to services and APIs.  You can find a sample **.env** file in `config/templates/.env.template`.

#### Image Storage

AssetHost supports Amazon S3 as a storage backend.  For in-house storage,
you can use [Riak CS](https://github.com/basho/riak_cs), which implements
the S3 API and can be used in the same way.  For AssetHost to work properly, AWS credentials for S3 need to be set as these environment variables:
```sh
ASSETHOST_S3_BUCKET=<insert value here>
ASSETHOST_S3_REGION=<insert value here>
ASSETHOST_S3_ACCESS_KEY_ID=<insert value here>
ASSETHOST_S3_SECRET_ACCESS_KEY=<insert value here>
```

Local filesystem storage may be implemented in the future.


Once your **.env** file is in order, run `bin/setup`.  This will install Ruby dependencies, initialize the database, and start the AssetHost application.  Those steps can be executed separately in the following way:

* Install Ruby dependencies
```sh
bundle install
```

* Initialize the database
```sh
rake db:create
rake db:schema:load
rake db:seed
```

* Run the Rails server
```sh
rails s
```

The application will be accessible at `http://localhost:3000`.

On first use, you will be required to log in.  An initial user called **admin** already exists with the password **password**.  Use those credentials to log in, and then promptly change the password to a more suitable one.




## Using Docker

AssetHost can be built into a [Docker](https://www.docker.com/) image using the provided Dockerfile.  It is recommended that you use a Docker image to deploy AssetHost, though building one may be an easy way to get the application up and running on a local machine.

```sh
docker build -t assethost .
```

Once the image has been created, you can run it in a container.  Here is an example of creating a container for the image long with a *.env* file to provide the necessary environment variables:

```sh
docker run -i -d -p 80:80 --name assethost --env-file .env.production assethost
```

Note that the `--name` parameter specifies the name of the container, and the last parameter is the name of the image.  `--name` can be left blank and Docker will assign a random name to it.  It's recommended that you pick a name and stick with it.

When running the container locally, if you have other containers running services such as MySQL, you can link them to your AssetHost container like this:

```sh
docker run -i -d -p 80:80 --name assethost --env-file .env.production --link mysql --link redis --link elasticsearch assethost
```

In your environment variables, you would set the host names for these services to the names of their respective containers:

```sh
ASSETHOST_DATABASE_HOST_NAME=mysql
ASSETHOST_RESQUE_HOST=redis
ASSETHOST_PUBSUB_HOST=redis
ASSETHOST_ELASTICSEARCH_HOST=elasticsearch
```

Once the container is running, you can run the application like this:

```sh
docker exec assethost server
```

Essentially, you are telling it to run the `server` script inside the assethost container.

To run a worker for asynchronous image encoding:

```sh
docker exec assethost worker
```



## Workflow

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




## Rich Media Support

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


### Async Workers

The AssetHost server uses Redis (via the Resque gem) to coordinate asynchronous processing of images.  Configure your Resque settings in **.env**.


## Credits

AssetHost is being developed to serve the media asset needs of [KPCC](https://scpr.org) 
and Southern California Public Radio, a member-supported public radio network that 
serves Los Angeles and Orange County on 89.3, the Inland Empire on 89.1, and the 
Coachella Valley on 90.3.

AssetHost development is currently led by Ben Titcomb and was originally written by
Eric Richardson & Bryan Ricker.

