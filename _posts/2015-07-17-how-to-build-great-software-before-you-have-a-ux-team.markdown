---
layout: post
title:  "How to build great software before you have a UX team"
date:   2015-07-17 08:10:00
categories: ux
published: true
---
<p class="intro">User Experience Design tips for Software Engineers</p>

At Stitch Fix we now have a dedicated team of amazing User Experience/User Interface engineers. However, we didn't always. Early on it was our full stack engineers that designed the products. Despite having a dedicated UX team now, they are in hot demand, so we still end up doing a fair bit of product design. So how did we manage to make fairly good applications before we were able to hire the really awesome folks to help us?

## Be the user
Spending time in the user's shoes is the best way to learn how to build a great experience. At Stitch Fix this can mean a number of things. For the Warehouse and Operations team it's often finding the merchandise that goes in a shipment or processing a return. For others it could be working with elaborate and unwieldy spreadsheets in order to handle purchase orders. If you don't have a UX team to help research the process then there's one way to find out how it works. Sit down and do it yourself! Common sense, right? But so often overlooked, maybe because the handing off of requirements is just so common in software engineering that we don't always think to find another way.

There are a lot of reasons why this is so effective but I'll put my money on just one: engineers thrive on efficiency. Our master engineer, [Dave Copeland](http://naildrivin5.com/), demonstrated this well when a long time ago he built the first version of our returns processing tool. As my memory recalls, he got two or three bags in to our old manual process before he stood up and drove to Office Max to buy a USB barcode scanner to make the process more efficient. Now, we process returns with 2-6 barcode scans rather than filling out values in an HTML form. It also paved the way for barcode usage warehouse-wide. All because he couldn't stand that he had to fill out that form more than once.

So, once you have an idea of what to build, what do you do next?

## Throw away the old user interface

It's very rare to build anything where no prior product exists. If you're building a new solution, it's likely that there's already something there, even if it’s an Excel spreadsheet or post-it notes.

Start with a clean slate when you begin thinking about the problem. Consider only the inputs and outputs for the most efficient way of getting from A to B. Don't let yourself get bogged down by what the current interface looks like. That's how you end up trying to solve every problem by cramming in a new button or just one more icon.

## Throw away the old code too

This one applies to more than just user interfaces. It's way too easy to get deep into the weeds trying to add just one more action to an existing controller. But saving a small amount of time now by trying to reuse old code and you'll soon have an unmaintainable mess that becomes more and more inflexible. Further, the design of your backend code will inevitably affect the choices you make in building the user interface.

As engineers, we tend to get too attached to existing code even when it's no longer relevant. It's either well written and you don't want to let it go or because it means you have to rewrite all of the tests that go with it. Either way, let it go anyway! Take the time to refactor now and you'll get it all back (and then some) by not needing to revisit it as often in the future because your users are happy and efficiently working with their well designed product.

## Final thoughts

There is no magic wand to wave that will help you build a great application but simplifying everything is a great way to start. The approach will be much more clear when you remove assumptions and learn first-hand about the problem. Clearing away roadblocks of existing interfaces and code add another level of freedom to think about the problem from the ground up.

These tips will help when you are working with a UX expert as well. You'll be a better partner in the design process and execute it much more effectively. They are also of great value in designing code in general, even when no user interface is involved. After all, software is full of all different kinds of interfaces!