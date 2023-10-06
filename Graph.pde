import com.google.gson.Gson;
import java.time.format.DateTimeFormatter;

int legendOffset = 60;
DateTimeFormatter time = DateTimeFormatter.ofPattern("HH:mm");
DateTimeFormatter dateTime = DateTimeFormatter.ofPattern("dd/MM HH:mm");

class Graph {
  private Gson gson = new Gson();

  private LocalDateTime startDate;
  private LocalDateTime endDate;

  private int[] data;

  private int highest;
  private int middle;
  private int lowest;

  private int stepSize;

  private long lastTimestamp = 0;

  LocalDateTime getStartDate() {
    LocalDateTime now = LocalDateTime.now();
    int div = now.getMinute() / refreshInterval;

    int nearestMultiple = div * refreshInterval;

    if (nearestMultiple == 60) {
      nearestMultiple = 0;

      now.plusHours(1);
    }

    return LocalDateTime.of(
      now.getYear(),
      now.getMonth(),
      now.getDayOfMonth(),
      now.getHour(),
      nearestMultiple
      ).minusHours(8);
  }

  LocalDateTime getEndDate() {
    LocalDateTime now = LocalDateTime.now();
    int div = now.getMinute() / refreshInterval;

    int nearestMultiple = div * refreshInterval;

    if (nearestMultiple == 60) {
      nearestMultiple = 0;

      now.plusHours(1);
    }

    return LocalDateTime.of(
      now.getYear(),
      now.getMonth(),
      now.getDayOfMonth(),
      now.getHour(),
      nearestMultiple
      );
  }

  void getData() {
    startDate = getStartDate();
    endDate = getEndDate();

    GetRequest request = new GetRequest("https://api.paytree.nl/v1/status/stats");
    request.addHeader("Authorization", apiKey);
    request.send();

    String result = request.getContent();

    int[] arr = gson.fromJson(result, int[].class);
    data = arr;

    highest = findHighest(data);
    lowest = findLowest(data);
    middle = (highest + lowest) / 2;

    if (middle == lowest) middle = highest;

    legendOffset = String.valueOf(highest).length() * 24;

    if (data != null && data.length > 0) {
      stepSize = (width - legendOffset) / data.length;
    }
  }

  void drawGraph(long now) {
    // Refresh data after state has cycled through all states, wrapping it back around to day
    if (lastTimestamp == 0 || (now - lastTimestamp) > refreshInterval * State.values().length) {
      getData();

      lastTimestamp = now;
    }

    fill(255);
    stroke(255);

    int legendY = height - tickerOffsetY;

    line(legendOffset, 10, legendOffset, legendY);
    line(legendOffset, height - tickerOffsetY, width - 10, legendY);

    textSize(20);

    textAlign(RIGHT, TOP);
    text(highest, 35, 10);

    if (middle != highest && middle != lowest) {
      textAlign(RIGHT, CENTER);
      text(middle, 35, legendY / 2);
    }

    if (lowest != highest) {
      textAlign(RIGHT, BOTTOM);
      text(lowest, 35, legendY);
    }

    if (startDate != null) {
      textAlign(LEFT, BOTTOM);

      if (startDate.getDayOfMonth() == endDate.getDayOfMonth()) {
        text(startDate.format(time), legendOffset, legendY + 30);
      } else {
        text(startDate.format(dateTime), legendOffset, legendY + 30);
      }
    }

    if (endDate != null) {
      textAlign(RIGHT, BOTTOM);

      if (startDate.getDayOfMonth() == endDate.getDayOfMonth()) {
        text(endDate.format(time), width - 10, legendY + 30);
      } else {
        text(endDate.format(dateTime), width - 10, legendY + 30);
      }
    }

    if (data != null) {
      stroke(24, 94.6, 94.9);
      strokeWeight(2);

      int graphOffset = 4;

      // Draw lines between all data points, connecting first to second etc.
      // which means the second-to-last datapoint will connect to the final datapoint,
      // so we can skip drawing a line from the last datapoint to nothing.
      for (int i = 0; i < data.length - 1; i++) {
        int current = this.data[i];

        int next = data[i + 1];

        float currentLineY;
        float nextLineY;

        float graphLowerY = legendY - graphOffset;

        if (highest == middle) {
          currentLineY = map(current, highest, highest, graphLowerY, 10);
          nextLineY = map(next, highest, highest, graphLowerY, 10);
        } else {
          currentLineY = map(current, lowest, highest, graphLowerY, 10);
          nextLineY = map(next, lowest, highest, graphLowerY, 10);
        }

        if (Float.isInfinite(currentLineY)) currentLineY = graphLowerY;
        if (Float.isNaN(currentLineY)) currentLineY = 10;

        if (Float.isInfinite(nextLineY)) nextLineY = graphLowerY;
        if (Float.isNaN(nextLineY)) nextLineY = 10;

        line(
          (i * stepSize) + legendOffset + graphOffset,
          currentLineY,
          ((i + 1) * stepSize) + legendOffset + graphOffset,
          nextLineY
          );
      }
    }
  }

  int findHighest(int[] data) {
    if (data == null) {
      return highest;
    }

    int result = -1;

    for (int i = 0; i < data.length; i++) {
      if (data[i] > result) {
        result = data[i];
      }
    }

    return result;
  }

  int findLowest(int[] data) {
    if (data == null) {
      return lowest;
    }

    int result = -1;

    for (int i = 0; i < data.length; i++) {
      if (result == -1) {
        result = data[i];
        continue;
      }

      if (data[i] < result) {
        result = data[i];
      }
    }

    return result;
  }
}
