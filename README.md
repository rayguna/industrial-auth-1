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
