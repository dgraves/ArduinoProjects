abstract class FadingObject {
  public final int DEFAULT_FADE_DURATION = 500;

  public int fadeDuration() { return fadeDuration; }

  public void setFadeDuration(int fadeDuration) { this.fadeDuration = fadeDuration; }

  public float fadedValue() { return fadedValue; }

  public void setFadedValue(float fadedValue) { this.fadedValue = fadedValue; }

  public void on(int duration) {
    this.duration = duration;
    currentFade = 1.0;
    on = true;
    start = millis();
  }

  public abstract void draw();

  protected void update() {
    if (on) {
      if (duration < (millis() - start)) {
        on = false;
        fading = true;
        duration = fadeDuration;
        start = millis();
      }
    } else if (fading) {
      int ellapsed = millis() - start;
      currentFade = 1.0 - ((float)ellapsed / (float)duration) * (1.0 - fadedValue);
      if (currentFade <= fadedValue) {
        fading = false;
        currentFade = fadedValue;
      }
    }
  }

  protected float currentFade() { return currentFade; }

  private float currentFade = 0.1;
  private float fadedValue = 0.1;
  private int fadeDuration = DEFAULT_FADE_DURATION;
  private int start = 0;
  private int duration = 0;
  private boolean on = false;
  private boolean fading = false;
}

