class Forum < ActiveRecord::Base

  belongs_to :site
  has_many :topics

  def fetch_topics
    Rails.logger.info "HERE"
    self.scraper.can_scrape or self.scraper.login

    topics = self.scraper.fetch_topics(self)

    topics.each do |topic|

      if Topic.where(:vb_id => topic.vb_id, :forum_id => self.id).size == 0
        topic.save!
      end

      topic.fetch_messages
    end

  end

  def scraper
    return self.site.scraper
  end

end
