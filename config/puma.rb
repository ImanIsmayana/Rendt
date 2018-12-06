#!/usr/bin/env puma

app_dir = File.expand_path('../../', __FILE__)

workers 3

threads 0, 16

port 3000

environment 'development'

preload_app!

on_worker_boot do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
