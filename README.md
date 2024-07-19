# industrial-auth-1

Target: https://industrial-auth-1.matchthetarget.com/

Video: https://share.descript.com/view/qqL5sX534E1

Lesson: https://learn.firstdraft.com/lessons/201-photogram-industrial-authorization

## I. Photogram Industrial Authorization - the long way

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

1. Let's enable users to comment only public photos or photos of their leaders and not private photos. We will not allow comments if the current user is not the photo owner, the photo owner profile is private, and the current user does not follow the photo owner. Add a private method which is called before action:

```
# app/controllers/comments_controller.rb

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy ]
  before_action :is_an_authorized_user, only: [:destroy, :create]
  # ...
    def is_an_authorized_user
      @photo = Photo.find(params.fetch(:comment).fetch(:photo_id))
      if current_user != @photo.owner && @photo.owner.private? && !current_user.leaders.include?(@photo.owner)
        redirect_back fallback_location: root_url, alert: "Not authorized"
      end
    end
  # ...
end
```

2. Also, link comment table to owner through photo, so the attributes can be accessed:

```
# app/models/comment.rb

class Comment < ApplicationRecord
  belongs_to :author, class_name: "User", counter_cache: true
  belongs_to :photo, counter_cache: true
  has_one :owner, through: :photo

  validates :body, presence: true
end
```

#### E. Create a pull request

1. First, create a branch from the head with: `git checkout -b rg_photogram_industrial_authorization`. Publish the branch.
2. Switch main to the earliest version of the app with: `git reset --hard 46772ee`.
3. Update main `git push origin main --force`.

## II. Industrial Authorization Using Pundit

Create a new branch
1. The above changes are considered "painful". In the next lesson, we will learn to use some shortcuts with the pundit gem.
2. create a new branch: `git checkout -b rg_authorization_with_pundit`. Publish the branch.

Move main to a certain branch in three steps:
1. git checkout main
2. git reset --hard <commit-hash>
3. git push origin main --force

#### Objectives

1. create Pundit policies
2. use before_action
3. raise an exception
4. using Pundit helper method to gain access to the methods in all other controllers
5. incorporate Pundit into views
6. implement inheritance, aliasing, etc using Ruby
7. secure-by-default

***

#### A. Create Pundit policies

1. Install pundit as follows:
  - add gem "pundit" to your Gemfile
  - type: `bundle install`.

2. Create a folder within app/ called policies/, and within it create a file called photo_policy.rb and a class and initialize and show methods as follows. 


```
# app/policies/photo_policy.rb

class PhotoPolicy
  attr_reader :user, :photo

  def initialize(user, photo)
    @user = user
    @photo = photo
  end
end

# Our policy is that a photo should only be seen by the owner or followers
#   of the owner, unless the owner is not private in which case anyone can
#   see it
def show?
    user == photo.owner ||
      !photo.owner.private? ||
      photo.owner.followers.include?(user)
  end
end
```

3. Populate tables with `rake sample_data`.

4. Test if the policy is applied successfully as follows:
- First, get two users:

```
[1] pry(main)> alice = User.first
=> #<User id: 15>
[2] pry(main)> bob = User.second
=> #<User id: 16>
```

- Check followers and private status:

```
[3] pry(main)> alice.followers.include?(bob)
=> false
[4] pry(main)> alice.private?
=> true
```

- Get one of alice's photo:

```
photo = alice.own_photos.first
```

- First, we instantiate a policy for Alice, policy_a, and based on our .show? method, we check the visibility:

```
[6] pry(main)> policy_a = PhotoPolicy.new(alice, photo)
=> #<PhotoPolicy:0x00007fca9886d8e0>
[7] pry(main)> policy_a.show?
=> true
```

- Do the same for Bob:

```
[8] pry(main)> policy_b = PhotoPolicy.new(bob, photo)
=> #<PhotoPolicy:0x00007fca5fa3a6e8>
[9] pry(main)> policy_b.show?
=> false
```

#### B. Use before_action

1. Apply before_action as follows:

```
# app/controllers/photos_controller.rb

class PhotosController < ApplicationController
  before_action :set_photo, only: %i[ show edit update destroy ]
  before_action :ensure_current_user_is_owner, only: [:destroy, :update, :edit]
  before_action :ensure_user_is_authorized, only: [:show]
  
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

    def ensure_user_is_authorized
      if !PhotoPolicy.new(current_user, @photo).show?
        redirect_back fallback_location: root_url
      end
    end
  # ...
end
```

