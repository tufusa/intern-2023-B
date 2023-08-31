class StaticPagesController < ApplicationController

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
end
