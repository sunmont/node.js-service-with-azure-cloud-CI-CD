Docker and Azure App Service Deployment Guide 🐳
This guide provides a quick reference for building Docker images from a Dockerfile and docker-compose.yml, deploying them to Azure App Service, and understanding Azure's public endpoints.

Building Docker Images
From a Dockerfile
A Dockerfile is a text document that contains all the commands a user could call on the command line to assemble an image.

Create a Dockerfile: In your project root, create a file named Dockerfile.

Dockerfile

# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Bundle app source
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the app
CMD [ "npm", "start" ]
Build the Image: Run the docker build command from your project's directory. The -t flag tags your image with a name.

Bash

docker build -t my-node-app:1.0 .
From a docker-compose.yml File
You can build multiple images for a multi-container application using a single docker-compose.yml file.

Create a docker-compose.yml: Define your services in this file. Each service can have its own build context.

YAML

version: '3.8'

services:
  web:
    build: ./web_app
    ports:
      - "5000:5000"
    image: my-web-app:latest

  api:
    build: ./api_service
    ports:
      - "8000:8000"
    image: my-api-service:latest
Build the Images: Use the docker compose build command to build all images defined in the file.

Bash

docker compose build
To build the images and start the containers, use:

Bash

docker compose up
Deploying to Azure App Service
Deploying a Docker image to Azure App Service involves pushing it to a registry and then creating an App Service to run it.

Create an Azure Container Registry (ACR): An ACR is a private Docker registry in Azure. Create one through the Azure Portal and enable the admin user to get credentials.

Tag and Push Your Image to ACR:

First, log in to your ACR from the command line.

Bash

docker login myregistry.azurecr.io
Next, tag your local image with the ACR's login server name.

Bash

docker tag my-node-app:1.0 myregistry.azurecr.io/my-node-app:1.0
Finally, push the tagged image to your ACR.

Bash

docker push myregistry.azurecr.io/my-node-app:1.0
Create an Azure App Service:

In the Azure Portal, create a new Web App.

On the "Basics" tab, set Publish to "Docker Container" and Operating System to "Linux."

On the "Docker" tab, select Image Source as "Azure Container Registry," and choose the registry, image, and tag you just pushed.

Review and create the service. Azure will pull the image and run your container.

Azure App Service Public Endpoint
The public endpoint is the URL you use to access your deployed application over the internet.

Default Endpoint: For a standard Azure App Service, the public endpoint is a unique domain name formatted as <app-name>.azurewebsites.net.

IP Addresses: You access the app via its hostname, not its IP address. In a multi-tenant environment, multiple apps share a public inbound IP address. Outgoing connections from your app will originate from a pool of shared outbound IP addresses.

Private Access: For more secure, non-public access, you can use Private Endpoints to connect your App Service to an Azure Virtual Network, or deploy your app in an isolated App Service Environment (ASE).