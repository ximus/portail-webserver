require 'rbtrace'
require 'ruby-prof'

# require 'socket'
# $debug_socket = UNIXSocket.new(App.paths.tmp.join('devsocket').to_s)
# $debug_socket.puts(Process.pid)
# $debug_socket.close

def Kernel.prof(&block)
  results = RubyProf.profile(&block)
  RubyProf::GraphHtmlPrinter.new(results).print(App.paths.tmp.join('ruby-prof'))
end

trap 'TTIN' do
  Thread.list.each do |thread|
    puts "Thread TID-#{thread.object_id.to_s(36)}"
    puts thread.backtrace.join("n")
  end
end


#####################
#
# Pry related
#
#####################
#
if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

# Hit Enter to repeat last command
Pry::Commands.command /^$/, "repeat last command" do
  _pry_.run_command Pry.history.to_a.last
end
