require "http"
require "kemal"
require "yaml"
# require "mime"

require "./utils"
require "./config"

# macro error(message)
#     env.response.content_type = "application/json"
#     env.response.status_code = 403
#     error_message = {"error" => {{message}}}.to_json
# 	error_message
#   end

CONFIG = Config.load

if !Dir.exists?("#{CONFIG.files}")
  begin
    Dir.mkdir("#{CONFIG.files}")
  rescue ex
    puts ex.message
    exit
  end
end

get "/" do |env|
  render "src/views/index.ecr"
end

# TODO: Error checking later
post "/upload" do |env|
  filename = ""
  extension = ""
  HTTP::FormData.parse(env.request) do |upload|
    next if upload.filename.nil? || upload.filename.to_s.empty?
    pp upload
    extension = File.extname("#{upload.filename}")
    filename = Utils.random_string(CONFIG.filename_lenght)
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
  if !filename.empty?
    JSON.build do |j|
      j.object do
        j.field "link", "#{env.request.headers["Host"]}/#{filename + extension}"
      end
    end
  else
    env.response.content_type = "application/json"
    env.response.status_code = 403
    error_message = {"error" => "No file"}.to_json
    error_message
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
    raise ""
  rescue
    env.response.content_type = "text/plain"
    env.response.status_code = 403
    "File does not exist"
  end
end

# delete "/:filename" do |env|
#   begin
#     if !File.extname(env.params.url["filename"]).empty?
#       File.delete?("#{CONFIG.files}/#{env.params.url["filename"]}")
# 	  "File deleted successfully"
# 	  next
#     end
#     dir = Dir.new("#{CONFIG.files}")
#     dir.each do |filename|
#       if filename.starts_with?("#{env.params.url["filename"]}")
#         File.delete?("#{CONFIG.files}/#{env.params.url["filename"]}" + File.extname(filename))
# 		"File deleted successfully"
#       end
#     end
# 	raise ""
#   rescue
#     env.response.content_type = "text/plain"
#     env.response.status_code = 403
#     "File does not exist"
#   end
# end

Kemal.run
