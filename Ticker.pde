import java.math.BigDecimal;
import java.text.DecimalFormat;
import http.requests.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.time.LocalDateTime;
import java.time.ZoneId;

class Ticker {
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

      this.total = new BigDecimal(result);
      this.lastTotalTimestamp = now;
    }
  }

  void drawTicker() {
    getTotal();

    fill(255);

    textAlign(LEFT, BOTTOM);
    textSize(primaryTextSize);

    text("€", 0, height);
    text(this.df.format(this.total), 60, height);
  }
}
