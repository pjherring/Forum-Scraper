class Forum < ActiveRecord::Base

  belongs_to :site
  has_many :topics

  validates :vb_id, :name, :site, :presence => true
  validates :vb_id, :numericality => true

  def fetch_topics
    self.scraper.can_scrape or self.scraper.login

    topics = self.scraper.fetch_topics(self)
    
    topics.each do |topic|

      if Topic.where(:vb_id => topic.vb_id, :forum_id => self.id).size == 0
        topic.save!
      end

      topic.fetch_messages

    end
  end
  handle_asynchronously :fetch_topics

  def scraper
    return self.site.scraper
  end

end
