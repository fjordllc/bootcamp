import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import { FetchRequest } from '@rails/request.js'
import userIconFrameClass from './user-icon-frame-class.js'

dayjs.extend(relativeTime)

class NotificationsBell {
  constructor() {
    this.container = document.getElementById('notifications-bell-container')
    if (!this.container) return

    this.apiUrl = this.container.dataset.apiUrl
    this.bellButton = document.getElementById('notifications-bell-button')
    this.dropdown = document.getElementById('notifications-dropdown')
    this.background = document.getElementById('notifications-background')
    this.unreadTab = document.getElementById('unread-tab')
    this.allTab = document.getElementById('all-tab')
    this.notificationsList = document.getElementById('notifications-list')
    this.notificationsContent = document.getElementById('notifications-content')
    this.notificationsFooter = document.getElementById('notifications-footer')
    this.notificationCount = document.getElementById('notification-count')
    this.notificationLoading = document.getElementById('notification-loading')
    this.notificationsLoading = document.getElementById('notifications-loading')
    this.emptyMessage = document.getElementById('empty-message')
    this.emptyText = document.getElementById('empty-text')
    this.emptyLinkContainer = document.getElementById('empty-link-container')
    this.headerPageLink = document.getElementById('header-page-link')
    this.notificationsPageLink = document.getElementById(
      'notifications-page-link'
    )
    this.openAllTabs = document.getElementById('open-all-tabs')

    this.targetStatus = 'unread'
    this.notifications = null
    this.unreadNotifications = null
    this.loadNotificationsController = null

    this.bindEvents()
    this.loadUnreadCount()
  }

  bindEvents() {
    this.bellButton.addEventListener('click', () => {
      this.showDropdown()
    })

    this.background.addEventListener('click', (e) => {
      if (e.target === e.currentTarget) {
        this.hideDropdown()
      }
    })

    this.unreadTab.addEventListener('click', () => {
      this.setTargetStatus('unread')
    })

    this.allTab.addEventListener('click', () => {
      this.setTargetStatus('all')
    })

    this.openAllTabs.addEventListener('click', () => {
      this.openUnconfirmedItems()
    })

    // Close dropdown on escape key
    document.addEventListener('keydown', (e) => {
      if (
        e.key === 'Escape' &&
        !this.dropdown.classList.contains('is-hidden')
      ) {
        this.hideDropdown()
      }
    })
  }

  showDropdown() {
    this.dropdown.classList.remove('is-hidden')
    this.bellButton.setAttribute('aria-expanded', 'true')
    this.loadNotifications()
  }

  hideDropdown() {
    this.dropdown.classList.add('is-hidden')
    this.bellButton.setAttribute('aria-expanded', 'false')
  }

  setTargetStatus(status) {
    this.targetStatus = status

    // Update tab active states and ARIA attributes
    if (status === 'unread') {
      this.unreadTab.classList.add('is-active')
      this.unreadTab.setAttribute('aria-selected', 'true')
      this.allTab.classList.remove('is-active')
      this.allTab.setAttribute('aria-selected', 'false')
    } else {
      this.unreadTab.classList.remove('is-active')
      this.unreadTab.setAttribute('aria-selected', 'false')
      this.allTab.classList.add('is-active')
      this.allTab.setAttribute('aria-selected', 'true')
    }

    this.loadNotifications()
  }

  async loadUnreadCount() {
    this.notificationLoading.classList.remove('is-hidden')

    try {
      const request = new FetchRequest('get', this.apiUrl, {
        query: { status: 'unread' }
      })
      const response = await request.perform()

      if (response.ok) {
        const data = await response.json
        this.unreadNotifications = data.notifications
        this.updateBellBadge()
      } else {
        console.warn(
          'Failed to load unread notifications: HTTP',
          response.status
        )
      }
    } catch (error) {
      console.warn('Failed to load unread notifications:', error)
    } finally {
      this.notificationLoading.classList.add('is-hidden')
    }
  }

  async loadNotifications() {
    // Cancel any in-flight request
    if (this.loadNotificationsController) {
      this.loadNotificationsController.abort()
    }
    this.loadNotificationsController = new AbortController()
    const { signal } = this.loadNotificationsController

    this.showLoading()

    try {
      const query =
        this.targetStatus === 'all'
          ? { page: 1, per: 10 }
          : { status: this.targetStatus }

      const request = new FetchRequest('get', this.apiUrl, { query, signal })
      const response = await request.perform()

      // Check if this request was aborted
      if (signal.aborted) return

      if (response.ok) {
        const data = await response.json
        this.notifications = data.notifications
        this.renderNotifications()
        this.updateHeader()
        this.updateFooter()
      } else {
        console.warn('Failed to load notifications: HTTP', response.status)
        this.showError()
      }
    } catch (error) {
      // Ignore abort errors
      if (error.name === 'AbortError') return

      console.warn('Failed to load notifications:', error)
      this.showError()
    } finally {
      if (!signal.aborted) {
        this.hideLoading()
      }
    }
  }

