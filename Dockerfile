FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install ruby-full build-essential zlib1g-dev --assume-yes --no-install-recommends

RUN gem install bundler jekyll:3.10.0 minima:2.5.1 kramdown-parser-gfm:1.1 jekyll-sitemap jekyll-feed

WORKDIR /blog
