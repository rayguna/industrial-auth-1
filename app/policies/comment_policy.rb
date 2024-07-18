class CommentPolicy < ApplicationPolicy
  attr_reader :user, :comment

  debugger

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

  # def create?
  #   true
  # end

  # def new?
  #   true
  # end


end
