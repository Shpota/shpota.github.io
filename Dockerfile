FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install ruby-full build-essential zlib1g-dev --assume-yes --no-install-recommends

RUN gem install bundler jekyll:3.9.2 minima jekyll-sitemap webrick kramdown-parser-gfm:1.1 rouge:3.29.0

WORKDIR /blog
