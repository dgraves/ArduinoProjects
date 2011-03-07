class FadingCircle extends FadingObject {
  public FadingCircle(int centerX, int centerY, int diameter, int hexColor) {
    this.centerX = centerX;
    this.centerY = centerY;
    this.diameter = diameter;
    this.hexColor = hexColor;
  }

  public void draw() {
    update();

    noStroke();
    fill(hexColor, 255 * currentFade());
    ellipse(centerX, centerY, diameter, diameter);
  }

  private int centerX;
  private int centerY;
  private int diameter;
  private int hexColor;
}

