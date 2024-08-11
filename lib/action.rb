class Action
  attr_reader :id, :keys, :method, :description
  def initialize(id, args={})
    #TODO: Shouldn't have to reload this file every time
    description_file = YAML.load_file('strings/help_descriptions.yml')
    @id = id
    @keys = args[:keys] || [id.to_s]
    @method = args[:method] || "#{id.to_s}_action".to_sym
    description_key = args[:description_key] || "#{id.to_s}"
    @description = description_file[description_key]
  end
end
