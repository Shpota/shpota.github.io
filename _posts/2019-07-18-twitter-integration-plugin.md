---
layout: post
title:  "Twitter Integration Plugin for JetBrains IDEs"
date:   2019-07-18 10:00:00 +0200
comments: true
img:
  href: 2019-07-18-twitter-plugin-showcase.gif
  alt: Plugin Showcase
---
I have implemented [a small IntelliJ plugin](https://github.com/Shpota/twitter-plugin) to 
post code to Twitter. I often see tweets with code, so I thought why not make a better way 
to tweet. When you have the plugin installed, you can right-click on a selected piece of 
code, press "Tweet" and your IDE will redirect you to the Tweet creation window in your 
browser with the selected text.

{% include picture.html %}

**The source code** of the plugin is available 
[on GitHub](https://github.com/Shpota/twitter-plugin). It is written in Java and built with
Gradle. You are welcome to open issues or pull requests if you want to improve the plugin.

**Installation:** The plugin is available in
[the JetBrains Plugin Repository](https://plugins.jetbrains.com/plugin/12729-twitter-integration).
Go to `Settings` > `Plugins` > `Marketplace` tab > search for `Twitter Integration` > 
press the `Install` button.

{% 
  include picture.html 
  href="2019-07-18-how-to-install-twitter-plugin.png" 
  alt="Plugin Installation"
%}

**Compatibility.** The plugin is compatible with all IntelliJ-based IDEs such as Android Studio, 
CLion, DataGrip, GoLand, IntelliJ IDEA, MPS, AppCode, PhpStorm, PyCharm, Rider, RubyMine, 
WebStorm.

I hope that you will find this plugin fun to use.
