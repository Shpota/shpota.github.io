---
layout: post
title:  "A Better Structure for Kotlin Projects"
date:   2020-11-05 10:00:00 +0200
comments: true
img:
  href: 2020-11-05-matthew-mccounaghey.png
  copyright: Dallas Buyers Club by Craig Borten
  alt: Dallas Buyers Club
---
When I write programs in Kotlin I usually don't think, where to
put my source files and how to structure packages; my build
tool knows it better. After years of working with Java and then
with Kotlin, it is not a surprise that code lies in `src/main/kotlin`
and tests in `src/test/kotlin`. I know where the `resources` are and how
they are packaged. Paths like `com/companyname/projectname` are paths
corresponding to package names. This all looks familiar.
However, we are so used to such setups, that we often don't
understand what inconveniences they bring. In this article, I will
explain what's wrong with these defaults and how we can do better. 

{% include picture.html %}

First, let's recall why we use such setups. They became
popular with Maven which introduced a unified way of storing source
sets. Such a structure is flexible enough to cover many use cases.
For instance, if a project was written with several languages, you
would solve it easily by adding language-specific folders: `src/main/java`,
`src/main/groovy`, etc. Gradle reused the same pattern, and it became
a de facto standard. Finally, people started introducing Kotlin to their
Java projects which could perfectly utilize this pattern. It was convenient
to have Java and Kotlin side by side until projects get fully migrated.

Now, at the end of 2020, having Java and Kotlin in one project is not a common
scenario anymore. People boost new projects in Kotlin and those who prefer
Java stay with Java. In the majority of cases, we don't need this flexibility
anymore as we don't have to carry Java code anywhere in Kotlin projects.

Yet, we still utilize projects structures like this:

```
src
├── main                   
│   └── kotlin
│       └── com
│           └── companyname
│               └── projectname
│                   ├── controllers
│                   ├── services 
│                   └── Main.kt
├── test                   
│   └── kotlin
│       └── com
│           └── companyname
│               └── projectname
│                   ├── controllers
│                   ├── services 
│                   └── MainTest.kt
```
Not only is it complex and verbose, but it also introduces other issues.
If you expand the project structure in an IDE it consumes more width
on the screen leaving less space for the editor. The same issue
appears during code review, especially if you use the side-by-side view.
Long paths, like 
`src/main/kotlin/com/companyname/projectname/services/UserService.kt`,
often don't fit into the screen. For instance, GitHub
might show it like `src/main/kotlin/com/companyname/projectname/servi...`.
You might say that we all work from home and have 27" monitors, and you
will be right. Yet, many use only laptops, where this
issue gets more important. In any way, why would you want to carry
boilerplate in your projects? Is Kotlin not about being pragmatic?
Also, people who only start learning Kotlin and have no
Java background might find it confusing as well. Even if you just need
to take a glance at a project you would have to go through numerous
nested folders which is not the best experience.

What is the solution? Instead, we could use a structure like this

```sh
src
├── controllers
├── services 
└── Main.kt
testSrc                   
├── controllers
├── services 
└── MainTest.kt
```

No, I do not suggest you remove package declarations. Kotlin allows
declaring classes/functions whose packages do not match the folder structure.

The following code will get compiled without issues if it is placed
in the root of a source set.

```kotlin
package com.companyname.projectname

fun main() {
    println("Hello!")
}
```
My suggestion is to omit folders corresponding to the root package,
and use a single directory per subpackage.
```sh
com.companyname.projectname ->             src/
com.companyname.projectname.services ->    src/services
com.companyname.projectname.controllers -> src/controllers

```
Next, how do we get rid of `src/main/kotlin` and `src/test/kotlin`?
This could be achieved by overriding `sourceSets` in a Gradle project.
Just add the following instruction to your `build.gradle`.
```
sourceSets {
    main.kotlin.srcDirs = ['src']
    test.kotlin.srcDirs = ['testSrc']
}
```

The same could be done for the `resources` folder.

These simple manipulations allow us to reduce the amount of boilerplate
in our code bases. Of course, it might not fit all types of projects.
But in case of small code bases it gets really handy.