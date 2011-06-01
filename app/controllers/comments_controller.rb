class CommentsController < ApplicationController

  def add_comment
    commentable_type = params[:commentable][:commentable]
    commentable_id = params[:commentable][:commentable_id]
    # Get the object that you want to comment
    commentable = Comment.find_commentable(commentable_type, commentable_id)
  
    # Create a comment with the user submitted content
    @comment = Comment.new(params[:comment])
    @comment.created_at = Time.now
    # Assign this comment to the logged in user
    raise "No existe usuario logueado" if (!current_user)
    @comment.user = current_user
   
    # Add the comment
    commentable.comments << @comment
  
    render :layout=>false
  end

end
