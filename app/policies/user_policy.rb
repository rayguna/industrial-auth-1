class UserPolicy < ApplicationPolicy

  def show_photos?
    record == user.username ||
     !record.private? || 
     record.followers.include?(user.username) || user.followers.include?(record)
  end

  def show?
    true
  end

  def feed?
    user == record
  end

  def discover?
    feed?
  end

end
