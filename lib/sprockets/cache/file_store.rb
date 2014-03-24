require 'digest/md5'
require 'fileutils'
require 'pathname'
require 'active_support/core_ext'

module Sprockets
  module Cache
    # A simple file system cache store.
    #
    #     environment.cache = Sprockets::Cache::FileStore.new("/tmp")
    #
    class FileStore
      def initialize(root)
        @root = Pathname.new(root)
      end

      # Lookup value in cache
      def [](key)
        pathname = @root.join(key)
        if pathname.exist?
          lock_file(pathname) { pathname.open('rb') { |f| Marshal.load(f) } }
        else
          nil
        end
      rescue => e
        nil
      end

      # Save value to cache
      def []=(key, value)
        # Ensure directory exists
        FileUtils.mkdir_p @root.join(key).dirname

        lock_file(@root.join(key).to_s) do
          File.atomic_write(@root.join(key).to_s) do |file|
            file.write(Marshal.dump(value, file))
          end
        end

        value
      end

      def lock_file(file_name, &block) # :nodoc:
        if File.exist?(file_name)
          File.open(file_name, 'r+') do |f|
            begin
              f.flock File::LOCK_EX
              yield
            ensure
              f.flock File::LOCK_UN
            end
          end
        else
          yield
        end
      end
    end
  end
end
