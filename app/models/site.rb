class Site < ActiveRecord::Base

  has_many :forums

  validates :name, :url, :presence => true

  def fetch_forums
    #login if needed
    self.scraper.can_scrape or self.scraper.login
    forums = self.scraper.fetch_forums

    forums.each do |forum|

      #unless the forum is alreday saved
      unless Forum.where(:site_id => self.id, :vb_id => forum.vb_id).size > 0
        forum.save
      end

      Rails.logger.info "about to fetch topics for #{forum.vb_id}"
      forum.fetch_topics

    end

    self.last_updated = DateTime.now
    self.save

  end
  handle_asynchronously :fetch_forums

  def scraper
    @scraper ||= Scraper.create_fetcher(self)
  end

end
