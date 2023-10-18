class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers,:mylikes]
  before_action :set_user,       only: [:mylikes, :followers, :following, 
                                        :show, :destroy, :edit, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def index
    search_place = params[:search_place] || ''
    search_term = params[:search_users] || ''
    search_term_pattern = "%#{User.sanitize_sql_like(search_term)}%"
    @users = User.where('name LIKE ?', search_term_pattern)
                 .or(User.where('email LIKE ?', search_term_pattern))

    @users = @users.where(birthplace: search_place) unless search_place.empty?

    @users = @users.paginate(page: params[:page])
    @locale = params[:locale]
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.without_fixed.paginate(page: params[:page])
    @fixed_item = @user.get_fixed_micropost
    @hidden_button = false
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # @user.send_activation_email
      # flash[:info] = "Please check your email to activate your account."
      @user.activate
      if @user.authenticate(user_params[:password])
        reset_session
        log_in @user
      end
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    Rails.logger.debug "debug; #{user_params}"
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted"
    p({ current: current_user })
    redirect_to users_url, status: :see_other
  end

  def following
    @title = I18n.t :following
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow', status: :unprocessable_entity
  end

  def followers
    @title = I18n.t :followers
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow', status: :unprocessable_entity
  end
  def mylikes
    @microposts = @user.liked_microposts.paginate(page: params[:page])
  end
  
  private
    def set_user 
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :nickname, :introduce, :birthplace)
    end
  
    # beforeフィルタ

    # 正しいユーザーかどうか確認
    def correct_user
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
