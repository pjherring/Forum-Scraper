class Forum < ActiveRecord::Base

  belongs_to :site
  has_many :topics

  validates :vb_id, :name, :site, :presence => true
  validates :vb_id, :numericality => true

  def fetch_topics
    Rails.logger.info "HERE"
    self.scraper.can_scrape or self.scraper.login

    topics = self.scraper.fetch_topics(self)
    Rails.logger.info topics.inspect
    
    topics.each do |topic|

      if Topic.where(:vb_id => topic.vb_id, :forum_id => self.id).size == 0
        topic.save!
      end

      Rails.logger.info "about to fetch messages for #{topic.vb_id}"
      topic.fetch_messages
    end

  end

  def scraper
    return self.site.scraper
  end

end
