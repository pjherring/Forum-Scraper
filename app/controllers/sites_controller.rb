class SitesController < ApplicationController

  MAX_FORUM_SHOW = 25

  # GET /sites
  # GET /sites.json
  def index
    @sites = Site.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    @site = Site.find(params[:id])
    @forums = @site.forums[0..MAX_FORUM_SHOW]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @site }
    end
  end

  def paginate
    @site = Site.find(params[:id])
    page = params[:page].to_i - 1
    index_start = (page * MAX_FORUM_SHOW)
    index_end = index_start + MAX_FORUM_SHOW

    #make sure our start is not greater than the total count
    index_start = 0 if index_start > @site.forums.count
    index_end = @site.forums.count if  index_end > @site.forums.count

    Rails.logger.info "Slicing #{index_start}, #{index_end}"

    #decrement to account for 0 base indexing
    index_end -= 1

    @forums = @site.forums[index_start..index_end]
    #increment for rendering of view
    @page = page + 1

    respond_to do |format|
      format.html { redirect_to @site, :notice => 'Error' }
      format.js 
    end

  end

  # GET /sites/new
  # GET /sites/new.json
  def new
    @site = Site.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @site }
    end
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find(params[:id])
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        format.html { redirect_to @site, :notice => 'Site was successfully created.' }
        format.json { render :json => @site, :status => :created, :location => @site }
      else
        format.html { render :action => "new" }
        format.json { render :json => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.json
  def update
    @site = Site.find(params[:id])

    respond_to do |format|
      if @site.update_attributes(params[:site])
        format.html { redirect_to @site, :notice => 'Site was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json { head :ok }
    end
  end

  def fetch_forums
    @site = Site.find(params[:id])
    @site.fetch_forums

    respond_to do |format|
      format.html { redirect_to @site }
      format.json { head :ok }
    end
  end
end
