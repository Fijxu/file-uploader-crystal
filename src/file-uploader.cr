require "http"
require "kemal"
require "yaml"
require "mime"

# macro error(message)
#     env.response.content_type = "application/json"
#     env.response.status_code = 403
#     error_message = {"error" => {{message}}}.to_json
# 	error_message
#   end

class Config
  include YAML::Serializable

  property files : String = "./files"
  property filename_lenght : Int8 = 3

  def self.load
    config_file = "config/config.yml"
    config_yaml = File.read(config_file)
    config = Config.from_yaml(config_yaml)
    config
  end
end

CONFIG = Config.load

if !Dir.exists?("#{CONFIG.files}")
  begin
    Dir.mkdir("#{CONFIG.files}")
  rescue ex
    puts ex.message
    exit
  end
end

def random_string : String
  retardation = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  res = IO::Memory.new
  CONFIG.filename_lenght.times do
    "".rjust(res, 1, retardation[Random.rand(62)])
  end
  res.to_s
end

# TODO: Error checking later
post "/upload" do |env|
  filename = ""
  extension = ""
  HTTP::FormData.parse(env.request) do |upload|
    # if upload.filename.nil?
    #   error("No file provided")
    # end
    extension = File.extname("#{upload.filename}")
    filename = random_string()
    # filename = "#{Base64.urlsafe_encode("#{Random.rand(9999 % 1000)}", padding = false)}.#{upload.filename.to_s[extension + 1..]}"
    # Be sure to check if file.filename is not empty otherwise it'll raise a compile time error
    if !filename.is_a?(String)
      "This doesn't look like a file"
    else
      file_path = ::File.join ["#{CONFIG.files}", filename + extension]
      File.open(file_path, "w") do |file|
        IO.copy(upload.body, file)
      end
    end
  end
  env.response.content_type = "application/json"
  JSON.build do |j|
    j.object do
      j.field "link", "#{env.request.headers["Host"]}/#{filename + extension}"
    end
  end
end

get "/:filename" do |env|
  begin
    if !File.extname(env.params.url["filename"]).empty?
      send_file env, "#{CONFIG.files}/#{env.params.url["filename"]}"
	  next
    end
    dir = Dir.new("#{CONFIG.files}")
    dir.each do |filename|
      if filename.starts_with?("#{env.params.url["filename"]}")
        send_file env, "#{CONFIG.files}/#{env.params.url["filename"]}" + File.extname(filename)
      end
    end
	raise "Fuck"
  rescue
    env.response.content_type = "text/plain"
    env.response.status_code = 403
    "File does not exist"
  end
end

Kemal.run
