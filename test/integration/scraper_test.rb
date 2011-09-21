require 'scraper'
require 'test_helper'

class ScraperTest < ActionDispatch::IntegrationTest

  test "scraper can login to a site" do
    sites_enum = [sites(:two), sites(:three), sites(:four), sites(:five), sites(:six), sites(:eight), sites(:nine), sites(:ten), sites(:eleven), sites(:twelve), sites(:thirteen)]
    sites_enum.each do |site|
      scraper = Scraper.create_fetcher(site)
      scraper.login

      assert scraper.can_scrape, "scraper cannot scrape for #{site.name}"
      assert (site.username.nil? && site.password.nil?) || scraper.cookies.size > 2, "no cookies set for #{site.name}"
    end
  end

  test "scraper can get forums" do
    sites_enum = [sites(:two), sites(:three), sites(:four), sites(:five), sites(:six), sites(:eight), sites(:nine), sites(:ten), sites(:eleven), sites(:twelve), sites(:thirteen)]
    sites_enum.each do |site|
      site.forums = []
      site.save!

      assert site.forums.size == 0, "site has forums for #{site}"

      scraper = Scraper.create_fetcher site
      scraper.login
      forums = scraper.fetch_forums

      assert !forums.nil?, "forums is null for #{site}"
      assert forums.size > 0, "forums is 0 for #{site}"
      assert forums[0].vb_id.kind_of?(Integer), "vb is not an integer but #{forums[0].inspect} for #{site}"
    end
  end

  test "scraper can fetch topics" do
    forums_enum = [forums(:two), forums(:three), forums(:four), forums(:five), forums(:six), forums(:eight), forums(:nine), forums(:ten), forums(:eleven), forums(:twelve), forums(:thirteen)]
    forums_enum.each do |forum|
      forum.topics = []
      forum.save!

      assert forum.topics.size == 0, "forum still has topics for #{forum.vb_id}"

      scraper = Scraper.create_fetcher forum.site
      scraper.login

      topics = scraper.fetch_topics(forum)

      assert_not_nil topics
      assert topics.size > 0, "topics is 0 for #{forum.vb_id}"
      assert topics[0].vb_id.kind_of?(Integer), "vb_id is not a number but #{topics[0].inspect} for #{forum.vb_id}"
    end
  end

  test "scraper can retrieve messages" do
    topics_enum = [topics(:two), topics(:three), topics(:four), topics(:five), topics(:six), topics(:eight), topics(:nine), topics(:ten), topics(:eleven), topics(:twelve), topics(:thirteen)]
    topics_enum.each do |topic|
      topic.messages = []
      topic.messages.destroy_all

      assert topic.messages.size == 0, "topic has messages for #{topic.vb_id}"

      scraper = Scraper.create_fetcher topic.forum.site
      scraper.login

      messages = scraper.fetch_messages(topic)
      assert_not_nil messages, "messages is nil for #{topic.vb_id}"
      assert messages.size > 0, "messages size is not greater than 0 for #{topic.vb_id}"
      assert messages[0].kind_of?(Message), 'message is not a Message'
      assert messages[0].text.size > 0, "message has no text for #{topic.vb_id}"
      assert messages[0].text.kind_of?(String)
    end

  end

end
