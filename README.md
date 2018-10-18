# Screen2Camera-comm
Implement screen 2 camera communication

## Overview
```
Frame : Spatial-temporal complementary frames design as inframe++
Locator : Follow the standard of QR code for finding out the coordinates of the block
Data Block : STCF design with different patterns
```

## Workflow
### encode
```
1.Import data for transmitting
2.Create mask of brightness according to the data 
3.Add mask to frames with temporal complementary order
```

### decode
```
1.Read video
2.Take two consecutive frames from video and do subtraction
3.Binarize the outcome of subtraction
4.Estimate the changes in size by the proportion of locator
5.Create locators with size calculated above for correlation
6.Find out the coordinates of the block by cross correlation
7.Decode according to the patterns
```


