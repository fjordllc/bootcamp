export function UserIconFrameClass(user) {
  return `a-user-role is-${user.primary_role} ${
    user.joining_status === 'new-user' ? 'is-new-user' : ''
  }`
}
