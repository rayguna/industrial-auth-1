# industrial-auth-1

Target: https://industrial-auth-1.matchthetarget.com/

Video: https://share.descript.com/view/qqL5sX534E1

Lesson: https://learn.firstdraft.com/lessons/201-photogram-industrial-authorization

### A. Objectives:
- Hide certain routes, such as:
  - /comments
  - /photos
  - /likes
  - /follow_requests
  - /ID/edit
- Make private profiles private.
- Using scaffold and leaving all routes will make the above routes available.

### B. Tasks

Hide the links and lock the ability to do the following:
  - delete and edit photos and comments that don't belong to the user.
  - view other user's posts and like section unless the profile is not private or the user is an accepted follower.
  - see other user's pending follow requests.
  - see a collection of photos of another user's leaders (feed, discover). For instance, /carol/feed and /carol/discover should not be visitable by other users, but Carol herself.

### C. Approach

1. Consider each and every route and action a user can take. 
2. Solve security holes with:
- Filters: before_action and skip_before_action (https://guides.rubyonrails.org/action_controller_overview.html#filters).
- Redirecting: redirect_to and redirect_back (https://api.rubyonrails.org/v6.1.0/classes/ActionController/Redirecting.html).
- Devise’s current_user method.
- Ruby’s if/else statements.
- Deleting or limiting routes with only: and except: after resources.

### D. Step-by-step Procedure

#### D1. Limit routes using `except` and `only`.
1. Populate tables with `rails sample_data`.
2. Run server with `bin/dev` and login as alice.
3. (5-11 min) There are several GET actions available for each route. Here are some of it:
  - index
  - show
  - new
  - edit
  - create
  - destroy
  - update

4. We can limit routes by adding except: or only: parameters.

For the follow_request route, we only allow a user to: create, update, and destroy. Other actions, such as ubdex, show, new, and edit are not allowed. In this case,let's change the routes.rb as follows.

```
# config/routes.rb

Rails.application.routes.draw do
  # ...
  resources :comments
  resources :follow_requests, except: [:index, :show, :new, :edit]
  # ...
```

5. For likes, we only allow a user to create and destroy.

```
# config/routes.rb

Rails.application.routes.draw do
  # ...
  resources :follow_requests, except: [:index, :show, :new, :edit]
  resources :likes, only: [:create, :destroy]
  # ...
```

6. For ohotos, we need most of the routes, but the index:

```
# config/routes.rb

Rails.application.routes.draw do
  # ...
  resources :follow_requests, except: [:index, :show, :new, :edit]
  resources :likes, only: [:create, :destroy]
  resources :photos, except: [:index]
  # ...
```
However, you can delete not just your photos, but other people's as well.

#### D2. Authorization in controller with before_action

1. Controller is one level below the routing, where we can restrict and fix photo deletion to allow a user to only delete his/her photo and not other users'.  
2. One way to restrict a user from deleting another user's photo is by adding an if-else statement within app/controllers/photos_controller.rb, as follows.

```
  # ...
  def destroy
    if current_user == @photo.owner
      @photo.destroy

      respond_to do |format|
        format.html { redirect_back fallback_location: root_url, notice: "Photo was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      redirect_back(fallback_location: root_url, notice: "Nice try, but that is not your photo.")
    end
  end
  # ...
```

3. Alternatively, check the ownership on some other actions.using before_action as follows. Use this approach in place of the previous one.

```
# app/controllers/photos_controller.rb

class PhotosController < ApplicationController
  before_action :set_photo, only: %i[ show edit update destroy ]
  before_action :ensure_current_user_is_owner, only: [:destroy, :update, :edit]
  # ...
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    def ensure_current_user_is_owner
      if current_user != @photo.owner
        redirect_back fallback_location: root_url, alert: "You're not authorized for that."
      end
    end
  # ...
end
```

#### D3. Conditionals in the view templates

1. On the html page, let's hide the links/buttons/icons that are not available to the user (e.g., the edit or delete font awesome links to photos should not be visible to the users).
2. Use the conditional statement to show these buttons only if the current_user is the photo owner.

```
<!-- app/views/photos/_photo.html.erb -->

<div class="card">
  <div class="card-body py-3 d-flex align-items-center justify-content-between">
    <h2 class="h5 m-0 p-0 d-flex align-items-center">
      <%= image_tag photo.owner.avatar_image, class: "rounded-circle mr-2", width: 36 %>

      <%= link_to photo.owner.username, user_path(photo.owner.username), class: "text-dark" %>
    </h2>

    <div>
      <% if current_user == photo.owner %>
        <%= link_to edit_photo_path(photo), class: "btn btn-link btn-sm text-muted" do %>
          <i class="fas fa-edit fa-fw"></i>
        <% end %>

        <%= link_to photo, method: :delete, class: "btn btn-link btn-sm text-muted" do %>
          <i class="fas fa-trash fa-fw"></i>
        <% end %>
      <% end %>
      
    </div>
  </div>
<!-- ... -->
```

#### D4. Hiding private users

1. Use conditionals in the views/users/show.html.erb page to hide private users that are set to "Private" or not being followed. We encapsulate this within the variable truevalue which includes three conditions.  

```
<!-- app/views/users/show.html.erb -->

<div class="row mb-4">
  <div class="col-md-6 offset-md-3">
    <%= render "users/user", user: @user %>
  </div>
</div>

<% truevalue = current_user == @user || !@user.private? || current_user.leaders.include?(@user) %>

<% if truevalue %>
  <div class="row mb-2">
    <div class="col-md-6 offset-md-3">
      <%= render "users/profile_nav", user: @user %>
    </div>
  </div>

  <% @user.own_photos.each do |photo| %>
    <div class="row mb-4">
      <div class="col-md-6 offset-md-3">
        <%= render "photos/photo", photo: photo %>
      </div>
    </div>
  <% end %>
<% end %>
```


#### D5. Commenting on a photo


#### D6. Industrial authorization with pundit

The above changes are considered "painful". In the next lesson, we will learn to use some shortcuts with the pundit gem.

***
