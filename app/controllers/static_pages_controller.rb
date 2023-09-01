class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: [:newpost]
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
      @fixed_item = current_user.get_fixed_micropost
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def newpost
    following_ids = "SELECT followed_id FROM relationships
                      WHERE  follower_id = :user_id"
    @newpost_items =  Micropost.where("user_id IN (#{following_ids}) AND created_at>= :passtime", user_id:current_user.id,passtime: Settings.newpost.limithour.hours.ago)
              .includes(:user, image_attachment: :blob).limit(Settings.newpost.limitnum)
    @micropost  = current_user.microposts.build
  end
end
