class FollowRequestPolicy < ApplicationPolicy

  #methods: create, destroy, update
  def create?
    true
  end

  def new?
    true
    #create?
  end

  def update?
    true
    #create?
  end

  def edit?
    true
    #create?
  end

  def destroy?
    true
    #create?
  end

end
