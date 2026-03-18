import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
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
    this.notificationsPageLink = document.getElementById('notifications-page-link')
    this.openAllTabs = document.getElementById('open-all-tabs')

    this.targetStatus = 'unread'
    this.notifications = null
    this.unreadNotifications = null

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
      if (e.key === 'Escape' && !this.dropdown.classList.contains('is-hidden')) {
        this.hideDropdown()
      }
    })
  }

  showDropdown() {
    this.dropdown.classList.remove('is-hidden')
    this.loadNotifications()
  }

  hideDropdown() {
    this.dropdown.classList.add('is-hidden')
  }

  setTargetStatus(status) {
    this.targetStatus = status
    
    // Update tab active states
    if (status === 'unread') {
      this.unreadTab.classList.add('is-active')
      this.allTab.classList.remove('is-active')
    } else {
      this.unreadTab.classList.remove('is-active')
      this.allTab.classList.add('is-active')
    }

    this.loadNotifications()
  }

  async loadUnreadCount() {
    this.notificationLoading.classList.remove('is-hidden')
    
    try {
      const response = await fetch(`${this.apiUrl}?status=unread`)
      const data = await response.json()
      this.unreadNotifications = data.notifications
      this.updateBellBadge()
    } catch (error) {
      console.warn('Failed to load unread notifications:', error)
    } finally {
      this.notificationLoading.classList.add('is-hidden')
    }
  }

  async loadNotifications() {
    this.showLoading()
    
    try {
      const url = this.targetStatus === 'all' 
        ? `${this.apiUrl}?page=1&per=10`
        : `${this.apiUrl}?status=${this.targetStatus}`
        
      const response = await fetch(url)
      const data = await response.json()
      this.notifications = data.notifications
      this.renderNotifications()
      this.updateHeader()
      this.updateFooter()
    } catch (error) {
      console.warn('Failed to load notifications:', error)
      this.showError()
    } finally {
      this.hideLoading()
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
    this.notifications.forEach(notification => {
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

    li.innerHTML = `
      <a href="${notification.path}" class="header-dropdown__item-link unconfirmed_link">
        <div class="header-notifications-item__body">
          <span class="${iconFrameClass} header-notifications-item__user-icon">
            <img src="${notification.sender.avatar_url}" class="a-user-icon" alt="User Icon" />
          </span>
          <div class="header-notifications-item__message">
            <p class="test-notification-message">${notification.message}</p>
          </div>
          <time class="header-notifications-item__created-at">${createdAtFromNow}</time>
        </div>
      </a>
    `

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
      const notificationsUrl = isUnreadTab ? '/notifications?status=unread' : '/notifications'
      const linkLabel = isUnreadTab ? '全ての未読通知一覧へ' : '全ての通知一覧へ'
      
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
    const links = document.querySelectorAll('.header-dropdown__item-link.unconfirmed_link')
    links.forEach(link => {
      window.open(link.href, '_blank', 'noopener')
    })
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  new NotificationsBell()
})