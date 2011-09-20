class Topic < ActiveRecord::Base
  belongs_to :forum
  has_many :messages

  validates :vb_id, :name, :forum, :presence => true
  validates :vb_id, :numericality => true

  def fetch_messages
    self.scraper.can_scrape or self.scraper.login
    messages = self.scraper.fetch_messages(self)

    messages.each do |message|

      if self.forum.site.last_updated.nil? || message.posted_at > self.forum.site.last_updated
        message.save
      end

    end

  end

  def scraper
    return self.forum.site.scraper
  end

end
