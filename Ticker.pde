import java.math.BigDecimal;
import java.text.DecimalFormat;
import http.requests.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.time.LocalDateTime;
import java.time.ZoneId;
import com.google.gson.Gson;

int tickerOffsetY = 150;

public enum State {
  EIGHT_HOURS, WEEK, MONTH, YEAR, ALL;

  public State increment(State state) {
    switch (state) {
    case EIGHT_HOURS:
      return State.ALL;
    case WEEK:
      return State.EIGHT_HOURS;
    case MONTH:
      return State.WEEK;
    case YEAR:
      return State.MONTH;
    case ALL:
      return State.YEAR;
    default:
      return State.ALL;
    }
  }
}

class Totals {
  private int eightHours;
  private int week;
  private int month;
  private int year;
  private int all;

  Totals() {
  }
}

private State state = State.ALL;

class Ticker {
  private Gson gson = new Gson();
  private int textOffset = tickerOffsetY - 100;

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

      if (totals != null && newTotals.eightHours > totals.eightHours) {
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

  void drawEightHours(int x, int y) {
    text(String.format("%,d", totals.eightHours) + "×", x, y);
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

  void drawAll(int x, int y) {
    text(String.format("%,d", totals.all) + "×", x, y);
  }

  void drawTicker() {
    getTotal();

    if (error != null) {
      text(error, legendOffset, (height - tickerOffsetY) + textOffset);
    } else if (this.totals != null) {
      textAlign(RIGHT, BOTTOM);
      textSize(20);

      int x = width - 20;
      int y = (height - tickerOffsetY) + textOffset;

      fill(disabledTextColor);

      int subtitleOffsetY = 85;

      int letterSpacing = 12;
      int spacing = 0;
      int padding = 15;

      if (state == State.EIGHT_HOURS) fill(primaryTextColor);
      text("8HRS", x - spacing, y + subtitleOffsetY);
      fill(disabledTextColor);

      spacing += ("8HRS".length() * letterSpacing) + padding;

      if (state == State.WEEK) fill(primaryTextColor);
      text("WEEK", x - spacing, y + subtitleOffsetY);
      fill(disabledTextColor);

      spacing += ("WEEK".length() * letterSpacing) + padding;

      if (state == State.MONTH) fill(primaryTextColor);
      text("MONTH", x - spacing, y + subtitleOffsetY);
      fill(disabledTextColor);

      spacing += ("MONTH".length() * letterSpacing) + padding;

      if (state == State.YEAR) fill(primaryTextColor);
      text("YEAR", x - spacing, y + subtitleOffsetY);
      fill(disabledTextColor);

      spacing += ("YEAR".length() * letterSpacing) + padding;

      if (state == State.ALL) fill(primaryTextColor);
      text("ALL", x - spacing, y + subtitleOffsetY);

      textAlign(RIGHT, TOP);
      textSize(primaryTextSize);
      fill(primaryTextColor);

      y -= 20;

      switch (state) {
      case EIGHT_HOURS:
        drawEightHours(x, y);
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
      case ALL:
        drawAll(x, y);
        break;
      }

      if (streak > 0) {
        float val = map(streak, 0, maxStreak, 0, 120);
        fill(val, 255, 255);
      }

      textAlign(LEFT, TOP);
      if (streakIncreased) {
        text("^", legendOffset, y + 10);
      } else {
        text("-", legendOffset, y);
      }

      state = state.increment(state);
    }
  }
}