  updateBellBadge() {
    if (!this.unreadNotifications) return

    const count = this.unreadNotifications.length

    if (count > 0) {
      const displayCount = count > 99 ? '99+' : count.toString()
      this.notificationCount.textContent = displayCount
      this.notificationCount.classList.remove('is-hidden')
    } else {
      this.notificationCount.classList.add('is-hidden')
    }
  }

  showLoading() {
    this.notificationsLoading.classList.remove('is-hidden')
    this.notificationsList.classList.add('is-hidden')
    this.emptyMessage.classList.add('is-hidden')
  }

  hideLoading() {
    this.notificationsLoading.classList.add('is-hidden')
  }

  showError() {
    // Simple error handling - could be enhanced
    this.notificationsList.innerHTML = '<li>Failed to load notifications</li>'
    this.notificationsList.classList.remove('is-hidden')
  }

  renderNotifications() {
    if (!this.notifications || this.notifications.length === 0) {
      this.showEmptyMessage()
      return
    }

    this.notificationsList.innerHTML = ''
    this.notifications.forEach((notification) => {
      const li = this.createNotificationElement(notification)
      this.notificationsList.appendChild(li)
    })

    this.notificationsList.classList.remove('is-hidden')
    this.emptyMessage.classList.add('is-hidden')
  }

  createNotificationElement(notification) {
    const li = document.createElement('li')
    li.className = 'header-dropdown__item'

    const createdAtFromNow = dayjs(notification.created_at).fromNow()
    const iconFrameClass = userIconFrameClass(
      notification.sender.primary_role,
      notification.sender.joining_status
    )

    // Build DOM elements safely without innerHTML
    const link = document.createElement('a')
    link.setAttribute('href', notification.path)
    link.classList.add('header-dropdown__item-link', 'unconfirmed_link')

    const body = document.createElement('div')
    body.className = 'header-notifications-item__body'

    const iconWrapper = document.createElement('span')
    iconFrameClass.split(' ').forEach((cls) => {
      if (cls) iconWrapper.classList.add(cls)
    })
    iconWrapper.classList.add('header-notifications-item__user-icon')

    const img = document.createElement('img')
    img.setAttribute('src', notification.sender.avatar_url)
    img.setAttribute('alt', 'User Icon')
    img.className = 'a-user-icon'
    iconWrapper.appendChild(img)

    const messageDiv = document.createElement('div')
    messageDiv.className = 'header-notifications-item__message'

    const messageP = document.createElement('p')
    messageP.className = 'test-notification-message'
    messageP.textContent = notification.message
    messageDiv.appendChild(messageP)

    const timeEl = document.createElement('time')
    timeEl.className = 'header-notifications-item__created-at'
    timeEl.textContent = createdAtFromNow

    body.appendChild(iconWrapper)
    body.appendChild(messageDiv)
    body.appendChild(timeEl)
    link.appendChild(body)
    li.appendChild(link)

    return li
  }

  showEmptyMessage() {
    const isUnreadTab = this.targetStatus === 'unread'

    this.emptyText.textContent = isUnreadTab
      ? '未読の通知はありません'
      : '通知はありません'

    if (isUnreadTab) {
      this.emptyLinkContainer.classList.remove('is-hidden')
    } else {
      this.emptyLinkContainer.classList.add('is-hidden')
    }

    this.emptyMessage.classList.remove('is-hidden')
    this.notificationsList.classList.add('is-hidden')
  }

  updateHeader() {
    const notificationsCount = this.notifications?.length || 0
    const isUnreadTab = this.targetStatus === 'unread'

    if (notificationsCount > 0) {
      const notificationsUrl = isUnreadTab
        ? '/notifications?status=unread'
        : '/notifications'
      const linkLabel = isUnreadTab
        ? '全ての未読通知一覧へ'
        : '全ての通知一覧へ'

      this.notificationsPageLink.href = notificationsUrl
      this.notificationsPageLink.textContent = linkLabel
      this.headerPageLink.classList.remove('is-hidden')
    } else {
      this.headerPageLink.classList.add('is-hidden')
    }
  }

  updateFooter() {
    const notificationsCount = this.notifications?.length || 0
    const isUnreadTab = this.targetStatus === 'unread'

    if (isUnreadTab && notificationsCount > 0) {
      this.notificationsFooter.classList.remove('is-hidden')
    } else {
      this.notificationsFooter.classList.add('is-hidden')
    }
  }

  openUnconfirmedItems() {
    const links = document.querySelectorAll(
      '.header-dropdown__item-link.unconfirmed_link'
    )
    links.forEach((link) => {
      window.open(link.href, '_blank', 'noopener')
    })
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  const bell = new NotificationsBell()
  return bell
})
