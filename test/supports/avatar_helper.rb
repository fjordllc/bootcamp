# frozen_string_literal: true

module AvatarHelper
  # ユーザーアイコンがwebpに変換されていることを確認するテストは、対象となるavatarをresetする。
  # （テスト環境では、複数のテストでavatarを共有する影響で、avatarに不具合が生じ画像変換処理が出来ない可能性があるため。）
  def reset_avatar(user)
    filename = "#{user.login_name}.jpg"
    path = Rails.root.join('test/fixtures/files', "users-avatars-#{filename}")
    user.avatar.attach(
      io: File.open(path, 'rb'),
      filename:,
      content_type: 'image/jpeg'
    )
  end
end
