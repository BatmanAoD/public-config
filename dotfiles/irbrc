puts '-> irbrc'

require 'rubygems'  # for 1.8

begin
    require 'wirble'

    # XXX doesn't work....???
    # wirble_opts = {
    #     # override some of the default colors (because blue on black
    #     # is essentially unreadable, and yellow symbols are hideous)
    #       :colors => {
    #         :comma              => :light_blue,
    #         :refers             => :light_blue,
    #         :object_addr_prefix => :light_blue,
    #         :object_line_prefix => :light_blue,
    #         :symbol             => :light_cyan,
    #         :symbol_prefix      => :light_cyan,
    #       },
    # 
    #       # enable color
    #       :init_color     => true,
    # }

    # Wirble.init(wirble_opts)
    
    wirble_colors = Wirble::Colorize.colors.merge({
        :comma              => :light_blue,
        :refers             => :light_blue,
        :object_addr_prefix => :light_blue,
        :object_line_prefix => :light_blue,
        :symbol             => :light_cyan,
        :symbol_prefix      => :light_cyan,
    })
    Wirble.init
    Wirble::Colorize.colors = wirble_colors
    Wirble.colorize


    rescue LoadError => err
    $stderr.puts "Couldn't load Wirble: #{err}"
end

alias q exit

# Easily print methods local to an object's class
# from http://robots.thoughtbot.com/irb-script-console-tips
# ....use Wirble's 'po' function instead
# class Object
#   def local_methods
#     (methods - Object.instance_methods).sort
#   end
# end

# from http://stackoverflow.com/a/123847/1858225
# Note: names MUST be uppercase...? So... the .irbrc shouldn't define locals?
# Alt: use https://gist.github.com/lucapette/807492
HASH = { 
  :bob => 'Marley', :mom => 'Barley', 
  :gods => 'Harley', :chris => 'Farley'} unless defined?(HASH)
ARRAY = HASH.keys unless defined?(ARRAY)

puts '<- irbrc'
