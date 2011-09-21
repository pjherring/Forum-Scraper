require 'rest_client'
require 'nokogiri'
require 'digest/md5'
require 'iconv'

module Scraper

  ArchiveUrl = 'archive/index.php'
  LoginFormAction = 'login.php?do=login'
  BaseForumUrl = 'archive/index.php/f-'
  BASE_FORUM_DISPLAY_URL = 'forumdisplay.php?f='
  BaseTopicUrl = 'archive/index.php/t-'
  BASE_TOPIC_DISPLAY_URL = 'showthread.php?t='
  FORUM_LINK_FORMAT = /f[-=]\d+/
  TopicLinkFormat = /t[-=]\d+/
  TopicPageLinks = /p[-=]\d+/
  MESSAGE_FORMATS = [
    { :block => 'div.post', :posted_by => 'div.username', :posted_at => 'div.date', :text => 'div.posttext' },
    { :block => 'ol#posts > li', :posted_by => 'div.userinfo div.username_container',
      :posted_at => 'div.posthead span.date', :text => 'div.postbody div.content' },
    { :block => 'div#posts div[@id*=edit]', :posted_by => 'a.bigusername', 
      :posted_at => 'table[@id*=post] td.thead div.normal', :text => 'div[@id*=post_message]',
      :date_format => /(AM|PM)\s+\d{1,2}:\d{1,2}\s+,?\d{1,2}[-\/]\d{1,2}[-\/]\d{2,4}/i },
    { :block => 'div#postlist li.postcontainer', :posted_by => 'a.username',
      :posted_at => 'span.postdate', :text => 'div.postrow' }
  ]


  def self.create_fetcher(site)
    @cache ||= {}
    limit = 3 unless ENV['RAILS_ENV'] == 'production'

    unless @cache.key?(site.id)
      @cache[site.id] = Fetch.new(site, limit)
    end

    return @cache[site.id]
  end


  class Fetch

    attr_accessor :can_scrape

    def initialize(site, limit = nil)
      @site = site
      @can_scrape = false
      @limit = limit
    end

    def login
      if @can_scrape || (@site.username.nil? && @site.password.nil?)
        @can_scrape = true
      else

        #hit archive, if a 302 then login, otherwise just return true for logged in
        response = fetch_html(@site.url + Scraper::ArchiveUrl)
        archive_response = response[:doc]
        login_form = get_login_form(archive_response)

        unless login_form.nil?
          #fetch html
          html = fetch_html(@site.url)[:doc]

          #get the inputs
          inputs = login_form.css('input')
          #construct the post string
          post_params = self.construct_post_params(inputs)

          login_url = @site.url
          login_url += '/' unless @site.url.match(/\/$/)
          login_url += Scraper::LoginFormAction

          #post to login
          login_response = RestClient.post(login_url, post_params)
          #get the cookies
          @cookies = login_response.cookies
          @can_scrape = true
        else
          @can_scrape = response.code == 200
        end

      end

    end

    def cookies
      return @cookies
    end


    def fetch_forums

      forums = []

      if @can_scrape
        forum_page = fetch_html(@site.url + Scraper::ArchiveUrl)[:doc]

        forum_links = forum_page.css('a').select { |a| a.key?('href') && a['href'] =~ Scraper::FORUM_LINK_FORMAT }

        unless @limit.nil?
          forum_links = forum_links[0..@limit]
        end

        forum_links.each do |forum_link|
          vb_id = forum_link['href'].match(/f[-=](\d+)/)[1].to_i
          name = forum_link.content

          new_forum  = Forum.new :vb_id => vb_id, :name => name, :site => @site, :last_updated => nil 
          forums.push(new_forum)
          #Rails.logger.info "Found forum of #{new_forum.site.url} with vb id #{new_forum.vb_id}"
        end

      end

      return forums

    end

    def fetch_topics(forum)
      topics = []

      if @can_scrape
        topics_page = fetch_html("#{@site.url}#{Scraper::BaseForumUrl}#{forum.vb_id}")[:doc]

        topic_links = []

        if topics_page.css('div#pagenumbers a').size > 0

          page_links = topics_page.css('div#pagenumbers a').
            select { |a| a.key?('href') && a['href'] =~ Scraper::TopicPageLinks }

          unless @limit.nil?
            page_links = page_links[0..@limit]
          end

          page_links.each do |page_link|

            topic_page_html = fetch_html(@site.url + Scraper::ArchiveUrl + '/' + page_link['href'])[:doc]

            page_topic_links = topic_page_html.css('a').
              select { |a| a.key?('href') && a['href'] =~ Scraper::TopicLinkFormat }
            page_topic_links.inspect

            page_topic_links.each do |link|
              topic_links.push(link)
            end

          end

        end

        #if there are multiple pages this needs to run to get the topics on page 1
        #otherwise this will get all the topics on the forum page
        page_topic_links = topics_page.css('a').select { |a| a.key?('href') && a['href'] =~ Scraper::TopicLinkFormat }

        page_topic_links.each do |link|
          topic_links.push(link)
        end

        unless @limit.nil?
          topic_links = topic_links[0..@limit]
        end

        topic_links.each do |topic|

          vb_id_match = topic['href'].match(/t[-=](\d+)([&\?\.]|$)/) if topic.key?('href')
          vb_id = vb_id_match[1].to_i unless vb_id_match.nil? || vb_id_match.size == 0

          name = topic.content

          new_topic = Topic.new :vb_id => vb_id, :name => name, :forum => forum, :last_updated => nil
          topics.push(new_topic)
          #Rails.logger.info "got a topic from #{new_topic.forum.site.url} with vb_id #{new_topic.vb_id}"

        end

      end

      return topics
    end

    def fetch_messages(topic)

      html = fetch_html("#{@site.url}#{Scraper::BaseTopicUrl}#{topic.vb_id}")[:doc]

      if is_homepage(html)
        begin
          html = fetch_html(@site.url + Scraper::BASE_TOPIC_DISPLAY_URL + topic.vb_id)[:doc]
        rescue
          html = fetch_html(@site.url + Scraper::BASE_TOPIC_DISPLAY_URL.match(/(.*)t=/)[1].to_s + topic.vb_id)[:doc]
        end

      end

      posts = nil
      messages = []

      Scraper::MESSAGE_FORMATS.each do |format|
        if posts.nil?

          posts = html.css format[:block]

          #if the block worked try the details
          if posts.size > 0 && posts.css(format[:posted_at]).size > 0 && posts.css(format[:posted_by]) && posts.css(format[:text]).size > 0
            unless @limit.nil?
              posts = posts[0..@limit]
            end
            posts.each do |post|
              posted_by = post.css(format[:posted_by])


              posted_at = post.css(format[:posted_at]).text
              ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
              posted_at = ic.iconv(posted_at + ' ')[0..-2]

              text = post.css(format[:text]).text

              message = Message.new :text => text, :posted_by => posted_by, 
                :posted_at => posted_at, :topic => topic
              messages.push(message)
              #Rails.logger.info "Found a message of #{topic.forum.site.url} of topic #{topic.vb_id}"

            end
          else
            posts = nil
          end

        end

      end

      return messages

    end

    protected #all methods below are protected

    def is_homepage(html)
      forum_links = html.css('a').select { |a| a.key?('href') && a['href'] =~ /forumdisplay/ }

      return forum_links.size > 0
    end

    def get_login_form(html)
      forms = html.css('form').select { |f| f.key?('action') && f['action'] == Scraper::LoginFormAction }
      return forms[0] unless forms.length == 0
    end

    def construct_post_params(inputs)
      post_params = {}

      inputs.each do |input|

        name = input['name'] if input.key?('name')
        value = nil

        #add parameter
        if input.key?('value') && input['value'] != ''
          value = input['value']
        else
          #we need to insert the value from our DB
          case name
          when 'vb_login_password'
            value = @site.password
          when 'vb_login_username'
            value = @site.username
          when 'vb_login_md5password'
            value = Digest::MD5.hexdigest(@site.password)
          when 'vb_login_md5password_utf'
            value = Digest::MD5.hexdigest(@site.password)
          end

        end

        unless value.nil? || name.nil?
          post_params[name] = value
        end

      end

      return post_params
    end

    def fetch_html(url)

      Rails.logger.info "about to get #{url}"
      response = RestClient.get(url, { :cookies => @cookies })

      if response.code == 200
        return { :doc => Nokogiri::HTML(response), :response => response }
      elsif response.code == 301
        raise Scraper::PermanentlyMovedException
      end

    end
  end

  class PermanentlyMovedException < StandardError 
    ;
  end




end
