For quite some time I have had an idea about writing my own small PHP-framework for small sites such as this one. Motivation behind the idea was that even if it doesn’t take too long to hack a site together by modifying older sites, extending them later on has proved to be time consuming.

The plan was not to write yet another CMS with web based authoring, but instead write a few well though basic components for a tiny MVC framework. The operating words being: “tiny”, “simple” and “self-contained”.  The basic requirements I had in mind were:

* As few dependencies on outside libraries as possible.
* Small set of base classes, extended if needed depending on the web site.
* Simple configuration of visible URLs and matching controllers. 
* Dependency injection would be nice.

While doing research for the best was to implement a small dependency injection container I first found out [Pimple](http://pimple-project.org/) and then [Silex](http://silex-project.org/) which uses it. Going over the Silex features it seemed to be an exact match for the requirements I had set, so I decided to first do a simple exercise site with a few static pages.

The experiment proved extremely successful and I decided to rewrite this site using Silex. I didn’t come across any terrible design issues in the framework and using it was a breeze. So I can heartily recommend Silex if you are building a small website. From my experiences I would guess that Silex scales into medium sized web sites quite easily, if you don’t need
CMS features.
