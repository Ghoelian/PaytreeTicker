import java.math.BigDecimal;
import java.text.DecimalFormat;
import http.requests.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.time.LocalDateTime;
import java.time.ZoneId;

int tickerOffsetY = 120;

static byte day = 0000;
static byte week = 0001;
static byte month = 0010;
static byte year = 0100;

class Ticker {
  private byte state = day;
  private int textOffset = 25;

  private int streak = 0;
  private int maxStreak = 0;

  private boolean streakIncreased = false;

  private int total = 0;

  private String error;

  Ticker() {
    try {
      byte b[] = loadBytes("streak");

      if (b == null) return;

      String streakVals = new String(b);
      String parts[] = streakVals.split(";");

      this.streak = parseInt(parts[0].split(":")[1]);
      this.maxStreak = parseInt(parts[1].split(":")[1]);
    }
    catch (Exception e) {
    }
  }

  void getTotal() {
    GetRequest request = new GetRequest("https://api.paytree.nl/v1/status/total");
    request.addHeader("Authorization", apiKey);
    request.send();

    String result = request.getContent();

    try {
      int newTotal = Integer.parseInt(result);

      if (newTotal > total) {
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
  }

  void drawTicker() {
    state += 0001;

    if (state >= 1000) state = 0000;

    getTotal();

    fill(255);

    textAlign(LEFT, TOP);
    textSize(primaryTextSize);

    if (error != null) {
      text(error, legendOffset, (height - tickerOffsetY) + textOffset);
    } else {
      textAlign(LEFT);
      textSize(20);
      translate(legendOffset - 15, (height - tickerOffsetY) + textOffset + 10);

      rotate(PI*1.5);

      fill(disabledTextColor);

      if (state == day) fill(primaryTextColor);
      text("D", 0, 0);
      fill(disabledTextColor);

      if (state == week) fill(primaryTextColor);
      text("W", -20, 0);
      fill(disabledTextColor);

      if (state == month) fill(primaryTextColor);
      text("M", -40, 0);
      fill(disabledTextColor);

      if (state == year) fill(primaryTextColor);
      text("Y", -60, 0);

      fill(primaryTextColor);

      textAlign(LEFT, TOP);
      textSize(primaryTextSize);
      rotate(HALF_PI);
      translate(-(legendOffset - 5), -((height - tickerOffsetY) + textOffset + 10));
      text(String.format("%,d", total) + "×", legendOffset, (height - tickerOffsetY) + textOffset);
    }

    if (streak > 0) {
      float val = map(streak, 0, maxStreak, 0, 120);
      fill(val, 94.6, 94.9);
    }

    if (streakIncreased) {
      text("^", width - 80, (height - tickerOffsetY + 10) + textOffset);
    } else {
      text("-", width - 80, (height - tickerOffsetY) + textOffset);
    }
  }
}
