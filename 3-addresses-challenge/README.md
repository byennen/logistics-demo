## Addresses

The purpose of this challenge is to build upon the previous task and add full address support to each stop. This includes latitude and longitude.

## Task

Take input from the command line to create a multi-stop "load" or "delivery" as in the last challenge. This time, instead of a generic name for a stop, we'll take an address entered in the command line, break it into it's components and geocode it.

At each stop, an address is required with the following data:

- Address line 1
- City
- State
- Zipcode
- Country
- Latitude
- Longitude

The input/output would look something like below

```
$ ruby cloud_logistics.rb
Number of stops:
> 3
Carrier name:
> YRC
Origin:
> 333 Las Ols Way, Ft Lauderdale, FL. 33301
1st stop:
> 222 Lakeviw Ave, West Palm Beach, FL. 33401
Destination:
> 545 Hibiscus St, West Palm Beach, FL 33401
Bill of lading number 1, being carried by YRC
 - Origin: 333 Las Olas Way, Ft Lauderdale, FL. 33301, 26.117569, -80.141218
 - 1st stop: 222 Lakeview Ave, West Palm Beach, FL. 33401, 26.705829, -80.051017
 - Destination: 545 Hibiscus St, West Palm Beach, FL 33401, 26.709269, -80.056220
```

### What we are looking for

Approach this problem as if it is an application going to production.  We don't expect it to be perfect (no production code is), but we also don't want you to hack together a throw-away script.  This should be representative of something that you would be comfortable releasing to a production environment.  

Also, spend whatever amount of time you think is reasonable. You may use whatever gems, frameworks and tools that you think are appropriate, just provide any special setup instructions when you submit your solution.

We are looking for you to demonstrate your knowledge related to common software practices to include reusability, portability and encapsulation - to name a few.

Please do not fork the question.


### Put all your code in a directory

Usually candidates are assigned multiple challenges. For each challenge put all your code in a directory. For example if
the challenge is to find github score for DHH then directory name could be `github-score-for-dhh`.

In this way when you are finished with all challenges and all your pull requests are merged then we have one directory for each challenge.

Again, please do not fork questions.
