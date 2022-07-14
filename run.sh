#sh
docker run -p 4000:4000 --rm -v $(pwd):/blog blog-builder bundle exec jekyll serve --host=0.0.0.0 --future