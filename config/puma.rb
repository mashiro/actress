require 'pathname'
root_dir = Pathname.new File.expand_path('../../', __FILE__)

environment 'production'
daemonize true
stdout_redirect root_dir.join('log/out.log'), root_dir.join('log/err.log')
bind "unix://#{root_dir.join('tmp/actress.sock')}"
pidfile root_dir.join('tmp/actress.pid')

