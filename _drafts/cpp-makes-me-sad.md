---
layout: post
title: C++, The Zero-Overhead Principle, and Lying
date: 
---

Part of the attractive value proposition of C++ is the zero-overhead principle. According to language creator Bjarne Stroustrup in ["Foundations of C++"](https://www.stroustrup.com/ETAPS-corrected-draft.pdf), there are two components to this:
1. You don't pay for what you don't use.
2. What you do use, you couldn’t hand code any better.
The "what you use" here is referring to language features, and "better" refers to efficiency. While each component falls under the umbrella of zero-overhead, they have distinct effects on the C++ programmer.
INTRODUCTION TO OVERHEAD AND ABSTRACTION

"You don't pay for what you don't use" improves the control C++ programmers have over the behavior have over their code. The classic counter example of a feature which violates this is garbage collection. In languages like Java, at any point the runtime may decide its time to free up some memory and effectively pause the execution of the program. For some use cases this is acceptable, but in performance sensative cases where C++ is almost ubiquitious, that lack of control is unacceptable. {EXAMPLES}

"What you do use, you couldn't hand code any better" enables C++ programmers to be more productive, more expressive, and write more performant software. There is a popular notion that there is an inverse relationship between abstraction and performance; the more abstractly a language wishes to express itself, the less performant code written in that language will be. Bjarne and other C++ language advocates suggest that notion is not just false, but the opposite of true. It is subtle but important that the principle is not that "you could hand code something equally efficient", but that you couldn't do any better. They say is possible to write code which is both more abstract and faster by consequence of that abstraction. HOW IS THAT ACHEIVED

The impressionable reader may think to themselves "This is all fantastic! The C++ programmer may reap the benefits of abstraction with no cost to control, no cost to performance, no cost at all it seems! In fact, given C++ code is faster than lower level alternatives, we may rightly call the zero-overhead principle a misnomer. Indeed, it is *negative*-overhead abstractions being described!". While I would be tickled by the excitement of this declaration, I would offer such a reader some warning. Firstly, that their usage of exclamation points is bordering on excess. Secondly, that while they are correct that "zero-overhead" is one of many C++ misnomers (along with `std::vector`, `std::move`, `inline`, and countless others), they are wrong about the sign of that overhead in the mathematic sense.

It cannot be ignored that there simply cannot be such a thing as a "zero-overhead abstraction" to a compiler. Compilation requires crossing the distance between a machine code and a higher level language. The more abstract the language, the further it gets from the machine, and the longer it takes to cross that distance. There will always be compile time overhead to abstraction. This is the reason why C++ has such infamously long compile times. However, it very well may be the case that the strict type checking which C++ abstraction enables mean C++ code has to be compiled less. SOURCE HERB SUTTER. Being generous, we may say there is net zero-overhead to C++ compilation times, and let it off the hook.

While it does not discredit the claim of the zero-overhead principle, it is worth noting that "What you do use, you couldn’t hand code any better" does not guarantee you will use the right thing. In fact, because C++ is so complicated it is really easy to use the wrong thing. Even a competent programmer may misuse some C++ feature and produce code which is pessimized in an obscure way, which may be obvious if if the hand-coded alternative was in front of them. There is an obfuscating overhead to abstractions, especially in a system as complicated as C++.

However, where the zero-overhead principle falls apart is the notion that "You don't pay for what you don't use". If we look at C++ for even a moment, we see a few key features which clearly violate this principle, infect every line of C++, and make any claim to "zero-overhead" null and void. Some of these features compilers have added an option to turn off, but some are so ingrained in the language that the C++ programmer has no choice but to accept.

# Exceptions

# RTTI

# Move Semantics
