class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # get rating options from model
    @all_ratings = Movie.pluck(:rating).uniq.sort
    
    # filtering movies by ratings checkbox
    # checked ratings remain checked after refresh
    if params[:ratings]
      @movies = Movie.where({ rating: params[:ratings].keys })
      @checked_ratings = params[:ratings].keys
    else
      @movies = Movie.all
      @checked_ratings = @all_ratings
    end
    
    # clickable <thead> for sorting movies
    if request.path.include? 's_title'
      # sort by title
      @movies = @movies.order(:title)
      @sort_title_path = '/'
      @sort_release_path = '/movies/s_release'
    elsif request.path.include? 's_release'
      # sort by release date
      @movies = @movies.order(:release_date)
      @sort_title_path = '/movies/s_title'
      @sort_release_path = '/'
    else
      # not sorted
      @movies = @movies
      @sort_title_path = '/movies/s_title'
      @sort_release_path = '/movies/s_release'
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find params[:id]
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
