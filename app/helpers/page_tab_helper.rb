module PageTabHelper
  def page_tab_members(resource)
    case resource
    when Practice
      practices_tab_members(resource)
    end
  end

  def current_page_tab_or_not(target_name)
    current_page_tab?(target_name) ? 'is-current' : ''
  end

  private
    def practices_tab_members(resource)
      [
        root_tab(resource),
        reports_tab(resource),
        products_tab(resource)
      ]
    end

    def root_tab(resource)
      page_tab_member(resource, resource.class.name.tableize.to_sym)
    end

    def page_tab_member(path, tab_name, admin_displayable: false)
      {
        path: path,
        target_name: tab_name.to_s,
        display_name: display_tab_name(tab_name),
        admin_displayable: admin_displayable
      }
    end

    def display_tab_name(tab_name)
      display_tab_names[tab_name]
    end

    def display_tab_names
      {
        practices: 'プラクティス',
        reports: '日報',
        products: '提出物'
      }
    end

    def reports_tab(resource)
      tab_name = :reports
      page_tab_member(eval(tab_path(resource, tab_name)), tab_name)
    end

    def tab_path(resource, tab_name)
      "#{resource.class.name.underscore}_#{tab_name.to_s}_path(resource)"
    end

    def products_tab(resource)
      tab_name = :products
      page_tab_member(eval(tab_path(resource, tab_name)), tab_name, admin_displayable: true)
    end

    def current_page_tab?(target_name)
      paths = request.fullpath.split('/')
      if paths[-2] == target_name
        true
      else
        paths.last == target_name
      end
    end
end
