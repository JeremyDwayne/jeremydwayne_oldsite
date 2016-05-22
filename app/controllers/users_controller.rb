class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def update
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User was deleted"
  end

  private
    def set_user
      @user = User.find(params[:id])
    end
end
