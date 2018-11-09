---
layout: post
title:  "Shipping Docker with Java Application"
date:   2017-02-19 23:44:26 +0200
comments: true
---
Docker is not a new technology anymore. In the meanwhile, it has become an 
everyday tool for many developers. However, there are still a lot of people out there
who haven't tried Docker. In this article, I'm going to show you how to ship
a standalone Java application in a Docker container.

{% 
  include picture.html 
  href="2017-02-19-shipping-docker-with-java.jpg" 
  copyright="atlanticshipping.is"
%}

<br/>
**Docker installation**

Follow the instructions from 
[docker.com](https://docs.docker.com/engine/installation/).

**Create java project**

Create a simple java project with main method.  
{% highlight java %}
package hello;

import java.time.LocalTime;

public class HelloWorld {
    public static void main(String[] args) throws InterruptedException {
        while (true) {
            Thread.sleep(2000);
            System.out.println("The current time is: " + LocalTime.now());
        }
    }
}
{% endhighlight %}  

This code does nothing else other than notifying the user every 2 seconds.  
Build this code into a jar using your IDE. Or if you're lazy, just 
[download the project from GitHub](https://github.com/Shpota/java-docker-example).
It already contains the jar file as well.

**Prepare Dockerfile**

Create a file with the name `Dockerfile` to the root of your project and add 
the next commands into it:
  
{% highlight sh %}
FROM openjdk:8
ADD build/libs/java-docker-example-0.1.0.jar /opt/hello/app.jar
WORKDIR /opt/hello
ENTRYPOINT [ "sh", "-c", "java -cp app.jar hello.HelloWorld" ]
{% endhighlight %}
  
The first directive of this file creates a docker image based on 
[openjdk jre-8 image](https://hub.docker.com/_/openjdk/). It is 
an Ubuntu distribution with JRE installed on top of it.
  
The second directive copies the jar file into the Docker image.
Note: if you're using your own jar file (not the one from GitHub), you
might have a different jar name. If so - simply replace 
`build/libs/java-docker-example-0.1.0.jar` with your own jar name, thus providing 
an appropriate path.
  
The third step sets the work directory of the image into the directory 
which contains the jar.
  
And the last directive performs `sh` command which runs java. You can also 
use a shorter form `java -jar app.jar`, but make sure that your manifest
contains a reference to the main class.

**Build Docker image**

Open terminal in root folder of your project and perform the command:

{% highlight sh %}
$ docker build -t java-docker-example .
{% endhighlight %}

This might take some time, because Docker will download all the 
dependencies. Once it is ready, you'll see something like this:
```
Sending build context to Docker daemon 442.4 kB
Step 1 : FROM openjdk:8
 ---> 8dde5631d4aa
Step 2 : ADD build/libs/java-docker-example-0.1.0.jar /opt/hello/app.jar
 ---> Using cache
 ---> 423df7defd3b
Step 3 : WORKDIR /opt/hello
 ---> Using cache
 ---> 479a3a5f110e
Step 4 : ENTRYPOINT sh -c java -cp app.jar hello.HelloWorld
 ---> Using cache
 ---> f46dfdb8195b
Successfully built f46dfdb8195b
```

Now if you run the command
{% highlight sh %}
$ docker images
{% endhighlight %}
you'll see the newly built image 
{% highlight sh %}
REPOSITORY             TAG      IMAGE ID       CREATED         SIZE
java-docker-example    latest   f46dfdb8195b   7 minutes ago   641.5 MB
{% endhighlight %}

**We're ready to run the container**

Perform:
{% highlight sh %}
$ docker run java-docker-example
{% endhighlight %}
and you'll see the output from your code:
```
The current local time is: 23:32:55.617
The current local time is: 23:32:57.621
The current local time is: 23:32:59.622
The current local time is: 23:33:01.624
The current local time is: 23:33:03.625
```

You can watch your running containers by executing `$ docker ps` command.
You can also stop or remove your container.
 
`docker stop c79f70478154` stops the container with `CONTAINER ID` c79f70478154 (you 
 can find CONTAINER ID in `docker ps` output).

`docker rm c79f70478154` removes the container with id c79f70478154

`docker rm -f c79f70478154` removes the container even if it is still running.

