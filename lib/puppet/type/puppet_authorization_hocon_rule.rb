Puppet::Type.newtype(:puppet_authorization_hocon_rule) do

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:path) do
    desc 'The file Puppet will ensure contains the specified setting.'
    validate do |value|
      unless (Puppet.features.posix? and value =~ /^\//) or (Puppet.features.microsoft_windows? and (value =~ /^.:\// or value =~ /^\/\/[^\/]+\/[^\/]+/))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  newproperty(:value, :array_matching => :all) do
    desc 'The value of the setting to be defined.'

    validate do |val|
      unless val.is_a?(Hash)
        raise "Value must be a hash but was #{value.class}"
      end
    end

    def insync?(is)
      # make sure all passed values are in the file
      Array(@resource[:value]).each do |v|
        if not provider.value.flatten.include?(v)
          return false
        end
      end
      return true
    end

    def change_to_s(current, new)
      real_new = []
      real_new << current
      real_new << new
      real_new.flatten!
      real_new.uniq!
      "value changed [#{Array(current).flatten.join(", ")}] to [#{real_new.join(", ")}]"
    end
  end

  validate do
    message = ""
    if self.original_parameters[:path].nil?
      message += "path is a required parameter. "
    end
    if self.original_parameters[:value].nil? && self[:ensure] != :absent
      message += "value is a required parameter unless ensuring a setting is absent."
    end
    if message != ""
      raise(Puppet::Error, message)
    end
  end
end
