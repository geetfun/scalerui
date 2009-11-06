dir = File.dirname(__FILE__)

require 'optparse'
require 'fileutils'
require 'shell'
require 'tmpdir'

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
      
      # Sets some instance variables
      @install       = @options[:install]
      @install_dir   = @options[:install_dir]
      
      raise NoTargetDirectoryError if @install_dir.nil?
      @assets_dir    = @options[:assets] || File.join(@install_dir, "public")

      @scalerui_dir  = File.join(@assets_dir, "scalerui")
      @images_dir    = File.join(@scalerui_dir, "images")
      @js_dir        = File.join(@scalerui_dir, "javascript")
      @css_dir       = File.join(@scalerui_dir, "css")
      @src_dir       = File.join(File.dirname(__FILE__) + "/../src")
      
      process
    end
    
  end
    
  protected
  
  def process
    if @install
      # -- Begin of Installation
      
      # Creates the appropriate directory for the framework files ------------------------------
      begin
        # Checks to see whether an existing scalerui is installed
        if File.exist?(@scalerui_dir)
          print "Existing Scaler UI detected. Installer will delete all files in existing Scaler UI directory. Do you want to continue? (y/n): "
          response = gets.chomp        
          if response == 'n'
            puts "Aborted"
            return
          else
            cleanup
          end
        end
        print "Creating directory structure: #{@scalerui_dir}..."
        FileUtils.mkdir_p @scalerui_dir
        FileUtils.mkdir_p @images_dir
        FileUtils.mkdir_p @js_dir
        FileUtils.mkdir_p @css_dir
        puts "done"
      rescue Exception => e
        puts "An error has occurred while creating the directories"
        cleanup
        return
      end
      
      # Copies the files ------------------------------------------------------------------------
      begin
        all_source_files    = Dir[File.join(@src_dir, "/*")]
        version = @options[:version]
        case version
        when "latest"
          @file_source = all_source_files.sort.last
        else
          @file_source = File.join(@src_dir, "/scalerui-#{version}.tar.gz")
        end
        
        # Check to see if file exists
        raise NoSourceFileError unless File.exist?(@file_source)
        
        # Untar and copies files over
        copy_files
        
      rescue NoSourceFileError => e
        puts "Source file is missing. Please install the gem again."
        cleanup
        return
      end

      puts "Scaler UI Framework has been installed into this Rails app: #{@install_dir}"
      puts ""
      puts "Put the following lines into your template headers: "
      puts '
<link href="/scalerui/css/reset.css" rel="stylesheet" type="text/css">		
<link href="/scalerui/css/base.css" rel="stylesheet" type="text/css">
<link href="/scalerui/css/layout.css" rel="stylesheet" type="text/css">
<link href="/scalerui/css/components.css" rel="stylesheet" type="text/css">

<script src="http://www.google.com/jsapi"></script> 
<script type="text/javascript">
    // Load jQuery
    google.load("jquery", "1.3.2");
    google.load("jqueryui", "1.7.2");
</script>
<script type="text/javascript" src="javascript/scalerapps/ui-0.1.js"></script>
<!--[if IE 6]>
	<link href="css/ie6.css" rel="stylesheet" type="text/css">	

	<script type="text/javascript" src="javascript/ie6/DD_belatedPNG_0.0.8a.js"></script>
	<script type="text/javascript">
		DD_belatedPNG.fix("span.icon, span.big-icon, img");
	</script>			
<![endif]--> 

<!--[if IE]>
	<link href="css/ie.css" rel="stylesheet" type="text/css">
<![endif]-->
      '
      
      # -- End of Installation
    else
      # -- Begin of Removal
      cleanup
      # -- End of Removal
    end
    
  end
  
  def copy_files
    decompress_source
    copy_css
    copy_images
    copy_js
    clean_source
  end
  
  def decompress_source
    @tmpdir = Dir.mktmpdir
    Shell.def_system_command "decompress", "tar xzf #{@file_source} -C #{@tmpdir}"
    sh = Shell.new
    
    print "Decompressing framework source files..."
    sh.transact do
      decompress
    end
    puts "done"
  end
  
  def clean_source
    FileUtils.remove_dir(@tmpdir, true)
  end
  
  def copy_css
    print "Copying CSS files..."
    css_dir = File.join(@tmpdir, "css")
    Dir.chdir(css_dir)
    FileUtils.mv Dir.glob("*"), @css_dir
    puts "done"
  end
  
  def copy_images
    print "Copying images"
    images_dir = File.join(@tmpdir, "images")
    Dir.chdir(images_dir)
    FileUtils.mv Dir.glob("*"), @images_dir
    puts "done"
  end
  
  def copy_js
    print "Copying Javascript files..."
    js_dir = File.join(@tmpdir, "javascript")
    Dir.chdir(js_dir)
    FileUtils.mv Dir.glob("*"), @js_dir
    puts "done"
  end
  
  # Cleans up after messy installations, uninstallation, etc...
  def cleanup
    if File.exist?(@scalerui_dir)
      print "Cleaning up directories..."
      FileUtils.rm_r(@scalerui_dir)
      puts "done"
    else
      puts "Nothing to clean up!"
    end
  end
    
end

# Error Classes
class ScaleruiError < StandardError; end;
class NoTargetDirectoryError < ScaleruiError; end;
class NoSourceFileError < ScaleruiError; end;