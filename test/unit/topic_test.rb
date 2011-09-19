require 'test_helper'

class TopicTest < ActiveSupport::TestCase

  test "a topic requries the presence of a vb id, name, and forum" do
    topic = Topic.new
    assert !topic.valid?, 'topic is valid when missing a vb id, name, and forum'

    topic.vb_id = 123123
    assert !topic.valid?, 'topic is valid when missing a name and forum'

    topic.name = 'adfasdf'
    assert !topic.valid?, 'topic is valid without a forum'

    topic.forum = forums(:one)
    assert topic.valid?, 'topic is not valid when it has all required fields'
  end

  test "a topic requires a vb_id that is a number" do
    topic = Topic.new :name => 'name', :forum_id => forums(:one).id,
      :vb_id => 'afsd'

    assert !topic.valid?, 'topic is valid with a vb_id that is not a number'

    topic.vb_id = 12345
    assert topic.valid?, 'topic is not valid with vb id being a number'
  end

  test "a topic should scrape messages async" do
    topic = topics(:one)
    topic.messages = []
    topic.save!

    assert topic.messages.size == 0, 'topic has messages after deleting all messages'

    Delayed::Job.destroy_all

    assert_equal Delayed::Job.count, 0, 'still has delayed jobs'

    topic.fetch_messages

    assert_equal Delayed::Job.count, 1, 'delayed has no jobs'
  end

  test "a topic should scrape messages" do
    topic = topics(:one)
    topic.messages = []

    topic.save!

    assert topic.messages.count == 0, 'topic has messages after deleting all messages'

    topic.fetch_messages_without_delay

    assert topic.messages(true).count > 0, 'topic has no messages'
  end

end
