class ForumsController < ApplicationController

  MAX_TOPICS_TO_SHOW = 25
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

=begin
    if params.key?(:topic_start)
      floor = params[:topic_start]
      floor = 0 if floor > @forum.topics.size
      ceiling = start + MAX_TOPICS_TO_SHOW
      ceiling = @forum.topics.size - 1 if celing > @forum.topics.size
      @topics = @forum.topics[floor..ceiling]

    else
      max = MAX_TOPICS_TO_SHOW
      max = @forum.topics.size if max > @forum.topics.size
      @topics = @forum.topics[0..max]
    end
=end

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
end
