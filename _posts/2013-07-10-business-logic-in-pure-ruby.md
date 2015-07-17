---
layout: post
title: Business Logic in Pure Ruby
tags:
- ruby
- rails
type: post
published: true
---
<p class="intro">Why "the Rails way" of putting all business logic in models will cause you pain as your application grows and limit your ability to scale. Avoid this by putting that logic in pure Ruby classes and think about ActiveRecord differently.</p>

__Update 7/7/15__: This was kind of slapped together into order to give a lightening talk. [I highly suggest you read this article instead by Dave Copeland](http://multithreaded.stitchfix.com/blog/2015/06/02/anatomy-of-service-objects-in-rails/). It's much more thoughtful and covers the same points in more depth. He also focuses on the positives of a good approach, whereas this spends most of the time discussing flaws and barely mentions a better approach at the end. I would revise it but Dave basically did it for me!

## Flaws of the traditional MVC approach

### Large models are hard to navigate

Take a look at a familiar Product model that is present in many e-commerce sites. (We'll refer to this again later as well.)

{% highlight ruby %}
class Product < ActiveRecord::Base

  def price(currency = 'USD')
    # Not great code I know, but I've seen it done...
    currency == 'USD' ? base_price : international_price(currency)
    # ...
  end

  def description
    # ...
  end

  def related_items
    # ...
  end

  # ... 1,000 more lines of code ...

  private

  def international_price(currency)
    # Other model stuff in my model. Yuck.
    conversion_rate = ConversionRate.find_by_currency(currency)
    # ...
  end

  # ... another 1,000 lines of code ...

end
{% endhighlight %}

All of that scrolling! In this short snippet of an example, there are at least three different concerns shown in that model. In real life there will be dozens by the time your product evolves. Sure, they all have to do with a Product, but that classification is too coarse to use in designing good software. A class like this will be little more than a pile of spaghetti-string methods in no time.


### Tests become too complex

#### Large test files

In the first example you'll have a huge test file that will take a long time to run all of the tests. Nested _describe_ and _context_ blocks start showing up all over, as well as an increasing need for difficult to manage shared examples.

#### Slow tests

Often you you can avoid loading the full Rails stack entirely if you are just running tests for a file that is only testing a discreet bit of business logic. It may be fast enough to run just one example at a time in most cases, but if you are heavily refactoring you may want to often run all related tests at once. Doing that in a huge ActiveRecord model will be really slow.

#### Missing or duplicate test coverage

Another danger of complexity is that it's easy to miss and even duplicate test coverage because it hard to see at a glance what has been tested and what hasn't.

### Simpler code design

#### Easier comprehension

Engineers are capable of understanding very complex systems. That doesn't mean you should accept overly complicated designs. It's much easier to comprehend the design of simple, related chunks of code, which helps you write better applications.

#### Fewer bugs

When it's harder to see how something works, it's much easier to miss flaws. The more complex you allow your code to be the more bugs you will have. Bugs are for the birds. (Literally.)

#### Work faster

Simple code design means you work faster! No digging around for the definition of some logic and less need down the road for complex refactoring.

### Decouple the design of your data and application

#### Logic and persistence of data are different concerns

Just because you store a raw price in a <em>products</em> table in the database doesn't mean it's a good design to put all pricing related logic in a Product model. Often in more complex applications there are multiple data sources in play. In our pricing example you will likely need data pertaining to price in a Product model but also other data sources that have information about things like current conversion rates between currencies. Instead of spreading your logic out over multiple models, put all of those concerns in one place and just load the data you need.

#### Limited ability to refactor

Refactoring becomes somewhat limited to your ability to change your data model. In some environments this isn't trivial. For example, it's common for analytics and business intelligence teams to use raw SQL for reports or pipe them into some sort of data warehouse software. If changing your business logic means changing your data model you'll also have to change those systems as well. Instead, design your data model as it makes sense and your application as it makes sense. These are not always necessarily the same.

#### Different data stores

What if you want to use a different data store for those currency conversion rates? Maybe they start as a database model and then are moved out into an API service you created or that is built by someone else. Not all data makes sense in a relational database and sometimes they change. Don't move all of your code around to accommodate it.

#### ActiveRecord as "persistence layer configuration"

ActiveRecord models can and mostly should be void of all business logic and act simply as "persistence layer configuration." To that end they can store validations at the data level, relationships between other models, etc. Outside of that, there's probably a better place for your logic. It should be a rare thing to define a method in a Rails model.

### More portable code

#### Multiple apps and Service Oriented Architectures

This is a small point to make but with __huge__ implications. When it's time to break the application into multiple, smaller applications or services it's much easier and safer if you already have it split up among logical concerns. (Trust me, some day you _will_ want to break it up.) If you have lots of fat models you'll have a really hard time splitting that apart and will involve rewriting a good chunk of your application.

#### Gems and non-Rails apps

Maybe you want to move the logic to a gem that is also run from a command-line or just used in other application. Maybe it makes sense for your new service application to be written in Sinatra instead of Rails. Similar to the last point, it's much easier to break up your code to live elsewhere when concerns are isolated and not closely tied to a data model.

## A better design

### Mixin approach

A quick answer is just to share appropriate code in a Mixin:

{% highlight ruby %}
module InternationalPriceConcerns
  # Methods to mix in to any type of object involving pricing.
  # This module can be be used in your other models as well.
  # Often you'll have pricing for the both top-level Product and at the SKU level, possibly even down to your model for inventory units.
  # ...
end
{% endhighlight %}

This works well enough, but you're really on fooling yourself into thinking you've designed something better, when really you just put some of your methods in a different file. This avoids code duplication, but it's still essentially the same design.

### Service class approach

To really understand the service class approach, take a look at [this article by Dave Copeland](http://multithreaded.stitchfix.com/blog/2015/06/02/anatomy-of-service-objects-in-rails/). (As a bonus, it has a bit on the mixin approach as well.) In short, this approach clearly defines a file that has one concern, with one or two public methods. It's small and does just what it should and no more.

Taking a few of the methods out of our original `Product` model above, you may end up with these service classes:

{% highlight ruby %}
class ProductPriceService
  def price_for(product)
    # ...
  end

  private

  # Implementation details not necessary as part of the public API of the class
end
{% endhighlight %}

{% highlight ruby %}
class RelatedItemService
  def items_for(product)
    # ...
  end

  private

  # Implementation details not necessary as part of the public API of the class
end
{% endhighlight %}

These classes are small, easy to understand, quick to test, and very portable.