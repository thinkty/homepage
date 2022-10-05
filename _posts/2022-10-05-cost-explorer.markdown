---
title:  "Using the AWS Cost Explorer to Stop Bill Bombs"
date:   2022-10-05
categories: Updates
---

From time to time, I see posts on reddit where a user accidentally gets charged with stupendous amounts of bill due to some mistake they made in the past.
I've seen a post where a university student allocated an EC2 instance (can't remember which type of instance) for a senior project, and later forgot to delete the EC2 instance and getting a billing of over several grands.
Whenever I saw these kind of posts, I never thought that it would happen to me since I always use free-tier.
However, today I learned that I was also liable to those charges.

Long story short, in my case, I launched a [t2.micro](https://aws.amazon.com/ec2/instance-types/) instance to do some message passing and make it a general purpose backend API server for various projects.
Then, like any other mortals, I *forgot* that I allocated an EC2 instance and just went along my way.
As an excuse, I didn't really forget about it, because I stopped the instance from running.
However, that wasn't the same as [terminating](https://aws.amazon.com/premiumsupport/knowledge-center/delete-terminate-ec2/) the instance as I still had the instance allocated to me, ready to run on my command.

If I remember correctly, t2.micro was one of the smallest instance that I was able to find.
Thanks to this, the pricing wasn't that bad at all.
It was billing me about an extra of $1 monthly.
You may be laughing at the pewny numbers, but to a uni-student who doesn't have any source of income, I couldn't let that slip.

![slip](/assets/images/2022-10-05-cost-01.png)

I quickly terminated the instance and will have to see if it doesn't get charged anymore.
After this incident, I came up with two simple rules to stop enourmous bills on my doorstep.
1. Set a budget with alerts
2. Regularly check the bills

Setting a budget and checking the bills can all be done at the [Billing](https://us-east-1.console.aws.amazon.com/billing/) service.
To set a budget, go to the `Budgets` under `Cost Management` and click the `Create budget` button.

![budget](/assets/images/2022-10-05-cost-02.png)

When creating a budget, the amount can be specified alongside with the email address that the notification should be sent to.

To check the bills, it is very simple.
Navigate to `Bills` and the details of which services at which region is being billed the amount.

![bill](/assets/images/2022-10-05-cost-03.png)

Since it shows the bill by the service and location, one can locate the resource and make modifications to adjust the bill with ease.
I hope this post was helpful to keeping your pockets healthy.
