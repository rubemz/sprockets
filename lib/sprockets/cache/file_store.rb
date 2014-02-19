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
        pathname.exist? ? pathname.open('rb') { |f| Marshal.load(f) } : nil
      end

      # Save value to cache
      def []=(key, value)
        # Ensure directory exists
        FileUtils.mkdir_p @root.join(key).dirname

        File.atomic_write(@root.join(key).to_s) do |file|
          file.write(Marshal.dump(value, file))
        end

        value
      end
    end
  end
end
