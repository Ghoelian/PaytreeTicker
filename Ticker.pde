import java.math.BigDecimal;
import java.text.DecimalFormat;
import http.requests.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.time.LocalDateTime;
import java.time.ZoneId;

class Ticker {
  private int streak = 0;
  private int maxStreak = 0;

  private boolean streakIncreased = false;

  private BigDecimal total = BigDecimal.ZERO;

  private DecimalFormat df = new DecimalFormat();

  private long lastTotalTimestamp = 0;

  private String error;

  Ticker() {
    df.setMaximumFractionDigits(2);
    df.setMinimumFractionDigits(2);

    byte b[] = loadBytes("streak");

    if (b == null) return;

    String streakVals = new String(b);
    String parts[] = streakVals.split(";");

    this.streak = parseInt(parts[0].split(":")[1]);
    this.maxStreak = parseInt(parts[1].split(":")[1]);
  }

  void getTotal() {
    long now = Instant.ofEpochSecond(0L).until(Instant.now(), ChronoUnit.SECONDS);

    if (lastTotalTimestamp == 0 || (now - lastTotalTimestamp) > refreshInterval) {
      GetRequest request = new GetRequest("https://api.paytree.nl/v1/status/total");
      request.addHeader("Authorization", apiKey);
      request.send();

      String result = request.getContent();

      try {
        BigDecimal newTotal = new BigDecimal(result);

        if (newTotal.compareTo(total) > 0) {
          streak += 1;

          if (streak > maxStreak) {
            maxStreak = streak;
          }

          saveBytes("streak", ("streak:" + streak + ";max:" + maxStreak).getBytes());

          if (!streakIncreased) {
            streakIncreased = true;
          }
        } else {
          if (streakIncreased) {
            streak = 0;
            streakIncreased = false;

            saveBytes("streak", ("streak:" + streak + ";max:" + maxStreak + ";").getBytes());
          }
        }

        total = newTotal;
        error = null;
      }
      catch (Exception e) {
        System.out.println("Error while gettig ticker total:");
        e.printStackTrace();

        error = e.toString();
      }

      lastTotalTimestamp = now;
    }
  }

  void drawTicker() {
    getTotal();

    fill(255);

    textAlign(LEFT, BOTTOM);
    textSize(primaryTextSize);

    if (error != null) {
      text(error, 80, height);
    } else {
      text("€", 10, height);
      text(df.format(total), 80, height);
    }

    textAlign(RIGHT, BOTTOM);

    if (streak > 0) {
      float val = map(streak, 0, maxStreak, 0, 120);
      fill(val, 94.6, 94.9);
    }

    if (streakIncreased) {
      text("^", width - 25, height);
    } else {
      text("-", width - 25, height);
    }
  }
}
