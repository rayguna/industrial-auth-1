class CommentPolicy < ApplicationPolicy
  attr_reader :user, :comment

  def initialize(user, comment)
    @user = user
    @comment = comment
  end

  #methods: create, edit, delete

  def edit?
    user == comment.author
  end

  def update?
    edit?
  end

end
