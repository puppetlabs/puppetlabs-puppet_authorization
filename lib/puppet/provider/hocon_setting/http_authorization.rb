Puppet::Type.type(:hocon_setting).provide(:http_authorization, :parent => Puppet::Type.type(:hocon_setting).provider(:ruby)) do
  def set_value(value_to_set)
    if resource[:type] == 'array_element'
      tmp_val = []
      val = value
      Array(val).each do |v|
        tmp_val << v
      end
      Array(value_to_set).each do |v|
        unless tmp_val.include?(v)
          tmp_val << v
        end
      end

      tmp_val.sort_by! { |rule| [rule['sort-order'], rule['name']] }

      new_value = Hocon::ConfigValueFactory.from_any_ref(tmp_val, nil)

      conf_file_modified = conf_file.set_config_value(setting, new_value)

      return conf_file_modified
    else
      super
    end
  end
end
