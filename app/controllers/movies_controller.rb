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
    session[:ratings] = session[:ratings] || @all_ratings
    
    # filtering movies by ratings checkbox
    # checked ratings remain checked after refresh
    if (!params[:ratings]) && (@all_ratings & session[:ratings]).empty?
      @movies = Movie.all
      @checked_ratings = @all_ratings
      session[:ratings] = @checked_ratings
    elsif !params[:ratings]
      @movies = Movie.where({ rating: session[:ratings] })
      @checked_ratings = session[:ratings]
    else
      @movies = Movie.where({ rating: params[:ratings].keys })
      @checked_ratings = params[:ratings].keys
      session[:ratings] = @checked_ratings
    end
    
    # clickable <thead> for sorting movies
    @sort_by = params[:sort_by]
    session[:sort_by] = @sort_by
    
    if @sort_by == 'title'
      # sort by title
      @movies = @movies.order(:title)
      @sort_title_path = './'
      @sort_release_path = './?sort_by=release'
    elsif @sort_by == 'release'
      # sort by release date
      @movies = @movies.order(:release_date)
      @sort_title_path = './?sort_by=title'
      @sort_release_path = './'
    else
      # not sorted
      @movies = @movies
      @sort_title_path = './?sort_by=title'
      @sort_release_path = './?sort_by=release'
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
