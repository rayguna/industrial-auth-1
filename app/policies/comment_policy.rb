class CommentPolicy < ApplicationPolicy

  #methods: create (always true); edit, update, and delete (only the author)
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
    true
  end

  def destroy?
    edit?
  end

end
