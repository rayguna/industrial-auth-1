# app/policies/photo_policy.rb

class PhotoPolicy < ApplicationPolicy

  #methods: create (always true), destroy (only owner), view (only owner, public, or followers), edit and update (only author).

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
    #user.username == record.owner.username
  end

  def create?
    true
  end

  def new?
    true
  end

  def edit?
    user.username == record.owner.username
  end

  def update?
    edit?
  end
end
