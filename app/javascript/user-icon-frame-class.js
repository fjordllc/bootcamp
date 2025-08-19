export default function userIconFrameClass(primaryRole, joiningStatus) {
  const primaryRoleClass = primaryRole ? `is-${primaryRole}` : '';
  const newUserClass = joiningStatus === 'new-user' ? 'is-new-user' : ''
  return ['a-user-role', primaryRoleClass, newUserClass].filter(Boolean).join(' ');
}
