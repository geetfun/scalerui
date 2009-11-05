dir = File.dirname(__FILE__)

require 'optparse'
require 'fileutils'

class Scalerui
  def initialize(args)
    
    @args = args
    
    # Default Options
    @options = {
      :install => false,
      :upgrade => false,
      :version => "latest",
      :assets => nil
    }
    
    # Option Parser
    optparse = OptionParser.new do |opts|
      opts.banner = <<-EOF

Scaler UI Framework
(c) Copyright 2009 Simon Chiu, Scaler Apps    http://ui.scalerapps.com
---------------------------------------------------------------------------------------------------------

Usage: scalerui [options] [framework directory]

Description:
  Enables you to easily install, remove, or upgrade Scaler UI for Rails

Options:

      EOF
      
      opts.on_tail('--help', "Displays this screen") do
        puts opts
        exit
      end
      
      opts.on('--install', "Installs the UI") do
        @options[:install] = true
      end
      
      opts.on('--remove', "Removes the UI") do
        @options[:install] = false
      end
      
      opts.on('--version n', "Installs a specific UI version") do |version|
        @options[:version] = version
      end
      
      opts.on('--dir INSTALL-DIRECTORY', "Rails directoryw here you want to install UI") do |dir|
        @options[:install_dir] = dir
      end
      
      opts.on('--assets ASSETS-LOCATION', "URL of where your assets are hosted, eg. CDN") do |url|
        @options[:assets] = url
      end
      
      opts.parse!(@args)
      process
    end
    
  end
    
  protected
  
  def process
    raise NoTargetDirectoryError if @options[:install_dir].nil?
    
    install       = @options[:install]
    install_dir   = @options[:install_dir]    
    assets_dir    = @options[:assets] || File.join(install_dir, "public")
    scalerui_dir  = File.join(assets_dir, "scalerui")
    images_dir    = File.join(scalerui_dir, "images")
    js_dir        = File.join(scalerui_dir, "javascript")
    css_dir       = File.join(scalerui_dir, "css")
    
    if install      
      # Creates the appropriate directory for the framework files
      begin
        # Checks to see whether an existing scalerui is installed
        if File.exist?(scalerui_dir)
          print "Existing Scaler UI detected. Installer will delete all files in existing Scaler UI directory. Do you want to continue? (y/n): "
          response = gets.chomp        
          if response == 'n'
            puts "Aborted"
            return
          else
            print "Removing existing directory: #{scalerui_dir}..."
            FileUtils.rm_rf(scalerui_dir)
            puts "done"
          end
        end
        print "Creating directory structure: #{scalerui_dir}..."
        FileUtils.mkdir_p scalerui_dir
        FileUtils.mkdir_p images_dir
        FileUtils.mkdir_p js_dir
        FileUtils.mkdir_p css_dir
        puts "done"        
      rescue Exception => e
        puts "An error has occurred while creating the directories"
        FileUtils.rm_r(scalerui_dir)
        exit
      end
      
      # Copies the files
      
    else
      FileUtils.rm_r(scalerui_dir)
    end
    
  end
    
end

# Error Classes
class ScaleruiError < StandardError; end;
class NoTargetDirectoryError < ScaleruiError; end;