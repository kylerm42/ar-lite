class AttrAccessorObject
  def self.my_attr_accessor(*names)
    my_attr_writer(*names)
    my_attr_reader(*names)
  end

  def self.my_attr_reader(*names)
    names.each do |name|
      define_method(name) do
        self.instance_variable_get("@#{name}")
      end
    end
  end

  def self.my_attr_writer(*names)
    names.each do |name|
      define_method("#{name}=") do |val|
        self.instance_variable_set("@#{name}", val)
      end
    end
  end
end
