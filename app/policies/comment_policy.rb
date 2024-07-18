class CommentPolicy < ApplicationPolicy

  #methods: create, edit, delete
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
    user == record.author
  end

end
