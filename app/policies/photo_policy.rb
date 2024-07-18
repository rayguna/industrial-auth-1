# app/policies/photo_policy.rb

class PhotoPolicy < ApplicationPolicy

  #methods: create, destroy, and view

  # Our policy is that a photo should only be seen by the owner or followers
  #   of the owner, unless the owner is not private in which case anyone can
  #   see it
  def show?
    user == record.owner ||
      !record.owner.private? ||
      record.owner.followers.include?(user)
  end

  def destroy?
    user == record.owner
  end

  def create?
    true
  end

  def new?
    true
  end

end
