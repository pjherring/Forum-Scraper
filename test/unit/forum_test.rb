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

  test "a forum should be able to asynchronously scrape topics" do
    forum = forums(:one)
    forum.topics = []
    forum.save!

    Delayed::Job.destroy_all

    assert forum.topics.size == 0, 'forum has topics after deleting all topics'

    forum.fetch_topics

    assert forum.topics(true).size == 0, 'forum does not have any topics after scrape'

    assert Delayed::Job.count == 1, 'delayed jobs has no jobs'

  end

end
