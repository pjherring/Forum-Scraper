require 'test_helper'

class SiteTest < ActiveSupport::TestCase

=begin
  test "a site requires the presence of a name and url" do
    site = Site.new

    assert !site.valid?, 'site is valid even though it lacks a name and url'
  end

  test "use the same instance of scraper each time" do
    site = sites(:two)
    scraper = site.scraper
    scraper_two = site.scraper

    assert_equal scraper, scraper_two, 'scrapers not equal'
  end

  test "fetch_forums is handled asynchronously" do

    Delayed::Job.destroy_all

    assert_equal Delayed::Job.count, 0, 'there are delayed jobs'

    site = sites(:two)
    site.fetch_forums

    assert_equal Delayed::Job.count, 1, 'did not add delayed job'

  end
=end

  test "can fetch forums" do
    site = sites(:two)
    site.forums.destroy_all

    assert_equal site.forums(true).count, 0, 'the site has forums'

    site.fetch_forums_without_delay

    assert site.forums(true).count > 0, 'the site has no forums'

  end

end
