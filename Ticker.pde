import java.math.BigDecimal;
import java.text.DecimalFormat;
import http.requests.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.time.LocalDateTime;
import java.time.ZoneId;

class Ticker {
  private int streak = 0;
  private boolean streakIncreased = false;

  private BigDecimal total = BigDecimal.ZERO;

  private DecimalFormat df = new DecimalFormat();

  private long lastTotalTimestamp = 0;

  Ticker() {
    this.df.setMaximumFractionDigits(2);
    this.df.setMinimumFractionDigits(2);
  }

  void getTotal() {
    long now = Instant.ofEpochSecond(0L).until(Instant.now(), ChronoUnit.SECONDS);

    if (lastTotalTimestamp == 0 || (now - lastTotalTimestamp) > refreshInterval) {
      GetRequest request = new GetRequest("https://api.paytree-network.nl/v1/status/total");
      request.addHeader("Authorization", apiKey);
      request.send();

      String result = request.getContent();

      BigDecimal newTotal = new BigDecimal(result);
      if (newTotal.compareTo(this.total) > 0) {
        if (!this.streakIncreased) {
          this.streak += 1;
        }

        this.streakIncreased = true;
      } else {
        if (this.streakIncreased) {
          this.streak = 0;
        }

        this.streakIncreased = false;
      }

      this.total = newTotal;
      this.lastTotalTimestamp = now;
    }
  }

  void drawTicker() {
    getTotal();

    fill(255);

    textAlign(LEFT, BOTTOM);
    textSize(primaryTextSize);

    text("€", 10, height);
    text(this.df.format(this.total), 80, height);

    textAlign(RIGHT, BOTTOM);

    if (streak > 0) {
      float val = map(streak, 0, 500, 190, 0);
      fill(val, 255, 0);
    }

    if (this.streakIncreased) {
      text("^", width - 50, height);
    } else {
      text("-", width - 50, height);
    }
  }
}
