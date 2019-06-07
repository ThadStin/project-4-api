class BeersController < ApplicationController
  # index route
  def index
    render json: Beer.all
  end

  #show route
  def show
    render json: Beer.find(params["id"])
  end

  # create route
  def create
    render json: Beer.create(params["beer"])
  end

  # delete route
  def delete
    render json: Beer.delete(params["id"])
  end

  # update route
  def update
    render json: Beer.update(params["id"], params["beer"])
  end
end
