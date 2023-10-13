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

  private long lastTimestamp = 0;

  LocalDateTime getStartDate() {
    LocalDateTime now = LocalDateTime.now();
    Double div = Double.valueOf(now.getMinute()) / Double.valueOf(refreshInterval);

    int nearestMultiple = div.intValue() * refreshInterval;

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
    Double div = Double.valueOf(now.getMinute()) / Double.valueOf(refreshInterval);

    int nearestMultiple = div.intValue() * refreshInterval;

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

    GetRequest request = new GetRequest("https://api.paytree.nl/v1/status/stats?interval=5");
    request.addHeader("Authorization", apiKey);
    request.send();

    String result = request.getContent();

    int[] arr = gson.fromJson(result, int[].class);
    data = arr;

    highest = findHighest(data);
    lowest = findLowest(data);
    middle = (highest + lowest) / 2;

    if (middle == lowest) middle = highest;

    legendOffset = String.valueOf(highest).length() * 20 + 5;
  }

  void drawGraph(long now) {
    // Refresh data after state has cycled through all states, wrapping it back around to day
    if (lastTimestamp == 0 || (now - lastTimestamp) > refreshInterval * State.values().length) {
      getData();

      lastTimestamp = now;
    }

    fill(255);

    int legendY = height - tickerOffsetY;

    stroke(115);
    line(legendOffset, (legendY/3), width - 10, (legendY/3));
    line(legendOffset, (legendY/3)*2, width - 10, (legendY/3)*2);

    textSize(20);

    textAlign(RIGHT, CENTER);

    text(highest, String.valueOf(highest).length() * 20, 20);

    if (lowest < highest) {
      text((int) map(2, 0, 3, lowest, highest), 35, (legendY/3));
      text((int) map(1, 0, 3, lowest, highest), 35, (legendY/3)*2);
      text(lowest, 35, legendY - 10);
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
          map(i, 0, data.length - 1, legendOffset, width - 10),
          currentLineY,
          map(i + 1, 0, data.length - 1, legendOffset, width - 10),
          nextLineY
          );
      }
    }

    stroke(255);
    line(legendOffset, 10, legendOffset, legendY);
    line(legendOffset, legendY, width - 10, legendY);
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
