class CommentPolicy
  attr_reader :user, :comment

  def initialize(user, comment)
    @user = user
    @comment = comment
  end

  #methods: create, destroy, edit, update

  #A user can make comments if they own the photo, the photo is public, or they are followers.  
  def new?
    user == photo.owner ||
    !photo.owner.private? ||
    photo.owner.followers.include?(user)
  end


  #only the author can destroy, edit, or update
  def destroy?
    user == comment.author
  end

  def edit?
    user == comment.author
  end

  def update?
    user == comment.author
  end

end
