require "http/client"
require "myhtml"
require "file"

require "../notebookGrabber"


BASE_URL      = "https://people.finearts.uvic.ca/~ddudley/AHVS_300A_Masterpieces_Summer_2019/"
WELCOME_URL   = BASE_URL + "Welcome.html"
MATERIALS_URL = BASE_URL + "Materials/Materials.html"
NOTEBOOK_URL  = BASE_URL + "Materials/Entries/2019/5/"

materials_response = HTTP::Client.exec "GET", MATERIALS_URL
materials_body     = materials_response.body
materials_header   = materials_response.headers
materials_modified = materials_header["Last-Modified"]

# Use 'last-modified' file to check references.
begin
  current_last_modified = File.read("last-modified")

  if current_last_modified != materials_modified
    puts "\nWebsite has been modified since you ran this. Visit the site now: \n#{MATERIALS_URL}"
    File.write("last-modified", materials_modified)

    notebook = NotebookGrabber.new NOTEBOOK_URL
    notebook.process
  else
    puts "\nNah, it's chill."
  end
rescue ex
  puts ex.message
end
