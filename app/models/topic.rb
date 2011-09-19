class Topic < ActiveRecord::Base
  belongs_to :forum
  has_many :messages

  validates :vb_id, :name, :forum, :presence => true
  validates :vb_id, :numericality => true

  def fetch_messages
    self.scraper.can_scrape or self.scraper.login
    messages = self.scraper.fetch_messages(self)

    messages.each do |message|

      if self.site.last_updated.nil? || message.posted_at > self.site.last_updated
        message.save
      end

    end

  end
  handle_asynchronously :fetch_messages

  def site
    return self.topic.forum.site
  end

  def scraper
    return self.forum.site.scraper
  end

end
