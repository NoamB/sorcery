class SimpleAuthMailer < ActionMailer::Base
  
  default :from => "notifications@example.com"
  
  def activation_needed_email(user)
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email,
         :subject => "Welcome to My Awesome Site")
  end
  
  def activation_success_email(user)
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email,
         :subject => "Your account is now activated")
  end
end