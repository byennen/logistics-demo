## Transportation

The purpose of this challenge is to model, in a very simple way, the transportation domain. The goal is to model a multi-stop "load" or "delivery", moving from point A to point Z. Please use ActiveRecord/Rails or something equivalent as the next two challenges build on this.

## Task

Take input from the command line to create a multi-stop "load" or "delivery". This challenge doesn't require representing what's being carried, picked up, or dropped off. For example:

- Stop A - Orlando
- Stop B - Chicago
- Stop C - New York

The input/output would look something like below

```
$ ruby cloud_logistics.rb
Number of stops:
> 3
Carrier name:
> YRC
Origin:
> Ft Lauderdale
1st stop:
> West Palm Beach
Destination:
> Orlando
Bill of lading number 1, being carried by YRC
 - Origin: Ft Lauderdale
 - 1st stop: West Palm Beach
 - Destination: Orlando
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
