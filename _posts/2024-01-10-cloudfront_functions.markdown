---
title:  "Using Cloudfront Functions instead of Lambda"
date:   2024-01-10
categories: general
---

Recently, I had to upgrade the Node.js version on my [AWS Lambda](https://aws.amazon.com/lambda/) function.
The function was a pretty simple URI parser which was needed for my homepage to add/remove file extensions to the requested URL.
For example, when a user first visits `thinkty.net/`, they probably want to see my homepage which is actually `thinkty.net/index.html` and not the home directory.
So, for those cases, a Lambda function (Lambda@Edge) would intervene and update the URI accordingly to ensure that the user sees what they want.
To learn more about homepage setup using AWS tools, checkout my other [post](https://thinkty.net/general/2020/07/04/aws_complete_tutorial.html).

While updating the Lambda function and configuring the Cloudfront distribution to use the latest published version, I noticed the option to use [Cloudfront Functions](https://aws.amazon.com/blogs/aws/introducing-cloudfront-functions-run-your-code-at-the-edge-with-low-latency-at-any-scale/) instead.
To summarize my comprehension on Cloudfront Functions, it's similar to Lambda@Edge, but it is *cheaper* as it has limited features such as no network access, limited triggers, and way less computing power.
However, there were some advantages over Lambda and one was that it is deployed in the earlier steps of the request compared to Lambda as shown in the image (from AWS) below.

![cloudfront function and lambda deployment positions](/assets/images/2024-01-10-cloudfront_functions-01.png)

This forward deployment meant that it will result in lower latency (as stated in the blog), which I was not able to feel the difference since I didn't really care too much on the speed as long as it was good enough.
I don't know how many ms or ns this will reduce, but my selling point was on the price.

For my basic usage that does not require file access or network access, for a free-tier loving person like me, Cloudfront Functions is a better option compared to Lambda for my use cases since Lambda is free for 1 million requests per month whereas Cloudfront Functions is free for 2 million invocations.
Although nobody visits my site often to reach the limits of free-tier, it does not hurt to take precautions especially when it comes to pay-only-what-you-use business models.

Also, I just like the idea of keeping all the related stuff together.
Now, if I encounter a bug, I just need to handle it all in Cloudfront instead of the tedious process of publishing a new version on Lambda and updating the configurations in Cloudfront manually.

Using the Cloudfront Functions is similar to Lambda and one can easily learn the syntax/how-tos based on their use cases from the [documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/function-code-choose-purpose.html). Also, this [documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/functions-event-structure.html#functions-event-structure-request) on the `event` structure was helpful for me so I'll leave it here as well.
