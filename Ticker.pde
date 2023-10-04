import java.math.BigDecimal;
import java.text.DecimalFormat;
import http.requests.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.time.LocalDateTime;
import java.time.ZoneId;
import com.google.gson.Gson;

int tickerOffsetY = 120;

public enum State {
  DAY("day"), WEEK("week"), MONTH("month"), YEAR("year");

  private State(String state) {
    this.state = state;
  }

  private String state;

  public String getState() {
    return this.state;
  }

  public String toString() {
    return this.state;
  }

  public State increment(State state) {
    switch (state) {
    case DAY:
      return State.WEEK;
    case WEEK:
      return State.MONTH;
    case MONTH:
      return State.YEAR;
    case YEAR:
      return State.DAY;
    default:
      return State.DAY;
    }
  }
}

class Totals {
  private int day;
  private int week;
  private int month;
  private int year;

  Totals() {
  }
}

class Ticker {
  private Gson gson = new Gson();

  private long lastTimestamp = 0;

  private State state = State.DAY;
  private int textOffset = 25;

  private int streak = 0;
  private int maxStreak = 0;

  private boolean streakIncreased = false;

  private Totals totals;

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
      Totals newTotals = gson.fromJson(result, Totals.class);

      if (totals == null || newTotals.day > totals.day) {
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

      totals = newTotals;
      error = null;
    }
    catch (Exception e) {
      System.out.println("Error while gettig ticker total:");
      e.printStackTrace();

      error = e.toString();
    }
  }

  void drawDay(int x, int y) {
    text(String.format("%,d", totals.day) + "×", x, y);
  }

  void drawWeek(int x, int y) {
    text(String.format("%,d", totals.week) + "×", x, y);
  }

  void drawMonth(int x, int y) {
    text(String.format("%,d", totals.month) + "×", x, y);
  }

  void drawYear(int x, int y) {
    text(String.format("%,d", totals.year) + "×", x, y);
  }

  void drawTicker(long now, int refreshInterval) {
    // Refresh data after state has changed for the 5th time, wrapping it back around to day
    if (lastTimestamp == 0 || (now - lastTimestamp) > refreshInterval * 5) {
      getTotal();

      lastTimestamp = now;
    }

    if (error != null) {
      text(error, legendOffset, (height - tickerOffsetY) + textOffset);
    } else if (this.totals != null) {
      textAlign(RIGHT);
      textSize(20);

      int x = width - 20;
      int y = (height - tickerOffsetY) + textOffset;

      translate(x, y);

      rotate(PI*1.5);

      fill(disabledTextColor);

      if (state == State.DAY) fill(primaryTextColor);
      text("D", 0, 0);
      fill(disabledTextColor);

      if (state == State.WEEK) fill(primaryTextColor);
      text("W", -20, 0);
      fill(disabledTextColor);

      if (state == State.MONTH) fill(primaryTextColor);
      text("M", -40, 0);
      fill(disabledTextColor);

      if (state == State.YEAR) fill(primaryTextColor);
      text("Y", -60, 0);

      rotate(HALF_PI);
      translate(-x, -y);

      textAlign(RIGHT, TOP);
      textSize(primaryTextSize);
      fill(primaryTextColor);

      x = x - 20;

      switch (state) {
      case DAY:
        drawDay(x, y);
        break;
      case WEEK:
        drawWeek(x, y);
        break;
      case MONTH:
        drawMonth(x, y);
        break;
      case YEAR:
        drawYear(x, y);
        break;
      }

      x = x + 20;

      if (streak > 0) {
        float val = map(streak, 0, maxStreak, 0, 120);
        fill(val, 255, 255);
      }

      textAlign(LEFT, TOP);
      if (streakIncreased) {
        text("^", legendOffset, (height - tickerOffsetY + 10) + textOffset);
      } else {
        text("-", legendOffset, (height - tickerOffsetY) + textOffset);
      }

      state = state.increment(state);
    }
  }
}
