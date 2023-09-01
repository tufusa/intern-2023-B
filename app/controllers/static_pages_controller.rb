class StaticPagesController < ApplicationController

  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def newpost
    if logged_in?
      passtime = 48.hours.ago
      following_ids = "SELECT followed_id FROM relationships
                        WHERE  follower_id = :user_id"
      @newpost_items =  Micropost.where("user_id IN (#{following_ids}) AND created_at>= :passtime", user_id:current_user.id,passtime: passtime)
                .includes(:user, image_attachment: :blob).limit(10)
      @micropost  = current_user.microposts.build
      
     
    end
  end
end
