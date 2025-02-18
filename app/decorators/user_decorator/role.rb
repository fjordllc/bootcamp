# frozen_string_literal: true

module UserDecorator
  module Role
    def roles(user: current_user)
      role_list = [
        { role: 'retired', value: retired? },
        { role: 'hibernationed', value: hibernated? },
        { role: 'admin', value: admin? },
        { role: 'mentor', value: mentor? },
        { role: 'adviser', value: adviser? },
        { role: 'graduate', value: graduated? },
        { role: 'trainee', value: trainee? }
      ]
      roles = role_list.find_all { |v| v[:value] }
                       .map { |v| v[:role] }
      roles << :student if roles.empty?
      roles.unshift('new-user') if user&.mentor? && (roles & %i[student trainee]).any? && elapsed_days <= 7

      roles
    end

    def primary_role(user: current_user)
      roles(user:).first
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

    def roles_to_s(user: current_user)
      return '' if roles(user:).empty?

      roles = [
        { role: '退会ユーザー', value: retired? },
        { role: '休会ユーザー', value: hibernated? },
        { role: '管理者', value: admin? },
        { role: 'メンター', value: mentor? },
        { role: 'アドバイザー', value: adviser? },
        { role: '卒業生', value: graduated? },
        { role: '研修生', value: trainee? }
      ]
      roles.find_all { |v| v[:value] }
           .map { |v| v[:role] }
           .join('、')
    end
  end
end
