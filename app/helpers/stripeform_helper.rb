 # frozen_string_literal: true

 module StripeformHelper
   STRIPE_FORM_PATHS = [
     "card/new",
     "card/edit",
     "users/new"
   ]

   def stripeform_page?
     "#{controller_path}/#{params[:action]}".in?(STRIPE_FORM_PATHS)
   end
 end
