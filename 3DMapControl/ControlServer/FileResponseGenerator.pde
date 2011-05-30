import java.io.FileReader;

// Loads the specified file from the local system into a string to
// be returned as an HTTP response.
class FileResponseGenerator implements ResponseGenerator {
  private final int BLOCK_SIZE = 4096;
  private String _fileDir;

  public FileResponseGenerator(String fileDir) {
    _fileDir = fileDir;
  }

  public String generateResponse(HttpExchange ex) {
    FileReader reader;
    try {
      reader = new FileReader(_fileDir + ex.getRequestURI().getPath());
    } catch(FileNotFoundException e) {
      return null;
    }

    try {
      char[] buffer = new char[BLOCK_SIZE];
      StringBuffer response = new StringBuffer();

      for (;;) {
        int read = reader.read(buffer);

        if (read > 0) {
          response.append(buffer, 0, read);
        } else {
          break;
        }
      }

      return response.toString();
    } catch(IOException e) {
      return null;
    }
  }
}

