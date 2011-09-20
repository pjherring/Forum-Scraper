require 'test_helper'

class SitesControllerTest < ActionController::TestCase
  setup do
    @site = sites(:one)
  end

  test "that details a site can be shown" do
    get :show, :id => sites(:one).id
    assert_response :success

    assert_not_nil assigns(:site), 'site is nil'
    assert_not_nil assigns(:forums), 'forums is nil'
  end

  test "that a site can be created" do
  end

  test "that a site can be destroyed" do
  end

  test "that details of a site can be edited" do
  end

  test "that I can view a listing of all sites" do
  end

  test "that I can get a slice of a sites forums" do
    @site.forums.destroy_all

    (1..3).each do |i|
      forum = Forum.new
      forum.vb_id = i
      forum.name = 'forum ' + i.to_s
      forum.site = @site
      forum.save!
    end

    assert_equal @site.forums(true).count, 3, 'site does not have 3 forums'

    get :paginate, { :page => 1, :id => @site.id, :format => :js }
    assert_response :success
    assert_not_nil assigns(:forums), 'formums was not set'
    assert_not_nil assigns(:page), 'page is not set'

    @site.forums.destroy_all
    (1..79).each do |i|
      forum = Forum.new
      forum.vb_id = i
      forum.name = 'forum ' + i.to_s
      forum.site = @site
      forum.save!
    end

    assert_equal 79, @site.forums(true).count, 'site does not have 79 forums'

    get :paginate, { :page => 2, :id => @site.id, :format => :js }
    assert_response :success
    assert_not_nil assigns(:forums), 'forums is nil'
    assert_not_nil assigns(:page), 'page is not set'
    assert_equal 25, assigns(:forums).count, 'forums is not 25 items'

    get :paginate, { :page => 4, :id => @site.id, :format => :js }
    assert_response :success
    assert_not_nil assigns(:forums), 'forums is nil'
    assert_not_nil assigns(:page), 'page is not set'
    assert_equal 4, assigns(:forums).count, 'forums is not 4 items'
  end

end
