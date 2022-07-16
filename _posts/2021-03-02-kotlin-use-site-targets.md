---
layout: post
title:  "Unwrapping Use-Site Targets in Kotlin"
date:   2021-03-02 10:00:00 +0200
comments: true
img:
  href: 2021-03-02-dogs-of-berlin.png
  copyright: Dogs of Berlin by Christian Alvart
  alt: Dogs of Berlin
---
I like Kotlin for its expressiveness. Its interoperability with Java
allows the developer to easily use the existing Java ecosystem while
enjoying a modern language. When it comes to annotations Kotlin handles
them almost the same as Java. In Kotlin, a single syntax construction
might be compiled into several JVM constructions. A Kotlin property
would produce a JVM field, a getter, and optionally a setter. This is
where annotation use-site targets are useful.

{% include picture.html %}

Take a look at the following code:

```kotlin
data class User(
    @Unique
    val name: String,
    @Size(min = 18, max = 100)
    val age: Int,
)
```

Once it is compiled, the corresponding class would have a constructor,
fields, getters, equals, hashcode, and some other language elements.
In order to generate annotations for getters and fields specifically,
you can specify the so-called use-site targets.

```kotlin
data class User(
    @field:Unique
    val name: String,
    @get:Size(min = 18, max = 100)
    val age: Int,
)
```
In the compiled code the `name` field will be annotated with `@Unique`
and a getter of the `age` property will have the `@Size` annotation.

This all works great unless you forget to put the corresponding target in front
of an annotation. The problem is that there is no intuitive way to find out what
use-site target an annotation has to use. In fact, forgetting to specify an
annotation target is one of the most common sources of bugs in my code.

It would be much more efficient if I could omit the use-site target specifications,
and the Kotlin compiler magically put them into the proper places.

This is exactly the reason why I decided to create 
[Ktargeter](https://github.com/ktargeter/ktargeter). I spent
some time researching the subject. I tried annotation processing and 
code generation, but eventually I went with creating a compiler
plugin. Luckily, Kotlin 1.4 brought [the new JVM IR Backend](https://blog.jetbrains.com/kotlin/2021/02/the-jvm-backend-is-in-beta-let-s-make-it-stable-together/)
which is a set of APIs that allow to easily preprocess Kotlin code.

Long story short, if you don't want to specify annotation use-site
targets or you keep forgetting to use them, you can configure it once
in your Gradle configuration and forget about them while you code:

```gradle
plugins {
    id 'org.ktargeter' version '0.1.0'
}

compileKotlin {
    kotlinOptions.useIR = true
}

ktargeter.annotations = [
        "com.sample.Unique" : "field",
        "com.sample.Size"   : "get"
]
```

This would instruct the compiler to move `@Unique` annotations to field
declarations, and `@Size` annotations to getters. 
