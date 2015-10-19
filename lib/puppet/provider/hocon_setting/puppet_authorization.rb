Puppet::Type.type(:hocon_setting).provide(:puppet_authorization, :parent => Puppet::Type.type(:hocon_setting).provider(:ruby)) do
  def set_value(value_to_set)
    if resource[:type] == 'array_element' && resource[:setting] == 'authorization.rules'
      # Prevent duplicate rules by removing existing ones that have the same
      # rule name as the new value_to_set.
      tmp_val = Array(value).reject do |existing|
        value_to_set.any? { |new_val| existing['name'] == new_val['name'] }
      end
      tmp_val.concat(value_to_set)
      tmp_val.sort_by! { |rule| [rule['sort-order'], rule['name']] }

      new_value = Hocon::ConfigValueFactory.from_any_ref(tmp_val, nil)
      conf_file_modified = conf_file.set_config_value(setting, new_value)
      return conf_file_modified
    else
      super
    end
  end
end
