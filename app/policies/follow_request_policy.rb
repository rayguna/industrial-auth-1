class FollowRequest
  attr_reader :current_user, :user

def initialize(current_user, user)
  @current_user = current_user
  @user = user
end

#methods: create, destroy, and update

#only current_user can create a request


def new?
  user == current_user
end

#only current user can destroy the request
def destroy?
  user == current_user
end

#only current user can modify the request
def update?
  user == current_user
end
