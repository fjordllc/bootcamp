import { toast } from './vanillaToast'
import { FetchRequest } from '@rails/request.js'

export const checkProduct = async (productId, currentUserId, url, method) => {
  try {
    const request = new FetchRequest(method, url, {
      redirect: 'manual',
      body: {
        product_id: productId,
        current_user_id: currentUserId
      }
    })

    const response = await request.perform()
    const body = await response.json

    if (response.ok) {
      if (body.checker_id !== null) {
        toast('担当になりました。')
      } else {
        toast('担当から外れました。')
      }
    } else {
      if (body.message) {
        toast(body.message, 'error')
      }
    }
  } catch (error) {
    console.warn(error)
  }
}
