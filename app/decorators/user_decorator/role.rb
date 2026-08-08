# frozen_string_literal: true

module UserDecorator
  module Role
    def roles
      role_list = [
        { role: 'retired', value: UserStatus.new(self).retired? },
        { role: 'training_completed', value: UserStatus.new(self).training_completed? },
        { role: 'hibernationed', value: UserStatus.new(self).hibernated? },
        { role: 'admin', value: admin? },
        { role: 'mentor', value: mentor? },
        { role: 'adviser', value: adviser? },
        { role: 'graduate', value: UserStatus.new(self).graduated? },
        { role: 'trainee', value: trainee? }
      ]
      roles = role_list.find_all { |v| v[:value] }
                       .map { |v| v[:role] }
      roles << :student if roles.empty?

      roles
    end

    def primary_role
      roles.first
    end

    def staff_roles
      staff_roles = [
        { role: '管理者', value: admin? },
        { role: 'メンター', value: mentor? },
        { role: 'アドバイザー', value: adviser? }
      ]
      staff_roles.find_all { |v| v[:value] }
                 .map { |v| v[:role] }
                 .join('、')
    end

    def roles_to_s
      return '' if roles.empty?

      roles = [
        { role: '退会ユーザー', value: UserStatus.new(self).retired? },
        { role: '休会ユーザー', value: UserStatus.new(self).hibernated? },
        { role: '管理者', value: admin? },
        { role: 'メンター', value: mentor? },
        { role: 'アドバイザー', value: adviser? },
        { role: '卒業生', value: UserStatus.new(self).graduated? },
        { role: '研修生', value: trainee? }
      ]
      roles.find_all { |v| v[:value] }
           .map { |v| v[:role] }
           .join('、')
    end
  end
end
