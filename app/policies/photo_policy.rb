# app/policies/photo_policy.rb

class PhotoPolicy
  attr_reader :user, :photo

  def initialize(user, photo)
    @user = user
    @photo = photo
  end

  #methods: create, destroy, show

  # Our policy is that a photo should only be seen by the owner or followers
  #   of the owner, unless the owner is not private in which case anyone can
  #   see it

  #only current user can create a new photo
  def new?
    user == current_user
  end

  #only owner can destroy photo
  def destroy?
    user == photo.owner
  end

  #only owner, non-private photo, and follower can view photos
  def show?
    user == photo.owner ||
      !photo.owner.private? ||
      photo.owner.followers.include?(user)
  end

end
