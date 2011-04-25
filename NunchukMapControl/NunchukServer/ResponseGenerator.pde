import com.sun.net.httpserver.HttpExchange;

// Interface for generating responses to HTTP requests.  Used
// by RequestHandler for response generation.
interface ResponseGenerator {
  public String generateResponse(HttpExchange ex);
}

