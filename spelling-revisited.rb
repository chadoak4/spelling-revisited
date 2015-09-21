require 'rubygems'
require 'webrick'
require 'erb'

class Displaydictionary < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)

    if File.exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end

    response.status = 200
    response.body = %{
      <html>
      <head>
      <style>
      body {
        background-color: blue;}
        h1 {
          color: white;
          text-align: center;
          font-size: 50px;}
          </style>
          </head>
          <body>
          <header>
          <h1>Welcome to Iron Dictionary<h1>
          <h2><a href="/add">Add Words to Our Growing Dictionary!</a><h2>
          </header>
          <form method="POST" action="/search">
            <ul>
              <li>Search : <input name="input_search"/></li>
            </ul>
            <button type="submit">Submit!</button>
          </form>
           #{dictionary.join("<br/>")}
          </body>
          </html>
        }


      end
    end

class Add < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    response.status = 200
    response.header["Location"] = "/save"
    response.body = %{
      <html>
        <head>
          <style>
            body {
            background-color: blue;}
            h1 {
            color: white;
            text-align: center;
            font-size: 50px;}
          </style>
        </head>
        <body>
          <header>
            <h1>Add to the Iron Dictionary<h1>
          </header>
            <form method="POST" action="/save">
              <ul>
                <li>What is the word you would like to add to the dictionary? <input name="word"/></li>
                <li>What is the definition of the word? <input name="definition"/</li>
              </ul>
              <button type="submit">Submit!</button>
            </form>
            </body>
          </html>}
  end
end

class Save < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)

    if File exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end

    word = request.query["word"]
    definition = request.query["definition"]

    added_word = {word: word, definition: definition}
    dictionary << added_word

      File.write("data.yml", dictionary.to_yaml)


  response.status = 302
  response.header["Location"] = "/"
  response.body = ""
  end
end

class Search < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)

    if File exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end

    match = dictionary.select {|hash| hash[:word] == request.query("input_search")

    html_match = "<ul>" + (match.map {|hash| "<li> #{hash[:2word]}</li>"}).join + "</ul>"


  response.status = 200
  response.body = %{
      <html>
          <head>
            <style>
              body {
              background-color: blue;}
              h1 {
              color: white;
              text-align: center;
              font-size: 50px;}
            </style>
          </head>
          <body>
            <header>
              <h1>Search Results<h1>
            </header>
            <h2><a href="/">Back to Dictionary!</a><h2>
            <p>
            #{html_match}
            </p>
              </body>
            </html>
          }
  end
end


    server = WEBrick::HTTPServer.new(:Port=>3000)
    server.mount "/", Displaydictionary
    server.mount "/add", Add
    server.mount "/save", Save
    server.mount "/search", Search


    trap("INT") {
      server.shutdown
    }

    server.start
