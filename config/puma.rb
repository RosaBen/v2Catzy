max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

if ENV["PORT"]
  port ENV["PORT"]
else
  port 3000
end

bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

environment ENV.fetch("RAILS_ENV") { "development" }

plugin :tmp_restart

# Disable solid_queue plugin for production
# plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
