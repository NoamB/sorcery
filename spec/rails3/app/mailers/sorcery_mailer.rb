class SorceryMailer < ActionMailer::Base
  
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
  
  def reset_password_email(user)
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email,
         :subject => "Your password has been reset")
  end

  def send_unlock_token_email(user)
    @user = user
    @url = "http://example.com/unlock/#{user.unlock_token}"
    mail(:to => user.email,
         :subject => "Your account has been locked due to many wrong logins")
  end
end