# frozen_string_literal: true

module NotificationHelper

    def read_batche(target)
        if target == 'announcement' 
            return Cache.read_announcement_count(current_user.id)
        end
      end

      def unread_batche(target)
        if target == 'announcement' 
            return Cache.unread_announcement_count(current_user.id)
        end
      end
  end