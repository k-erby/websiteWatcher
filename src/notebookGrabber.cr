require "http/client"
require "process"
require "kernel"
require "myhtml"
require "file"

class NotebookGrabber

  def initialize(url : String)
    @url  = url
    @body = ""
    @list = [] of String
  end

  def process
    @body = get_body
    @list = get_list

    determine_notebook_format_and_convert
    puts "\nNotebook has been created."
  end

  def get_body
    response = HTTP::Client.exec "GET", @url
    response.body
  end

  def get_body(url)
    response = HTTP::Client.exec "GET", url
    response.body
  end

  def get_list
    html = Myhtml::Parser.new(@body)
    return html.css(%q{a[href$=".html"]}).map(&.inner_text).to_a
  end

  # check if prof posted a pdf or an html page
  def determine_notebook_format_and_convert
    new_url = @url + @list.last
    body = get_body(new_url)

    html = Myhtml::Parser.new(body)
    pdf_list = html.css(%q{a[href$=".pdf"]}).map(&.attributes["href"]).to_a

    if pdf_list.last?
      puts "PDF found, generating PDF-to-file."
      pdf_to_file(pdf_list[0])
    else
      puts "PDF not found, generating html-to-file."
      html_to_file(@url, @list.last)
    end
  end

  # grab the pdf notebook via subprocess call, because it's annoying otherwise.
  def pdf_to_file(pdf)
    url_to_pdf   = @url + pdf
    get_pdf_args = ["-r", "-A", "pdf", "-nd", "-e", "robots=off",
      "-P", "./notebooks/", url_to_pdf]

    begin
      Process.run("wget", args: get_pdf_args)
    rescue ex
      puts ex.message
    end
  end

  # converts the html page into a .txt for the notebook/, based on her pattern.
  def html_to_file(url, notebook)
    html_body   = get_body(url + notebook)
    parsed_html = Myhtml::Parser.new(html_body)

    notebook_entry = parsed_html.css(%q{p[class$="Body"]}).map(&.inner_text).to_a
    create_file(notebook_entry, notebook)
  end

  def create_file(notebook_entry, notebook)
    notebook_path = "notebooks/" + notebook.chomp(".html") + ".txt"
    notebook_entry.each do |line|
      File.write(notebook_path, "\n" + line, mode: "a")
    end
  end

  def print
    puts "\nThis is the url: \n"  + @url
    puts "\nThis is the body: \n" + @body
    puts "\nThis is the list: \n" + @list.to_s
  end
end
