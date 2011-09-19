require 'date'

namespace :scrape do

  desc "scrape all sites, all forums, all topics, all messages"
  task :scrape_all => :environment do

    Site.find_each do |site|
      p "scraping #{site.name}"
      site.fetch_forums
    end

  end

  desc "scrape a specific site"
  task :scrape_site => :environment do
    name = ENV['SITE']
    site = Site.first(:conditions => { :name => name })

    unless site.nil?
      site.fetch_forums
    end

  end


end
