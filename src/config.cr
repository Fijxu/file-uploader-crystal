require "yaml"

class Config
  include YAML::Serializable

  property files : String = "./files"
  property filename_lenght : Int8 = 3
  property port : UInt16 = 8080
  property unix_socket : String?
  property delete_files_after : Int32 = 7

  def self.load
    config_file = "config/config.yml"
    config_yaml = File.read(config_file)
    config = Config.from_yaml(config_yaml)
    config
  end
end