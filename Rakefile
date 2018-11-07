# encoding: utf-8

require 'rubygems'
require 'rake'
require 'tempfile'
require 'rake/clean'
require 'nokogiri'
require 'English'

task default: [
    :clean,
    :build
]

def done(msg)
  puts msg + "\n\n"
end

desc 'Delete _site directory'
task :clean do
  rm_rf '_site'
  done 'Jekyll site directory deleted'
end

desc 'Build Jekyll site'
task :build do
  if File.exist? '_site'
    done 'Jekyll site already exists in _site'
  else
    system('jekyll build')
    fail 'Jekyll failed' unless $CHILD_STATUS.success?
    done 'Jekyll site generated without issues'
  end
end

desc 'Check spelling in all HTML pages'
task spell: [:build] do
  Dir['_site/**/*.html'].each do |f|
    html = Nokogiri::HTML(File.read(f))
    html.search('//code').remove
    html.search('//script').remove
    html.search('//pre').remove
    html.search('//header').remove
    html.search('//footer').remove
    text = html.xpath('//article//p|//article//h2|//article//h3').to_a.join(' ')
               .gsub(/[\n\r\t ]+/, ' ')
               .gsub(/&[a-z]+;/, ' ')
               .gsub(/&#[0-9]+;/, ' ')
               .gsub(/n[’']t/, ' not')
               .gsub(/[’']ll/, ' will')
               .gsub(/[’']ve/, ' have')
               .gsub(/[’']s/, ' ')
               .gsub(/[,:;<>?!-#$%^&@]+/, ' ')
    tmp = Tempfile.new(['sashashpota-', '.txt'])
    tmp << text
    tmp.flush
    tmp.close
    stdout = `cat "#{tmp.path}" \
        | aspell -a --lang=en_US -W 2 --ignore-case -p ./_rake/aspell.en.pws \
        | grep ^\\&`
    fail "Typos at #{f}: ⛔️️\n#{stdout}" unless stdout.empty?
    puts "#{f}: ✅ (#{text.split(/\s/).size} words)"
  end
  done 'No spelling errors'
end
