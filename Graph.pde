import com.google.gson.Gson;
import java.time.format.DateTimeFormatter;

int legendOffset = 60;
DateTimeFormatter time = DateTimeFormatter.ofPattern("HH:mm");
DateTimeFormatter dateTime = DateTimeFormatter.ofPattern("dd/MM HH:mm");

class Graph {
  private Gson gson = new Gson();

  private LocalDateTime startDate;
  private LocalDateTime endDate;

  private float[] data;

  private float highest;
  private float lowest;

  private int graphOffset = 4;
  private int legendY = height - tickerOffsetY;
  private float graphLowerY = legendY - graphOffset;

  LocalDateTime getStartDate() {
    LocalDateTime now = LocalDateTime.now();
    Double div = Double.valueOf(now.getMinute()) / Double.valueOf(5);

    int nearestMultiple = ((int)Math.round(div)) * 5;

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
    Double div = Double.valueOf(now.getMinute()) / Double.valueOf(5);

    int nearestMultiple = ((int)Math.round(div)) * 5;

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

    GetRequest request = new GetRequest("https://api.paytree.nl/v1/status/stats?interval=5&start=" + startDate + "&end=" + endDate);
    request.addHeader("Authorization", apiKey);
    request.send();

    String result = request.getContent();

    float[] arr = gson.fromJson(result, float[].class);
    data = arr;

    highest = findHighest(data);
    lowest = findLowest(data);

    legendOffset = String.format("%.1f", highest).length() * 15;
  }

  void drawGraph() {
    getData();

    fill(255);

    stroke(115);
    line(legendOffset + 5, map(3, 0, 4, graphLowerY, 10), width - 10, map(3, 0, 4, graphLowerY, 10));
    line(legendOffset + 5, map(2, 0, 4, graphLowerY, 10), width - 10, map(2, 0, 4, graphLowerY, 10));
    line(legendOffset + 5, map(1, 0, 4, graphLowerY, 10), width - 10, map(1, 0, 4, graphLowerY, 10));

    textSize(20);

    textAlign(RIGHT, CENTER);

    float topMid = map(3, 0, 4, lowest, highest);
    float mid = map(2, 0, 4, lowest, highest);
    float bottomMid = map(1, 0, 4, lowest, highest);

    text(String.format("%.1f", highest), legendOffset, 20);
    text(String.format("%.1f", topMid), legendOffset, map(3, 0, 4, graphLowerY, 10));
    text(String.format("%.1f", mid), legendOffset, map(2, 0, 4, graphLowerY, 10));
    text(String.format("%.1f", bottomMid), legendOffset, map(1, 0, 4, graphLowerY, 10));
    text(String.format("%.1f", lowest), legendOffset, legendY - 10);

    if (startDate != null) {
      textAlign(LEFT, BOTTOM);

      if (startDate.getDayOfMonth() == endDate.getDayOfMonth()) {
        text(startDate.format(time), legendOffset + 5, legendY + 30);
      } else {
        text(startDate.format(dateTime), legendOffset + 5, legendY + 30);
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

      // Draw lines between all data points, connecting first to second etc.
      // which means the second-to-last datapoint will connect to the final datapoint,
      // so we can skip drawing a line from the last datapoint to nothing.
      noFill();
      beginShape();

      for (int i = 0; i < data.length; i++) {
        float current = this.data[i];

        float currentLineY;

        if (highest == lowest) {
          currentLineY = map(current, highest, highest, graphLowerY, 10);
        } else {
          currentLineY = map(current, lowest, highest, graphLowerY, 10);
        }

        if (Float.isInfinite(currentLineY)) currentLineY = graphLowerY;
        if (Float.isNaN(currentLineY)) currentLineY = 10;

        vertex(map(i, 0, data.length - 1, legendOffset + 5, width - 10), currentLineY);
      }

      endShape();
    }

    stroke(255);
    line(legendOffset + 5, 10, legendOffset + 5, legendY);
    line(legendOffset + 5, legendY, width - 10, legendY);
  }

  float findHighest(float[] data) {
    if (data == null) {
      return highest;
    }

    float result = -1;

    for (int i = 0; i < data.length; i++) {
      if (data[i] > result) {
        result = data[i];
      }
    }

    return result;
  }

  float findLowest(float[] data) {
    if (data == null) {
      return lowest;
    }

    float result = -1;

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
