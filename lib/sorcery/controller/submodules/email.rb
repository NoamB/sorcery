# module Sorcery
#   module Controller
#     module Submodules
#       # This module allows you to authenticate to the site using a mail server.
#       # Let's say your organization is called blup, and everyone has someklutz@blup.com,
#       # Instead of registering a new username and password for an internal web application,
#       # why not simply reuse your email credentials?
#       # Of course this means that if the mail server is down, nobody can authenticate to your app.
#       # I might add a fallback for that in the future.
#       module Email
#         def self.included(base)
#           base.send(:include, InstanceMethods)
#           Config.module_eval do
#             class << self
#               attr_reader :email_protocols                           # email protocols like pop3, IMAP etc.
#                                           
#               def merge_mail_defaults!
#                 @defaults.merge!(:@email_protocols => [])
#               end
#               
#               def email_protocols=(protocols)
#                 protocols.each do |protocol|
#                   include Protocols.const_get(protocol.to_s.split("_").map {|p| p.capitalize}.join(""))
#                 end
#               end
#             end
#             merge_mail_defaults!
#           end
#         end
# 
#         module InstanceMethods
#           protected
#           
#           # sends user to authenticate at the provider's website.
#           # after authentication the user is redirected to the callback defined in the provider config
#           def login_at(protocol)
# 
#           end
# 
#         end
#       end
#     end
#   end
# end