module Utils
  extend self

  def create_files_directory
    if !Dir.exists?("#{CONFIG.files}")
      begin
        Dir.mkdir("#{CONFIG.files}")
      rescue ex
        puts ex.message
        exit
      end
    end
  end

  def check_old_files
    puts "INFO: Deleting old files"
    dir = Dir.new("#{CONFIG.files}")
    dir.each_child do |file|
      if (Time.utc - File.info("#{CONFIG.files}/#{file}").modification_time).days >= CONFIG.delete_files_after
        puts "INFO: Deleting file '#{file}'"
        begin
          File.delete("#{CONFIG.files}/#{file}")
        rescue ex
          puts "ERROR: #{ex.message}"
        end
      end
    end
    # Close directory to prevent `Too many open files (File::Error)` error.
    # This is because the directory class is still saved on memory for some reason.
    dir.close
  end
end