Navigating into a private user's photo should not be allowed. For example, looking at rails/db, we know that alethia is a private user and alexis is not private. Sign in with alexis and try to look at alethia's photo by visiting https://urban-spoon-wgr7j6ggj7fvjxr-3000.app.github.dev/alethia. In this case, no pictures are shown. 


#### C. Raising An Exception

1. Let's raise an exception and generate an error message instead of redirecting if the current_user is not authorized as follows.

```
# app/controllers/photos_controller.rb

class PhotosController < ApplicationController
  # ...
  before_action :ensure_user_is_authorized, only: [:show]
  # ...
    def ensure_user_is_authorized
      if !PhotoPolicy.new(current_user, @photo).show?
        raise Pundit::NotAuthorizedError, "not allowed"
      end
    end
  # ...
end
```

I tried to visit https://urban-spoon-wgr7j6ggj7fvjxr-3000.app.github.dev/alethia/liked, but no exception was raised.

- Alternatively, we can redirect with a flash message, as follows:

```
# app/controllers/application_controller.rb

class ApplicationController
  # ...
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      
      redirect_back fallback_location: root_url
    end
end
```

Notes:
- One security flaw in this app is that the /rails/db page is accessible.


#### D. Create a new branch - convention over configuration

1. Revert to previous version and create a new branch from the head with: `git checkout -b rg_pundit_authorization`. Publish the branch.
2. Incorporate photos exception with before_action

```
# app/controllers/photos_controller.rb

class PhotosController < ApplicationController
  before_action :set_photo, only: %i[ show edit update destroy ]
  before_action :ensure_current_user_is_owner, only: [:destroy, :update, :edit]
  before_action :ensure_user_is_authorized, only: [:show]
  
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

    def ensure_user_is_authorized
      if !PhotoPolicy.new(current_user, @photo).show?
        redirect_back fallback_location: root_url
      end
    end
  # ...
end
```

And:

```
# app/controllers/photos_controller.rb

class PhotosController < ApplicationController
  # ...
  before_action :ensure_user_is_authorized, only: [:show]
  # ...
    def ensure_user_is_authorized
      if !PhotoPolicy.new(current_user, @photo).show?
        raise Pundit::NotAuthorizedError, "not allowed"
      end
    end
  # ...
end
```

Also, 

```
# app/controllers/application_controller.rb

class ApplicationController
  # ...
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      
      redirect_back fallback_location: root_url
    end
end
```

Test it out by visiting: https://urban-spoon-wgr7j6ggj7fvjxr-3000.app.github.dev/photos/115

Find out this route by going to https://urban-spoon-wgr7j6ggj7fvjxr-3000.app.github.dev/rails/info/routes and search for photo. To get the valid photo id, go to ..rails/db.

3. Incorporate pundit to raise the exception. Add the command `include Pundit`.

```
# app/controllers/application_controller.rb

class ApplicationController
  include Pundit
# ...
```

and

```
# app/controllers/photos_controller.rb

class PhotosController < ApplicationController
  # ...
  def show
    authorize @photo
  end
  # ...
end
```

As before, test out the new approach of using Pundit by visiting https://urban-spoon-wgr7j6ggj7fvjxr-3000.app.github.dev/photos/115. Commenting and uncommenting `authorize @photo` command confirms that the change works.

4. Shorthand. An easier way to incorporate the authorization, rather than specifying everywhere in each method you can just add at the top of the class. After this, you can comment the authorize @photo.

```
  before_action {authorize @photo }
```

And

class PhotosController < ApplicationController
  #...
  def show
    #authorize @photo
  end
  #...
end
```

5. Make the following modification:

```
#app/controllers/application_controller.rb

class ApplicationController
  include Pundit
  
  after_action :verify_authorized, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?
  #...
```

You will find that you can't access even the user main page (i.e., root URL) because it is set to users#feed. To remove the error, dd this to your app/policies/user_policy.rb file:

```
def feed?
  true
end
```

You also get an error saying that authorization not performed. To give authorization, add:

```
controlllers/users_controller.rb

class UsersController < ApplicationController
  before_action :set_user, only: %i[ show liked feed followers following discover ]

  before_action {authorize @user }
