class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy, :show]
  before_filter :authorized_user, :only => :destroy

  def show
		@user = User.find_by_id(current_user.id)
	  	@micropost = Micropost.find_by_id(params[:id])
  end

def create
    @micropost  = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end
 

  def destroy
    @micropost.destroy
    redirect_back_or root_path  
  end

def rate_up

   @micropost = Micropost.find(params[:id])
   @comment = @micropost.comments.find(params[:format])
    begin
   	@rating = Rating.new()
	@rating.user_id = current_user.id
	@rating.comment_id = @comment.id
	@rating.save!
  
   rescue
        flash[:success] = "cannot rate up/down again"
        redirect_to @micropost and return
   end
   @comment.rating += 1;
   @users_karma = User.find(@comment.user_id)
   @comment.save;
   @users_karma.karma += 1;
   @users_karma.save!
   #creating rating entry
  

   redirect_to @micropost
end

def rate_down
 	
  @micropost = Micropost.find(params[:id])   
   @comment = @micropost.comments.find(params[:format])

   
  
   if current_user.karma >= 10 
	    begin
   	@rating = Rating.new()
	@rating.user_id = current_user.id
	@rating.comment_id = @comment.id
	@rating.save!
  
   rescue
        flash[:success] = "cannot rate up/down again"
        redirect_to @micropost and return
   end
   @comment.rating -= 1;
   @comment.save;
   @users_karma = User.find(@comment.user_id)
   
   @users_karma.karma -= 1;
   @users_karma.save!
   redirect_to @micropost
    else
      flash[:success] = "Cannot rate down a comment, karma < 10!"
      redirect_to @micropost
    end
 end
    
  
  private

  def authorized_user
	@micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_path if @micropost.nil?
	 

  end

end
