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

  def remove_value(value_to_remove)
    if resource[:type] == 'array_element' && resource[:setting] == 'authorization.rules'
      # Similar to set_value, only consider the rule name when looking for the
      # rule to remove.
      new_value_tmp = Array(value).reject do |existing|
        Array(value_to_remove).any? { |v| existing['name'] == v['name'] }
      end

      new_value = Hocon::ConfigValueFactory.from_any_ref(new_value_tmp, nil)
      conf_file_modified = conf_file.set_config_value(setting, new_value)
      return conf_file_modified
    else
      super
    end
  end

  def exists?
    if resource[:type] == 'array_element' &&
       resource[:setting] == 'authorization.rules' &&
       resource[:ensure] == :absent
      # Similar to remove_value, only consider rule name when looking for the
      # rule to delete.
      value.any? do |existing|
        Array(@resource[:value]).any? { |v| existing['name'] == v['name'] }
      end
    else
      super
    end
  end
end
