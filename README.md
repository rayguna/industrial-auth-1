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


