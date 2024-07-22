class CommentPolicy < ApplicationPolicy

  #methods: create and new (except for private); edit, update, and delete (only the author)
  def edit?
    user == record.author
  end

  def update?
    edit?
  end

  def create?
    true
  end

  def new?
    create?
  end

  def destroy?
    edit?
  end

end
