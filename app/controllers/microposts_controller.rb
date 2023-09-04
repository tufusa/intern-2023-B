class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy, :fix]
  before_action :correct_user,   only: [:destroy, :fix]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    if request.referrer.nil?
      redirect_to root_url, status: :see_other
    else
      redirect_to request.referrer, status: :see_other
    end
  end

  def fix
    Micropost.transaction do
      Micropost.where(user_id: @micropost.user_id).update_all is_fixed: false
      @micropost.reload.update(is_fixed: true)  
    end
    @fixed_item = current_user.get_fixed_micropost
    flash[:success] = "Micropost fixed"
    redirect_to request.fullpath, status: :see_other
  end

  def like_users
    @micropost = Micropost.find_by(id: params[:id])
    @hidden_button = true;
    @users = @micropost.liked_users
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil?
    end
end
