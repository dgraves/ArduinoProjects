// Sends an email notification to the specified email address
// when mail is detected by the MailboxMonitor.
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.net.Socket;

class SmtpNotification {
  public SmtpNotification(String servername, int serverport) {
    this.servername = servername;
    this.serverport = serverport;
  }
  
  public void send(String from, String to, String subject, String message) {
    println("Sending email notification");
    try {
      Socket client = new Socket(servername, serverport);
      BufferedReader in = new BufferedReader(new InputStreamReader(client.getInputStream()));
      PrintWriter out = new PrintWriter(client.getOutputStream());

      // Read server banner
      println("Server says: " + in.readLine());

      sendLine(out, in, "helo");
      sendLine(out, in, "mail from: <" + from + ">");
      sendLine(out, in, "rcpt to: <" + to + ">");
      sendLine(out, in, "data");
      sendLine(out, in, "from: " + from);
      sendLine(out, in, "to: " + to);
      sendLine(out, in, "subject: " + subject);
      sendLine(out, in, "");
      sendLine(out, in, message);
      sendLine(out, in, ".");
      sendLine(out, in, "quit");
      
      in.close();
      out.close();
      client.close();

      println("Message sent");
    } catch(Exception e) {
      println("Error sending email notification: " + e.getMessage());
    }
  }

  private void sendLine(PrintWriter out, BufferedReader in, String message) throws IOException {
    println("Sending " + message + "...");
    out.print(message + "\r\n");
    out.flush();
    println("Server says: " + in.readLine());
  }

  private String servername;

  private int serverport;
}


