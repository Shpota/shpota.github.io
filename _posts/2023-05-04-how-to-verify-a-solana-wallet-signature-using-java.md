---
layout: post
title:  "How to Verify a Solana Wallet Signature Using Java?"
date:   2023-05-04 10:00:00 +0200
comments: true
img:
    href: 2023-05-04-the-pursuit-of-happyness.png
    copyright: The Pursuit of Happyness by Gabriele Muccino
    alt: The Pursuit of Happyness Movie
---

One of the most common tasks when dealing with wallets is proving that
the user is really the owner of the wallet. Every time a user links
a wallet to a website, the website has to prove ownership. This can be
easily done on the front-end side with JavaScript, but oftentimes it is
not enough. If a wallet is stored on the backend, it is required to prove
ownership on the backend as well. What if the backend is written in Java?
In this blog post, I will explain how to verify a Solana wallet signature
on the backend using Java.

{% include picture.html %}

I ran into this exact issue a year ago. At the time, I had to use the bitcoinj
library to accomplish it. Although it did its job, the APIs were not convenient,
and I had to write a lot of code to accomplish a simple task. Additionally, as
the name suggests, it is designed for Bitcoin, so it includes a lot of functionality
that I did not need.

However, now this task can be accomplished more easily using
[sol4k](https://github.com/sol4k/sol4k), a Solana RPC client designed for the JVM.
In addition to the RPC functionality, sol4k also allows you to conveniently work
with Solana signatures.

Let's get started. First, the client needs to sign a message and pass the signature
and wallet address to the backend. Here's how you can do it using [Phantom](https://phantom.app).

```javascript
const message = 'You are verifying you wallet with sol4k';
const encodedMessage = new TextEncoder().encode(message);
const signedMessage = await provider.signMessage(encodedMessage, "utf8");
// the wallet address is sent to the backend 
const walletAddress = provider.publicKey.toString();
// here I encode the signature to the Base58 format
const signature = base58.encode(signedMessage.signature);
```

On the backend side, these values need to be decoded and verified. Here's how
you can achieve it with sol4k.

To add sol4k as a dependency, use the following example for Gradle:
```sh
implementation 'org.sol4k:sol4k:0.3.2'
```

Use the `PublicKey.verify()` function to handle the signature.

```java
boolean verifySignature(String signature, String walletAddress) {
    String message = "You are verifying you wallet with sol4k";
    byte[] messageBytes = message.getBytes();
    PublicKey publicKey = new PublicKey(walletAddress);
    byte[] signatureBytes = Base58.decode(signature);
    return publicKey.verify(signatureBytes, messageBytes);
}
```

That's all you need to prove that the user is really who they claim to be.

I have prepared a demo project with this functionality which you can find
[on GitHub](https://github.com/Shpota/solana-wallet-linking). Run `docker-compose up`,
and it will build both the back end and the frontend. You will be able to access
the website at [http://localhost:8080](http://localhost:8080/).

{% include video.html src="/assets/video/2023-05-04-signing-message-with-sol4k.mp4"%}

In summary, verifying a Solana wallet signature using Java is a straightforward process
when you have the right tools and understanding. With caution, practice, and research,
you can become proficient in working with Solana no matter what language you use. Good luck!
