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
    
    # preserve URI properties from params and sessions
    # if no proper params in URI, redirect (#=> false)
    if check_param?
    
      # filtering movies by ratings checkbox
      # checked ratings remain checked after refresh
      get_movies
      set_ratings
      
      # clickable <thead> for sorting movies
      @sort_by = params[:sort_by]
      session[:sort_by] = @sort_by
      sort_table
    end
  end

  def check_param?
    need_redirect = false
    ratings = ""
    sort_by = ""
    # redirect index according to params and session
    if params[:ratings]
      ratings = params[:ratings].to_query("ratings")
    elsif !params[:ratings] && session[:ratings]
      need_redirect = true
      ratings = ratings_session
    end
    
    if params[:sort_by]
      sort_by = params[:sort_by].to_query("sort_by")
    elsif !params[:sort_by] && session[:sort_by]
      need_redirect = true
      sort_by = sort_by_session
    end
    
    if ratings != ""
      sort_by = "&" + sort_by
    end
    
    if need_redirect == true
      flash.keep
      redirect_to request.path + "?" + ratings + sort_by and return false
    else
      return true
    end
  end

  def ratings_session
    # return stringified params from session[:ratings]
    r = ""
    
    # compose params according to session content
    session[:ratings].each do |rating|
      r = r + "&ratings[#{rating}]=" + rating
    end
    return r = r[1..-1]
  end
    
  def sort_by_session
    # return stringified params from session[:sort_by]
    return "sort_by=" + session[:sort_by]
  end

  def sort_table
    if @sort_by == 'title'
      # sort by title
      @movies = @movies.order(:title)
      @sort_title_path = movies_path + '?sort_by=none'
      @sort_release_path = movies_path + '?sort_by=release'
    elsif @sort_by == 'release'
      # sort by release date
      @movies = @movies.order(:release_date)
      @sort_title_path = movies_path + '?sort_by=title'
      @sort_release_path = movies_path + '?sort_by=none'
    else
      # not sorted
      @movies = @movies
      @sort_title_path = movies_path + '?sort_by=title'
      @sort_release_path = movies_path + '?sort_by=release'
    end
  end
  
  def get_movies
    if params[:ratings] && (@all_ratings & session[:ratings]).empty?
      # when movies of one rating is all deleted
      @movies = Movie.all
    elsif !params[:ratings]
      @movies = Movie.where({ rating: session[:ratings] })
    else
      @movies = Movie.where({ rating: params[:ratings].keys })
    end
  end
  
  def set_ratings
    if params[:ratings] && (@all_ratings & session[:ratings]).empty?
      # when movies of one rating is all deleted
      @checked_ratings = @all_ratings
      session[:ratings] = @checked_ratings
    elsif !params[:ratings]
      @checked_ratings = session[:ratings]
    else
      @checked_ratings = params[:ratings].keys
      session[:ratings] = @checked_ratings
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
