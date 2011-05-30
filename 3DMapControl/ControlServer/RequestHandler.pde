import com.sun.net.httpserver.HttpHandler;

// Class to process HTTP requests received by ControlServer.  Only
// GET requests are processed.
class RequestHandler implements HttpHandler {
  private ResponseGenerator _generator;

  public RequestHandler(ResponseGenerator generator) {
    _generator = generator;
  }

  public void handle(HttpExchange ex) throws IOException {
    int responseCode = 200;
    String response = null;
        
    if (ex.getRequestMethod().equals("GET")) {
    response = _generator.generateResponse(ex);
      if (response == null) {
        responseCode = 404;
        response = "File not found.";
      }
    } else {
      responseCode = 500;
      response = "Server could not process " + ex.getRequestMethod() + " request.";
    }

    ex.sendResponseHeaders(responseCode, response.length());
    OutputStream os = ex.getResponseBody();
    os.write(response.getBytes());
    os.close();
  }
}

