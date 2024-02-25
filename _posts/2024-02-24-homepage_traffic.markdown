---
title:  "Analyzing Homepage Traffic"
date:   2024-02-24
categories: general
---

I've recently switched from using [Lamdba@Edge](https://aws.amazon.com/lambda/edge/) to Cloudfront [Functions](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html) as it was a better option for my use case. I've covered it briefly in [this](general/2024/01/10/cloudfront_functions.html) post.

After making the switch, I remembered how I was able to see website traffic back when I used Google Analytics.
Although I don't use it today, I suddenly got curious and wanted to see who were visiting my homepage (if there were any).
So I decided to use the Cloudfront function to gather some logs.
I had my expectations pretty low as I don't really care and I always paid a penny (literally 1 penny) for S3 usage which shows how empty the traffic is. 

I only collected the IP address and the requested URI.
I printed those info to the console and was able to store the logs using Cloudwatch.
According to the [pricing page](https://web.archive.org/web/20240217190217/aws.amazon.com/cloudwatch/pricing/) archived on February 17th, 2024, you can store *5 GB* of data (including not only logs but also Log Insight query transfers and more) for free.
Since the pricings may change, make sure to visit the most up-to-date [pricing page](https://aws.amazon.com/cloudwatch/pricing/).

After waiting for 2 weeks, I've collected about 600 logs.
I then created a temporary S3 bucket to store the logs and eventually downloaded them all using the `aws-cli`.
There are multiple ways to download object(s) from S3, so check out the instructions [here](https://docs.aws.amazon.com/AmazonS3/latest/userguide/download-objects.html). 
Since data transfer out from S3 buckets are billed, make sure to check the [pricing](https://aws.amazon.com/s3/pricing/).
After downloading all the logs, I ran a simple bash script to parse and gather all the *date*, *IP*, and *URI*.

```shell
#!/bin/bash

rm -f "./logs.csv"
touch "./logs.csv"

# Parse date, ip, uri
for subdir in */; do
    
    cd "$subdir"
    
    for compressed_log in *.gz; do
        gzip -dk "$compressed_log"
        cat "${compressed_log%.gz}" | sed -n "s/^\(.*Z\) .* IP : \(.*\), URI: \(.*\)$/\1,\2,\3/p" >> "../logs.csv"
        rm "${compressed_log%.gz}"
    done
    
    cd ".."
done

# Parse the IP and URI into separate files
cat "./logs.csv" | sed -n "s/^.*,\(.*\),.*$/\1/p" > "./ip"
cat "./logs.csv" | sed -n "s/^.*,.*,\(.*\)$/\1/p" > "./uri"

# Sort and count the occurrences of IP and URI 
sort "./ip" | uniq -c | sort -nr > "./ip_sorted"
sort "./uri" | uniq -c | sort -nr > "./uri_sorted"
```

After I got the lists, I first looked at the URIs.
Most of the requests were pretty normal and related to the posts and the main page.
However, there were some abnormal requests such as the following:

```
  count uri
      7 /ads.txt
      6 /wp-login.php
      4 /app-ads.txt
      3 /wp-admin/css/
      3 /.well-known/
      3 /.env
      2 //xmlrpc.php
      2 /filemanager/dialog.php
      1 /_profiler/empty/search/results
      1 /insurance/public/admin/lib/webuploader/0.1.5/server/preview.php
      1 /.git/HEAD
      1 /Content/themes/js/plugin/ueditor-1.4.3.3/net/controller.ashx
```

There were requests for `/wp-login.php` from various places such as a VPN in Chicago and Republic of Mauritius which is an island country east of Madagascar that has a population of about 1.26 million.

One that caught my eye was `//xmlrpc.php` due to its weird URI (notice two forward slashes) and I also suspected RPC to mean remote procedure call.
After some searching, I found that it was a php module to remotely manage your WordPress site.
According to multiple articles online, it used to be automatically enabled in older versions of WordPress and it was highly recommended to disable the module due to security concerns.
From the same IP that tried to access the RPC, it made two separate batches of calls looking for other WordPress-related resources.
An IP look up showed that it was coming from a data center, so I'm guessing that someone or some organization is trying to do some shady stuff.
In addition, there were so many other requests to resources that were related to WordPress.
Not only were there requests to old versions of WordPress modules that had known vulnerabilities, there were some that were related to a quite [recent](https://nvd.nist.gov/vuln/detail/CVE-2023-2245) vulnerability, and many of those IPs were blacklisted on some anti-spam databases.

There were some weird cases where a crawler was trying to access my old posts through a VPN in Germany.
It was weird because it tried to access my old posts that I wrote in Korean which don't exist now.
I'm not sure how or why.

There were also some requests trying to access `.git` for some reason.

Moving on to IP addresses, I found that many were from web crawlers that are probably used for updating the search engines like Google.
The reasoning is that the top IP addresses that visited my website looked for `robot.txt` which contains instructions to web crawler bots, and it also only looked at the links visible in the root `/` of the webpage within the span of 2~4 seconds.
Atleast 55% of the requests were coming from the same type of web crawlers.

> In summary, internet is actually full of bots and there are strangers who have malicious intent.
