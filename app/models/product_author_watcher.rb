# frozen_string_literal: true

class ProductAuthorWatcher
  def call(_name, _started, _finished, _unique_id, payload)
    product = payload[:product]
    Watch.register!(user: product.user, watchable: product)
  end
end
