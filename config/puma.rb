max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Configuration for different environments
if ENV["RAILS_ENV"] == "production"
  # Production: Render will override with -p $PORT anyway
  port ENV.fetch("PORT") { 3000 }
  bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"
else
  # Development: simple localhost configuration
  port ENV.fetch("PORT") { 3000 }
  # Don't bind to 0.0.0.0 in development to avoid DNS issues
end

environment ENV.fetch("RAILS_ENV") { "development" }

plugin :tmp_restart

# Disable solid_queue plugin for production
# plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
