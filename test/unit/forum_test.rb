require 'test_helper'

class ForumTest < ActiveSupport::TestCase

  test "a forum requries the presence of a vb id, name, and forum" do
    forum = Forum.new
    assert !forum.valid?, 'forum is valid when missing a vb id, name, and site'

    forum.vb_id = 123123
    assert !forum.valid?, 'forum is valid when missing a name and site'

    forum.name = 'adfasdf'
    assert !forum.valid?, 'forum is valid without a site'

    forum.site = sites(:one)
    assert forum.valid?, 'forum is not valid when it has all required fields'
  end

  test "a forum requires a vb_id that is a number" do
    forum = Forum.new :name => 'name', :site_id => sites(:one).id,
      :vb_id => 'afsd'

    assert !forum.valid?, 'forum is valid with a vb_id that is not a number'

    forum.vb_id = 12345
    assert forum.valid?, 'forum is not valid with vb id being a number'
  end

  test "a forum should be able to scrape topics" do
    forum = forums(:one)
    forum.topics.destroy_all
    assert_equal 0, forum.topics.count, 'forum has more than 0 topics'


    mock_topic = Topic.new
    mock_topic.expects(:fetch_messages).once
    mock_topic.stubs(:vb_id)

    scraper = Scraper::Fetch.new forum.site
    scraper.expects(:fetch_topics).with(forum).returns([mock_topic])
    scraper.expects(:can_scrape).returns(true)

    Topic.expects(:where).returns(['dummyarray'])
    Topic.any_instance.stubs(:save!)

    forum.expects(:scraper).at_least_once.returns(scraper)

    forum.fetch_topics
  end

end
