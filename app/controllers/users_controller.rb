class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_user, only: [:show, :update, :destroy]
  after_action :verify_authorized

  def index
    @users = User.all
    authorize User
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

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role)
    end

end
