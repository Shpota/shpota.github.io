FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install ruby-full build-essential zlib1g-dev --assume-yes --no-install-recommends

RUN gem install bundler jekyll:3.9.3 minima jekyll-sitemap jekyll-feed:0.16.0 webrick \
  kramdown-parser-gfm:1.1 rouge:3.29.0 addressable:2.8.4 i18n:1.12.0 liquid public_suffix:5.0.1 \
  ffi:1.15.5 concurrent-ruby:1.1.10 listen:3.7.1 rb-fsevent:0.11.1

WORKDIR /blog
