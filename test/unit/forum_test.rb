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

    forum.fetch_topics

    assert_not_equal 0, forum.topics(true).count, 'forum has 0 topics'
  end

end
