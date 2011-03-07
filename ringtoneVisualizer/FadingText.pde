class FadingText extends FadingObject {
  public FadingText(int centerX, int centerY, int fontSize, int hexColor) {
    this.centerX = centerX;
    this.centerY = centerY;
    this.fontSize = fontSize;
    this.hexColor = hexColor;
    this.message = "";
    this.align = CENTER;
    this.alignY = CENTER;
  }

  public String message() { return message; }

  public void setMessage(String message) { this.message = message; }

  public void setAlignment(int align, int alignY) {
    this.align = align;
    this.alignY = alignY;
  }

  public void draw() {
    update();

    textAlign(align, alignY);
    textSize(fontSize);
    fill(hexColor, 255 * currentFade());
    // Add diameter/10 to Y to make things look a little more centered
    text(message, centerX, centerY - fontSize/10);
  }

  private int align;
  private int alignY;
  private int centerX;
  private int centerY;
  private int fontSize;
  private int hexColor;
  private String message;
}

