ExceliDerp
==========

How not to make a custom renderer in Rails.

Wha?
----

While wrangling with the issues the lead to the [Excelinator](http://github.com/livingsocial/excelinator) gem, I wondered
what it would take to not require _any_ additional code in your Rails app to support Excel versions of existing CSV and HTML views. 
I learned a lot about how some of the Rails rendering pipeline works, and while it was waaay too much monkey-patching to actually use,
it couldn't be forgotten. So I've turned this into a short talk - and here's the code.