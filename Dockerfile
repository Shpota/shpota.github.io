FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install ruby-full build-essential zlib1g-dev --assume-yes --no-install-recommends

RUN gem install bundler jekyll:3.9.3 minima jekyll-sitemap jekyll-feed:0.16.0 webrick kramdown-parser-gfm:1.1 rouge:3.29.0 addressable:2.8.0 i18n:0.9.5 liquid:4.0.3 public_suffix:4.0.7 concurrent-ruby:1.1.10 listen:3.7.1 rb-fsevent:0.11.1

WORKDIR /blog
