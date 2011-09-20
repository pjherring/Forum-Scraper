require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  setup do
    @forum = forums(:one)
  end

  test "I can paginate through topics in a forum" do
    @forum.topics.destroy_all

    (1..5).each do |i|
      t = Topic.new
      t.vb_id = i
      t.name = 'topic ' + i.to_s
      t.forum = @forum
      t.save!
    end

    assert_equal 5, @forum.topics(true).count, 'forum does not have 5 topics'

    get :paginate, { :page => 1, :id => @forum.id, :format => :js }
    assert_response :success
    assert_not_nil assigns(:page), 'page is nil'
    assert_not_nil assigns(:topics), 'topics is nil'
    assert_not_nil assigns(:forum), 'forum is nil'
    assert_equal 5, assigns(:topics).count, 'topics.count is not 5'

    @forum.topics.destroy_all

    (1..504).each do |i|
      t = Topic.new
      t.vb_id = i
      t.name = 'topic ' + i.to_s
      t.forum = @forum
      t.save!
    end

    assert_equal 504, @forum.topics(true).count, 'forum does not have 5 topics'

    get :paginate, { :page => 1, :id => @forum.id, :format => :js }
    assert_response :success
    assert_not_nil assigns(:page), 'page is nil'
    assert_not_nil assigns(:topics), 'topics is nil'
    assert_not_nil assigns(:forum), 'forum is nil'
    assert_equal 100, assigns(:topics).count, 'topics.count is not 100'

    get :paginate, { :page => 3, :id => @forum.id, :format => :js }
    assert_response :success
    assert_not_nil assigns(:page), 'page is nil'
    assert_not_nil assigns(:topics), 'topics is nil'
    assert_not_nil assigns(:forum), 'forum is nil'
    assert_equal 100, assigns(:topics).count, 'topics.count is not 100'

    get :paginate, { :page => 5, :id => @forum.id, :format => :js }
    assert_response :success
    assert_not_nil assigns(:page), 'page is nil'
    assert_not_nil assigns(:topics), 'topics is nil'
    assert_not_nil assigns(:forum), 'forum is nil'
    assert_equal 4, assigns(:topics).count, 'topics.count is not 4'
  end

end
