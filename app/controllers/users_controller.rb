class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :one_user?, only: [:new, :create]
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @users = User.all
    authorize User
  end

  def new
  end

  def show
    authorize User
  end

  def update
    authorize User
    if @user.update_attributes(user_params)
      redirect_to users_path, succes: 'User updated'
    else
      redirect_to users_path, alert: 'unable to update user'
    end
  end

  def destroy
    authorize User
    @user.destroy
    redirect_to users_path, notice: "User was deleted"
  end

  private

    def one_user?
      if (User.count == 1) & (user_signed_in?)
        redirect_to root_path
      elsif User.count == 1
        redirect_to new_user_session_path
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role)
    end

end
