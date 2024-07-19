class FollowRequestPolicy < ApplicationPolicy

  #methods: create (always true), destroy and update (only owner)
  def create?
    true
  end

  def new?
    true
  end

  def update?
    user == record.sender || user == record.recipient
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

end
