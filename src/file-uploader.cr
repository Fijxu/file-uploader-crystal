require "http"
require "kemal"
require "yaml"
# require "mime"

require "./utils"
require "./handling"
require "./lib/**"
require "./config"

# macro error(message)
#     env.response.content_type = "application/json"
#     env.response.status_code = 403
#     error_message = {"error" => {{message}}}.to_json
# 	error_message
#   end

CONFIG = Config.load
Kemal.config.port = CONFIG.port

Utils.create_files_directory

get "/" do |env|
  render "src/views/index.ecr"
end

# TODO: Error checking later
post "/upload" do |env|
  Handling.upload(env)
end

get "/:filename" do |env|
  Handling.retrieve_file(env)
end

get "/stats" do |env|
  Handling.stats(env)
end

# TODO: HANDLE FILE DELETION WITH COOKIES

#   spawn do
#     loop do
#       begin
#         Utils.check_old_files
#       rescue ex
#         puts "#{"[ERROR]".colorize(:red)} xd"
#       end
#       sleep 10
#     end
#   end
# Fiber.yield

CHECK_OLD_FILES = Fiber.new do
  loop do
    Utils.check_old_files
    sleep 1
  end
end

CHECK_OLD_FILES.enqueue
# https://kemalcr.com/cookbook/unix_domain_socket/
# Kemal.run do |config|
#   if CONFIG.unix_socket != nil
#     config.server.not_nil!.bind_unix(Socket::UNIXAddress.new(CONFIG.unix_socket))
#   else
#     config.server.port = CONFIG.port
#   end
# end
Kemal.run

# Fiber.yield
