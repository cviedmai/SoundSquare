# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_SoundSquare_session',
  :secret      => '09ef6db2898fc8a8732c8fa85703e9189b29b4f51e09258bddafc22d1be059308ba8039e2e742979924819f1ff158d0d2975c2993e877e1e5db3c343f9576b87'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
