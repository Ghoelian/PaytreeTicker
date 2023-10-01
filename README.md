## Paytree ticker
A little Processing program that displays a graph showing the amount of transactions per 10 minutes over the past 8 hours,
and the total turnover over the entire history of Paytree.

### Screenshot
![Screenshot](https://github.com/Ghoelian/PaytreeTicker/blob/master/data/screenshot.png?raw=true)

The indicator to the right of the total indicates wether the total turnover has increased since the last refresh. If so, it displays a ^ and records a streak. If not, it displays a - and resets the streak back to 0.
The colour of the indicator is mapped from 0 to the max streak the program has recorded, to hsv(0), hsv(120) for red to yellow to green.

These values are saved to a file, so the max streak is remembered.
