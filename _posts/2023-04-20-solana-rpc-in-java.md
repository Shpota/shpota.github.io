---
layout: post
title:  "Communicating with Solana RPC using Java"
date:   2023-04-20 10:00:00 +0300
comments: true
img:
    href: 2023-04-20-operation-finale.png
    copyright: Operation Finale by Chris Weitz
    alt: Operation Finale Movie
---

Solana is one of the most popular blockchains with increasing adoption.
However, when it comes to development experience and client libraries,
predominantly only JavaScript and Rust are used. But what if you have
an existing project in Java and want to integrate Solana? What about
Android? This is where [sol4k](https://github.com/sol4k/sol4k) comes
into play.

{% include picture.html %}

Sol4k is a Kotlin client for Solana that can be used with Java or any
other JVM language, as well as on Android. It enables communication
with an RPC node, allowing users to query information from the blockchain,
create accounts, read data from them, send different types of transactions,
and work with key pairs and public keys. The client also exposes convenient
APIs to make the developer experience smooth and straightforward.

I started working on sol4k because of the absence of good alternatives to
web3.js in the JVM world. After its first release at 
[the Istanbul Hacker House](https://solana.com/events/istanbulhh),
sol4k had 20+ new releases. It now covers most of the popular RPC
calls and handles all essential cryptographic operations.

Here is how you can transfer SOL from one account to another with sol4k:

```java
var connection = new Connection("https://api.devnet.solana.com");
var blockhash = connection.getLatestBlockhash();
var sender = Keypair.fromSecretKey(secretKeyBytes);
var receiver = new PublicKey("DxPv2QMA5cWR5Xfg7tXr5YtJ1EEStg5Kiag9HhkY1mSx");
var instruction = new TransferInstruction(sender.getPublicKey(), receiver, 1000);
var transaction = new Transaction(
        blockhash,
        instruction,
        sender.getPublicKey()
);
transaction.sign(sender);
var signature = connection.sendTransaction(transaction);
```

Check the full source code of this example
[on GitHub](https://github.com/sol4k/sol4k-examples/blob/main/src/main/java/org/sol4kdemo/SolTransfer.java).

Sol4k APIs closely follow those of web3.js. If you have experience with web3.js,
the code above will look familiar to you.

Here is an example of a wallet balance query
([full code](https://github.com/sol4k/sol4k-examples/blob/main/src/main/java/org/sol4kdemo/GetWalletBalance.java)):

```java
var connection = new Connection("https://api.devnet.solana.com");
var wallet = new PublicKey("DxPv2QMA5cWR5Xfg7tXr5YtJ1EEStg5Kiag9HhkY1mSx");
var balance = connection.getBalance(wallet);
System.out.println("Balance in Lamports: " + balance);
```


All sol4k development is done in [the main project repository](https://github.com/sol4k/sol4k).
The release process is automated, and the source code is monitored. If you would like to
contribute, you can always create a pull request, open an issue, or start a discussion. Good luck!