```

### E. Implementing authorization throughout

1. create the corresponding _policy.rb for comments.rb, follow_request.rb, photos.rb, and users.rb.
2. Fixed the delete button. Previously used ajax delete command, rather than Ruby's. It should be:

```
data: { turbo_method: :delete }
```

Rather than:

```
data: { turbo_method: :delete }
```

3. To incorporate changes, the main needs to be at your branch. Don't just use git checkout <branch_name>. In this case, your changes won't be saved. It should be:

```
git checkout main
git reset --hard <branch_name>
git push origin main --force
```

### F. Enable Pundit

1. Add in the *_controller.rb class, e.g., `before_action { authorize @comment || Comment}`. Note that your are giving access to both the parameter @comment and the ActiveRecords Commment. Both are essential! 
2. create the corresponding `*_policy.rb`.
3. Set the appropriate methods to true at certain desired conditions. Note that the methods within the policy return a boolean (i.e, true or false). 
4. For all policy classes, except user, the class initialize inputs are user and method function. For user policy class, the inputs are current_user and user.
5. Look through the policy files to understand how the policy methods are defined. These definitions are based on which operations you would like to over-ride. Note how oop and method calling is applied to activerecords. Also, note that edit and update go together for comments. Also note that all policies inherit from ApplicationPolicy.
6. If in doubt what the method is called, go to the application_policy, which is where all default methods are initialized.
7. TIPS:
- INHERITANCE: Each of the policy inherits from application_policy.rb, therefore you don't have to call the def initialize each and every time. You also don't have to define the attr in each of the *_policy.rb, AS LONG AS you refer to the specific instance as record and the instance of the user as user consistently for each of the policy. 
- Each of the policy classes requires two inputs, the first one being the instance of the logged in user and the second one being the instance of the specific policy. 

8. Enable the relevant methods within comment activerecords.

- Got the error message: `ActionController::ParameterMissing - param is missing or the value is empty: comment: `app/controllers/comments_controller.rb:83:in is_an_authorized_user'`.
- To resolve this issue, set the is_an_authorized_user method as follows:

```
    def is_an_authorized_user
      if params.key?(:comment)
        photo = params[:comment][:photo_id]
      else
        comment = Comment.find(params[:id])
        photo = comment.photo.id
      end
      
      @photo = Photo.find(photo) #(params.fetch(:comment).fetch(:photo_id))
      if current_user != @photo.owner && @photo.owner.private? && !current_user.leaders.include?(@photo.owner)
        redirect_back fallback_location: root_url, alert: "Not authorized"
      end
    end
```

9. Enable the relevant methods within photo activerecords. 

- Had to create a new method called show_photo to SEPARATE the existing method called photo. This is to separately display photos for followers, following, and public users. The show method shows the user page, whereas show_photo shows the partial photos page. This conditional statement is defined within the photo views/users/show.html.erb page:

    ```
    <div class="row mb-4">
      <div class="col-md-6 offset-md-3">
        <%= render "users/user", user: @user %>
      </div>
    </div>

    <% if policy(@user).show_photos? %>
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
10. Enable the relevant methods within comment activerecords.
- I found that editing the photo comment will redirect the page to user's feed page even when the edit is made in user's profile page. It is left this way because the feed page is regarded as the root_url. Furthermore, the user will be redirected to the root_url even when edit is made on the root_url. 
11. Enable the relevant methods within follow_request activerecords. 
- Set the methods within follow_request_policy.rb as follows:

  ```
  class FollowRequestPolicy < ApplicationPolicy

    #methods: create (always true), destroy and update (only owner)
    def create?
      true
    end

    def new?
      true
    end

    def update?
      user == record.sender
    end

    def edit?
      update?
    end

    def destroy?
      update?
    end

  end
  ```

  ### G. Create a pull request
  
  1. Accidentally reverted to previous version without first creating a branch and almost lost the most recent version with:
  - Type `git checkout main`.
  - git reset --hard 2aabcf1
  - git push origin main --force

2. Revert to the previous most recent version with:

- git reflog:

```
2aabcf1 (HEAD -> main, origin/rg_pundit_authorization, origin/main, origin/HEAD) HEAD@{0}: reset: moving to 2aabcf1
af4f898 HEAD@{1}: checkout: moving from main to main
af4f898 HEAD@{2}: commit: updated README.md.
852823e HEAD@{3}: commit: updated README.md.
c84360a HEAD@{4}: commit: Fixed comment and follow_request policies.
f767b92 HEAD@{5}: commit: fixed photo and user policies.
bd9d027 HEAD@{6}: clone: from https://github.com/rayguna/industrial-auth-1.git
```

- git reset --hard af4f898
- git push origin main --force

3. Now, create a new branch with: 

  1. First, create a branch from the head with: `git checkout -b rg_pundit`. Publish the branch.
  2. Switch main to the earliest version of the app with: `git reset --hard 2aabcf1`.
  3. Update main `git push origin main --force`.


***
