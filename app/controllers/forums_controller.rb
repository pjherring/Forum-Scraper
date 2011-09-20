class ForumsController < ApplicationController

  MAX_TOPICS_TO_SHOW = 100

  # GET /forums
  # GET /forums.json
  def index
    @forums = Forum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @forums }
    end
  end

  # GET /forums/1
  # GET /forums/1.json
  def show
    @forum = Forum.find(params[:id])
    @topics = @forum.topics[0..MAX_TOPICS_TO_SHOW]
    @page = 1

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @forum }
    end
  end

  # GET /forums/new
  # GET /forums/new.json
  def new
    @forum = Forum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @forum }
    end
  end

  # GET /forums/1/edit
  def edit
    @forum = Forum.find(params[:id])
  end

  # POST /forums
  # POST /forums.json
  def create
    @forum = Forum.new(params[:forum])

    respond_to do |format|
      if @forum.save
        format.html { redirect_to @forum, :notice => 'Forum was successfully created.' }
        format.json { render :json => @forum, :status => :created, :location => @forum }
      else
        format.html { render :action => "new" }
        format.json { render :json => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forums/1
  # PUT /forums/1.json
  def update
    @forum = Forum.find(params[:id])

    respond_to do |format|
      if @forum.update_attributes(params[:forum])
        format.html { redirect_to @forum, :notice => 'Forum was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forums/1
  # DELETE /forums/1.json
  def destroy
    @forum = Forum.find(params[:id])
    @forum.destroy

    respond_to do |format|
      format.html { redirect_to forums_url }
      format.json { head :ok }
    end
  end

  def paginate

    if params.key?(:page) && !params[:page].nil?
      @forum = Forum.find(params[:id])
      @page = params[:page].to_i
      index_start = (@page - 1) * MAX_TOPICS_TO_SHOW
      index_end = index_start + MAX_TOPICS_TO_SHOW - 1
      index_start = 0 if index_start > @forum.topics.count
      index_end = @forum.topics.count if index_end > @forum.topics.count
      @topics = @forum.topics[index_start..index_end]

      respond_to do |format|
        format.html { redirect_to @forum }
        format.js
      end
    else
      render :bad_request
    end

  end

end
