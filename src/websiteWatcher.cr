require "http/client"
require "digest/sha1"
require "myhtml"
require "file"

require "../notebookGrabber"

BASE_URL      = "https://people.finearts.uvic.ca/~ddudley/AHVS_300A_Masterpieces_Summer_2019/"
WELCOME_URL   = BASE_URL + "Welcome.html"
MATERIALS_URL = BASE_URL + "Materials/Materials.html"
NOTEBOOK_URL  = BASE_URL + "Materials/Entries/2019/5/"

materials_response = HTTP::Client.exec "GET", MATERIALS_URL
materials_body     = materials_response.body
materials_hash     = Digest::SHA1.digest(materials_body)

# Use 'SHA1' hash to compare website states
begin
  currently_stored_hash = File.read("current-hash")

  if currently_stored_hash.to_s != materials_hash.to_s
    puts "\nWebsite has been modified since you ran this. Visit the site now: \n#{MATERIALS_URL}"
    File.write("current-hash", materials_hash)

    notebook = NotebookGrabber.new NOTEBOOK_URL
    notebook.process
  else
    puts "\nNah, it's chill."
  end
rescue ex
  puts ex.message
end
