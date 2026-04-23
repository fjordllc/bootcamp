json.partial! "api/users/user", user: @user
json.email @user.email if @include_email
