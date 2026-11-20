export default function guardTributeMenuClicks(tribute) {
  const originalClick = tribute.events.click
  tribute.events.click = function (instance, event) {
    const menu = instance.tribute.menu
    if (menu && menu.contains(event.target)) {
      let item = event.target
      // Tribute 5.1.3 assumes every click inside the menu belongs to an li.
      while (item !== menu && item.nodeName.toLowerCase() !== 'li') {
        item = item.parentNode
      }
      if (item === menu) return
    }
    return originalClick.call(this, instance, event)
  }
}
