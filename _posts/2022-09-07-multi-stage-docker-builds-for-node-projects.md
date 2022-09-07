---
layout: post
title:  "Reducing NodeJS Artefacts Size Using Multi-Stage Docker Builds"
date:   2022-09-07 10:00:00 +0300
comments: true
img:
    href: 2022-09-07-good-will-hunting.jpg
    copyright: Good Will Hunting by Gus Van Sant
    alt: Good Will Hunting Movie
---

Delivering a Node application as a Docker image is easy,
and it works straight away. Most likely because of this
simplicity many don't even know it is done incorrectly.
In this article, I am going to explain how to build a
Docker image for a Node application and how multi-stage
builds can help in this.

{% include picture.html %}

I will create a node application to experiment with. It
doesn't matter what it is, I just want to be able to
build and run it. You can follow me and do the same,
just run the following command and select defaults.

```shell
npx @nestjs/cli new docker-demo
```
This will generate a Node application based on the NestJS framework.
It would have a single rest endpoint that returns "Hello World" on
it's root path.

Now I will create a Docker image in a straightforward way:

```shell
FROM node:18.8.0-alpine3.16
WORKDIR /app
COPY package*.json ./
COPY tsconfig*.json ./
COPY src src
RUN  npm ci && npm run build
ENTRYPOINT ["npm", "run", "start:prod"]
```

This is more or less what a Dockerfile looks like in many projects.
It works but it is not optimal. The problem here is that the project
gets built and runs in the same environment. The building phase
requires the TypeScript compiler and a bunch of other dependencies.
These dependencies are not needed in runtime.

In order to optimize this, I will split building and running phases into
separate docker build stages. This way, once the application is built,
it will preserve only the built artifacts and install only production
dependencies. Let's look at the resulting Dockerfile. 
```shell
FROM node:18.8.0-alpine3.16 as builder
WORKDIR /app
COPY package*.json ./
COPY tsconfig*.json ./
COPY src src
RUN  npm ci && npm run build

FROM node:18.8.0-alpine3.16
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY --from=builder /app/dist/ dist/
ENTRYPOINT ["npm", "run", "start:prod"]
```
The building stage here is separated from the running stage. In the line
`COPY --from=builder /app/dist/ dist/`, I only take the dist folder from
the builder image. It is much smaller because I install only production
dependencies in the resulting image. Let's compare the difference.

Run `docker system df -v` to see the detailed information
{%
    include picture.html
    href="2022-09-07-docker-df-output.png"
    alt="Output of 'docker system df -v'"
%}
The size of the unoptimized image is almost 200Mb larger. If you take a look at the
unique size property, the difference is even more notable. The footprint of the
unoptimized image is at least three times larger. Unique size is the
amount of space we add on top of the base image (in my case node:18.8.0-alpine3.16).
Note, this is only a hello world application. In real-world applications, the difference
might be slightly larger. 

The reduced image size is not the only benefit. Unused node modules that are
placed into a Docker image, are a potential security risk. Malicious code might
execute some of this code, or it might have vulnerabilities on its own. 

It doesn't matter what kind of application you are building, always be sure you are including
only the needed dependencies and generally follow 
[best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/).
