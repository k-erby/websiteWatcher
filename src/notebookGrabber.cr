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
    determine_notebook_format
  end

  def get_body
    response = HTTP::Client.exec "GET", @url
    return response.body
  end

  def get_body(url)
    response = HTTP::Client.exec "GET", url
    return response.body
  end

  def get_list
    html = Myhtml::Parser.new(@body)
    return html.css(%q{a[href$=".html"]}).map(&.inner_text).to_a
  end

  # check if prof posted a pdf or an html page
  def determine_notebook_format
    new_url = @url + @list.last
    body = get_body(new_url)

    html = Myhtml::Parser.new(body)
    pdf_list = html.css(%q{a[href$=".pdf"]}).map(&.attributes["href"]).to_a

    if pdf_list.last?
      puts "PDF found, generating PDF-to-file."
      pdf_to_file(pdf_list[0])
    else
      puts "PDF not found, generating html-to-file."
      html_to_file(body)
    end
  end

  # Grab the pdf notebook via subprocess call, because it's annoying otherwise.
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

  # add a latest notebook
  def html_to_file(body)
    # TODO
  end

  def print
    puts "\nThis is the url: \n"  + @url
    puts "\nThis is the body: \n" + @body
    puts "\nThis is the list: \n" + @list.to_s
  end
end
